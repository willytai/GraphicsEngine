//
//  Renderer.m
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import <simd/simd.h>
#import <ModelIO/ModelIO.h>

#import "Renderer.h"
#import "Asset/Mesh.h"
#import "Camera.h"
#import "Shader/ShaderTypes.h"
#import "../Utils/Logger.h"
#import "../Utils/Math.hpp"
#import "../Utils/Timer.hpp"


static const NSUInteger kMaxBuffersInFlight = 3;

static const size_t kAlignedUniformsSize = (sizeof(Uniforms) & ~0xFF) + 0x100;


@interface Renderer()

/// Declaring as private property so that we can give access to test classes by
/// declaring the interface.
@property(nonatomic, readonly, nonnull) MTLVertexDescriptor* mtlVertexDescriptor;

@end

@implementation Renderer
{
    dispatch_semaphore_t _inFlightSemaphore;
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLLibrary> _shaderLibrary;

    id<MTLBuffer> _dynamicUniformBuffer;
    id<MTLRenderPipelineState> _pipelineState;
    id<MTLDepthStencilState> _depthState;

    uint32_t    _uniformBufferOffset;
    uint8_t     _uniformBufferIndex;
    void*       _uniformBufferAddress;

    // size of the frame
    CGSize      _size;

    uint32_t    _frameIndex;

    NSArray<id<MTLTexture> >*       _accumulationTargets;
    id<MTLComputePipelineState>     _rayTracingPipelineState;
    id<MTLRenderPipelineState>      _copyPipelineState;

    // asset
    Scene*      _scene;


    /// added
    Timer   _timer;
    Camera* _camera;
    Mesh*   _testMesh;
}
GEN_CLASS_LOGGER("Renderer.RayTracing.GraphicsEngine", "Renderer")

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view Scene:(nonnull Scene *)scene
{
    self = [super init];
    if(self)
    {
        _device = view.device;
        _scene = scene;
        _inFlightSemaphore = dispatch_semaphore_create(kMaxBuffersInFlight);
        [self _loadMetalWithView:view];
        [self _loadAssets];
        [self _initCamera];
        _timer.reset();
    }

    return self;
}

#pragma mark Setup and Load

- (void)_initCamera
{
    CameraParams cameraParams;
    cameraParams.fov = 45.0f; // in degrees
    cameraParams.width = 1280.0f;
    cameraParams.height = 720.0f;
    cameraParams.nearClip = 0.1f;
    cameraParams.farClip = 1000.0f;
    _camera = [[Camera alloc] initWithParams:cameraParams];

    LOG_INFO("Camera initialized");
}

- (void)_loadMetalWithView:(nonnull MTKView*)view;
{
    // init shader library
    _shaderLibrary = [_device newDefaultLibrary];

    // init pipeline states
    [self _invalidatePipelineStatesWithView:view];

    // init uniform buffer
    NSUInteger uniformBufferSize = kAlignedUniformsSize * kMaxBuffersInFlight;
    _dynamicUniformBuffer = [_device newBufferWithLength:uniformBufferSize
                                                 options:MTLResourceStorageModeShared];
    if (!_dynamicUniformBuffer)
    {
        LOG_ERROR("Failed to created uniform buffer");
    }
    else {
        LOG_INFO("Uniform buffer successfully created");
        _dynamicUniformBuffer.label = @"UniformBuffer";
    }

    // init command queue
    _commandQueue = [_device newCommandQueue];
    if (!_commandQueue)
    {
        LOG_ERROR("Failed to created command queue");
    }
    else {
        LOG_INFO("Command queue successfully created");
    }
}

- (void)_invalidatePipelineStatesWithView:(nonnull MTKView*)view
{
    // init states once only
    // view is shared, update enforced
    if (self.rendererMode == RendererModeNormalRendering) {
        // configure view
        view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
        view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
        view.sampleCount = 1;
        if (_pipelineState == nil) {
            [self _initNormalPipelineStatesWithView:view];
        }
    }
    else if (self.rendererMode == RendererModeRayTracing ) {
        // configure view
        view.colorPixelFormat = MTLPixelFormatRGBA8Unorm;
        view.sampleCount = 1;
        if (_rayTracingPipelineState == nil) {
            [self _initRayTracingPipelineStatesWithView:view];
        }
    }
    else {
        LOG_ERROR("Unrecognized mode: %lu", self.rendererMode);
    }
}

- (void)_initVertexDescriptor
{
    _mtlVertexDescriptor = [[MTLVertexDescriptor alloc] init];

    _mtlVertexDescriptor.attributes[VertexAttributePosition].format = MTLVertexFormatFloat3;
    _mtlVertexDescriptor.attributes[VertexAttributePosition].offset = 0;
    _mtlVertexDescriptor.attributes[VertexAttributePosition].bufferIndex = BufferIndexMeshPositions;

    _mtlVertexDescriptor.attributes[VertexAttributeNormal].format = MTLVertexFormatFloat3;
    _mtlVertexDescriptor.attributes[VertexAttributeNormal].offset = 0;
    _mtlVertexDescriptor.attributes[VertexAttributeNormal].bufferIndex = BufferIndexMeshNormals;

    _mtlVertexDescriptor.attributes[VertexAttributeMaterialID].format = MTLVertexFormatUChar;
    _mtlVertexDescriptor.attributes[VertexAttributeMaterialID].offset = 0;
    _mtlVertexDescriptor.attributes[VertexAttributeMaterialID].bufferIndex = BufferIndexMeshMaterialIDs;

    _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stride = sizeof(VtxPositionType);
    _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stepRate = 1;
    _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stepFunction = MTLVertexStepFunctionPerVertex;

    _mtlVertexDescriptor.layouts[BufferIndexMeshNormals].stride = sizeof(VtxNormalType);
    _mtlVertexDescriptor.layouts[BufferIndexMeshNormals].stepRate = 1;
    _mtlVertexDescriptor.layouts[BufferIndexMeshNormals].stepFunction = MTLVertexStepFunctionPerVertex;

    _mtlVertexDescriptor.layouts[BufferIndexMeshMaterialIDs].stride = sizeof(VtxMaterialIDType);
    _mtlVertexDescriptor.layouts[BufferIndexMeshMaterialIDs].stepRate = 1;
    _mtlVertexDescriptor.layouts[BufferIndexMeshMaterialIDs].stepFunction = MTLVertexStepFunctionPerVertex;

    LOG_INFO("Vertex descriptor initialized");
}

- (void)_initNormalPipelineStatesWithView:(nonnull MTKView*)view
{
    // init vertex descriptor
    [self _initVertexDescriptor];

    // pipeline state
    MTLRenderPipelineDescriptor* pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"FinalPipeline";
    pipelineStateDescriptor.rasterSampleCount = view.sampleCount;
    pipelineStateDescriptor.vertexFunction = [_shaderLibrary newFunctionWithName:@"vertexShader"];
    pipelineStateDescriptor.fragmentFunction = [_shaderLibrary newFunctionWithName:@"fragmentShader"];
    pipelineStateDescriptor.vertexDescriptor = _mtlVertexDescriptor;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat;

    NSError *error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState)
    {
        LOG_ERROR("Failed to created pipeline state, error %@", error);
    }
    else {
        LOG_INFO("Pipeline state successfully created");
    }

    MTLDepthStencilDescriptor* depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthStateDesc.depthWriteEnabled = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
    if (!_depthState)
    {
        LOG_ERROR("Failed to created depth/stencil state");
    }
    else {
        LOG_INFO("Depth/Stencil state successfully created");
    }
}

- (void)_initRayTracingPipelineStatesWithView:(nonnull MTKView*)view
{
    // Ray tracing kernel pipeline state
    MTLComputePipelineDescriptor* rayTracingDescriptor = [[MTLComputePipelineDescriptor alloc] init];
    rayTracingDescriptor.label = @"Ray Tracing Pipeline";

    // The ray tracing kernel
    rayTracingDescriptor.computeFunction = [_shaderLibrary newFunctionWithName:@"rayTracingKernel"];

    // Optimization
    rayTracingDescriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = YES;

    NSError* error;

    // create the ray tracing kernel pipeline state
    _rayTracingPipelineState = [_device newComputePipelineStateWithDescriptor:rayTracingDescriptor
                                                                      options:MTLPipelineOptionNone
                                                                   reflection:nil
                                                                        error:&error];

    if (_rayTracingPipelineState)
    {
        LOG_INFO("%@ successfully created", rayTracingDescriptor.label);
    }
    else
    {
        LOG_ERROR("Failed to create %@: %@", rayTracingDescriptor.label, error);
    }
    
    // Copy pipeline state
    MTLRenderPipelineDescriptor* copyPassDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    copyPassDescriptor.label = @"Copy Pipeline";
    copyPassDescriptor.vertexFunction = [_shaderLibrary newFunctionWithName:@"copyVertex"];
    copyPassDescriptor.fragmentFunction = [_shaderLibrary newFunctionWithName:@"copyFragment"];
    copyPassDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    
    // create the copy pipeline state
    _copyPipelineState = [_device newRenderPipelineStateWithDescriptor:copyPassDescriptor error:&error];
    
    if (_copyPipelineState)
    {
        LOG_INFO("%@ successfully created", copyPassDescriptor.label);
    }
    else
    {
        LOG_ERROR("Failed to create %@: %@", copyPassDescriptor.label, error);
    }
}

- (void)_loadAssets
{

    // BufferDataAllocator* bufferDataAllocator = [[BufferDataAllocator alloc] initWithDevice:_device];
    // _testMesh = [Mesh newCubeWithDimensionX:5.0f Y:1.0f Z:10.0f Allocator:bufferDataAllocator];
    // _testMesh = [Mesh newIcosphereWithSubdivisions:3
    //                                      Allocator:bufferDataAllocator];
    
    [_scene upload];
    LOG_INFO("Scene %@ loaded", _scene.name);

}

#pragma mark Per Frame Update

- (void)_updateDynamicBufferState
{
    /// Update the state of our uniform buffers before rendering

    _uniformBufferIndex = (_uniformBufferIndex + 1) % kMaxBuffersInFlight;

    _uniformBufferOffset = kAlignedUniformsSize * _uniformBufferIndex;

    _uniformBufferAddress = ((uint8_t*)_dynamicUniformBuffer.contents) + _uniformBufferOffset;
}

- (void)_updateGameStateWithDeltaTime:(TimeStep)deltaTime
{
    /// Update any game state before encoding renderint commands to our drawable

    // NSLog(@"delta time: %.4f", deltaTime.ms());
    [_camera onUpdateWithDeltaTime:deltaTime];

    Uniforms* uniforms = (Uniforms*)_uniformBufferAddress;

    uniforms->projectionMatrix = _camera.projMat;
    uniforms->viewMatrix = _camera.viewMat;
    uniforms->viewProjectionMatrix = _camera.viewProjMat;
    uniforms->frameIndex = _frameIndex;
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    /// Per frame updates here
    // NSLog(@"[mouse location] %f, %f", NSEvent.mouseLocation.x, NSEvent.mouseLocation.y);

    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);

    [self _updateDynamicBufferState];

    [self _updateGameStateWithDeltaTime:_timer.deltaTime()];

    if (self.rendererMode == RendererModeNormalRendering) {
        [self _regularRenderingWithView:view];
    }
    else if (self.rendererMode == RendererModeRayTracing) {
        [self _rayTracingRenderingWithView:view];
    }
}

- (void)_rayTracingRenderingWithView:(nonnull MTKView*)view
{
    // Create commnad buffer
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer)
        {
         dispatch_semaphore_signal(block_sema);
        }
    ];

    // Launch a rectangular grid of threads with one thread per pixel.
    // We indicated that thread group size is always a multiple of the
    // thread execution width for further optimization. Need to align
    // the number of threads to a multiple of the thread group size.
    // TODO Set this dynamically to maximize the number of threads per
    //      thread group and minimize the underused threads.
    MTLSize threadsPerThreadGroup = MTLSizeMake(8, 8, 1);
    MTLSize threadGroups = MTLSizeMake(
        (_size.width + threadsPerThreadGroup.width - 1) / threadsPerThreadGroup.width,
        (_size.height + threadsPerThreadGroup.height - 1) / threadsPerThreadGroup.height,
        1
    );

    // compute encoder
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    computeEncoder.label = @"Ray Tracing Kernel Encoder";
    [computeEncoder pushDebugGroup:@"Ray Tracing Pass"];
    // bind the uniform buffer
    [computeEncoder pushDebugGroup:@"Resource Setup"];
    [computeEncoder setBuffer:_dynamicUniformBuffer offset:_uniformBufferOffset atIndex:BufferIndexUniforms];
    // bind the accumulation texture
    [computeEncoder setTexture:_accumulationTargets[0] atIndex:TextureIndexRayTracingKernelDestinationTarget];
    [computeEncoder popDebugGroup];
    // bind the ray tracing pipeline state
    [computeEncoder setComputePipelineState:_rayTracingPipelineState];
    // dispatch kernel
    [computeEncoder pushDebugGroup:@"Dispatch Call"];
    [computeEncoder dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadsPerThreadGroup];
    [computeEncoder popDebugGroup];
    // end
    [computeEncoder popDebugGroup];
    [computeEncoder endEncoding];


    // copy into view, delay this as much as possible 
    id<CAMetalDrawable> drawable = nil;
    if ((drawable = view.currentDrawable)) {
        MTLRenderPassDescriptor* copyPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];

        // since the entire texture is copied, we don't care of the load action
        // a clear color is also not needed
        copyPassDescriptor.colorAttachments[0].texture = drawable.texture;
        copyPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionDontCare;

        id<MTLRenderCommandEncoder> copyPassEncoder = [commandBuffer renderCommandEncoderWithDescriptor:copyPassDescriptor];
        copyPassEncoder.label = @"Copy Pass Encoder";
        [copyPassEncoder pushDebugGroup:@"Copy Pass"];
        [copyPassEncoder setRenderPipelineState:_copyPipelineState];
        [copyPassEncoder setFragmentTexture:_accumulationTargets[0] atIndex:TextureIndexCopyShaderDestinationTarget];
        [copyPassEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];
        [copyPassEncoder popDebugGroup];
        [copyPassEncoder endEncoding];

        [commandBuffer presentDrawable:drawable];
    }

    [commandBuffer commit];
}

- (void)_regularRenderingWithView:(nonnull MTKView*)view
{
    /// Create commnad buffer
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer)
     {
         dispatch_semaphore_signal(block_sema);
     }];

    /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
    ///   holding onto the drawable and blocking the display pipeline any longer than necessary
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;

    if(renderPassDescriptor != nil) {

        /// Final pass rendering code here
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.6f, 0.7f, 0.9f, 1.0f);

        id <MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"FinalRenderEncoder";

        [renderEncoder pushDebugGroup:@"DrawMesh"];

        [renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
        [renderEncoder setCullMode:MTLCullModeBack];
        [renderEncoder setRenderPipelineState:_pipelineState];
        [renderEncoder setDepthStencilState:_depthState];

        /// bind uniform buffer
        [renderEncoder setVertexBuffer:_dynamicUniformBuffer
                                offset:_uniformBufferOffset
                               atIndex:BufferIndexUniforms];

        [renderEncoder setFragmentBuffer:_dynamicUniformBuffer
                                  offset:_uniformBufferOffset
                                 atIndex:BufferIndexUniforms];

        /// one draw call per instance
        for (GeometryInstance* instance in _scene.instances) {
            [self _drawMesh:instance Encoder:renderEncoder];
        }

        [renderEncoder popDebugGroup];

        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)_drawMesh:(GeometryInstance*)instance Encoder:(id<MTLRenderCommandEncoder>)renderEncoder
{
    GeometryResource resource = instance.geometry.resource;
    id<Geometry>     geometry = instance.geometry;

    // TODO should do something with the transfrom
    // simd_float4x4 transfrom = instance.transform;
    
    // bind resources
    for (MeshBuffer* vertexBuffer in resource.vertexBuffers) {
        [renderEncoder setVertexBuffer:vertexBuffer.buffer
                                offset:vertexBuffer.offset
                               atIndex:vertexBuffer.bufferIndex];
    }
    
    // draw mesh
    [renderEncoder drawIndexedPrimitives:geometry.primitiveType
                              indexCount:geometry.indexCount
                               indexType:geometry.indexType
                             indexBuffer:resource.indexBuffer.buffer
                       indexBufferOffset:resource.indexBuffer.offset];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    /// Respond to drawable size or orientation changes here

    /// Camera update
    [_camera onResizeWidth:size.width Height:size.height];

    /// Framebuffer update - accumulation targets
    MTLTextureDescriptor* descriptor = [[MTLTextureDescriptor alloc] init];
    descriptor.width = size.width;
    descriptor.height = size.height;
    descriptor.textureType = MTLTextureType2D;
    descriptor.pixelFormat = MTLPixelFormatRGBA32Float;
    // GPU access only
    descriptor.storageMode = MTLStorageModePrivate;
    descriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
    _accumulationTargets = @[
        [_device newTextureWithDescriptor:descriptor],
        [_device newTextureWithDescriptor:descriptor],
    ];

    /// Size update
    _size = size;

    // Reset frame index
    _frameIndex = 0;
}

#pragma mark Event Callbacks

- (void)onScrolled:(float)deltaY
{
    [_camera onScrolled:deltaY];
}

- (void)onMouseDown:(MouseButton)button
{
    if (button == MouseButton::Left)
        [_camera onLeftMouseDown];
}

- (void)onMouseUp
{
    [_camera onLeftMouseUp];
}

- (void)onKeyDown:(unsigned short)keyCode
     WithModifier:(NSUInteger)modifierFlags
{
    [_camera onKeyDown:keyCode];
}

- (void)onKeyUp:(unsigned short)keyCode
{
    [_camera onKeyUp:keyCode];
}

#pragma mark Other

- (void)setRendererMode:(RendererMode)rendererMode WithView:(MTKView *)view
{
    _rendererMode = rendererMode;
    [self _invalidatePipelineStatesWithView:view];
}

+ (RendererMode)getRendererModeFromString:(nonnull NSString*)mode
{
    if ([mode isEqualToString:@"Ray Tracing"]) {
        return RendererModeRayTracing;
    }
    else if ([mode isEqualToString:@"Normal Rendering"]) {
        return RendererModeNormalRendering;
    }
    return RendererModeUndefined;
}

@end
