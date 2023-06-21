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
#import "Asset/BufferDataAllocator.h"
#import "Camera.h"
#import "Geometries/Cube.hpp"
#import "Shader/ShaderTypes.h"
#import "../Utils/Logger.h"
#import "../Utils/Logger.hpp"
#import "../Utils/Math.hpp"
#import "../Utils/Timer.hpp"

static const NSUInteger kMaxBuffersInFlight = 3;

static const size_t kAlignedUniformsSize = (sizeof(Uniforms) & ~0xFF) + 0x100;

static os_log_t LOGGER = os_log_create("Renderer.RayTracing.GraphicsEngine", "Renderer");


@interface Renderer()

/// Declaring as private property so that we can give access to test classes by
/// declaring the interface.
@property(nonatomic, readonly, nonnull) MTLVertexDescriptor* mtlVertexDescriptor;

@end

@implementation Renderer
{
    dispatch_semaphore_t _inFlightSemaphore;
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;

    id <MTLBuffer> _dynamicUniformBuffer;
    id <MTLRenderPipelineState> _pipelineState;
    id <MTLDepthStencilState> _depthState;
    // id <MTLTexture> _colorMap;
    // MTLVertexDescriptor* _mtlVertexDescriptor;

    uint32_t _uniformBufferOffset;

    uint8_t _uniformBufferIndex;

    void* _uniformBufferAddress;

    // float _rotation;

    // MTKMesh *_mesh;


    /// added
    Timer   _timer;
    Camera* _camera;
    Mesh*   _testMesh;
}

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;
{
    self = [super init];
    if(self)
    {
        _device = view.device;
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

    LOG_INFO(LOGGER, "Camera initialized");
}

- (void)_loadMetalWithView:(nonnull MTKView *)view;
{
    /// Load Metal state objects and initialize renderer dependent view properties

    [self _initVertexDescriptor];

    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    view.sampleCount = 1;

    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

    id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];

    id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];

    MTLRenderPipelineDescriptor* pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"FinalPipeline";
    pipelineStateDescriptor.rasterSampleCount = view.sampleCount;
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.vertexDescriptor = _mtlVertexDescriptor;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat;

    NSError *error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState)
    {
        LOG_ERROR(LOGGER, "Failed to created pipeline state, error %@", error);
    }
    else {
        LOG_INFO(LOGGER, "Pipeline state successfully created");
    }

    MTLDepthStencilDescriptor* depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthStateDesc.depthWriteEnabled = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
    if (!_depthState)
    {
        LOG_ERROR(LOGGER, "Failed to created depth/stencil state");
    }
    else {
        LOG_INFO(LOGGER, "Depth/Stencil state successfully created");
    }

    NSUInteger uniformBufferSize = kAlignedUniformsSize * kMaxBuffersInFlight;
    _dynamicUniformBuffer = [_device newBufferWithLength:uniformBufferSize
                                                 options:MTLResourceStorageModeShared];
    if (!_dynamicUniformBuffer)
    {
        LOG_ERROR(LOGGER, "Failed to created uniform buffer");
    }
    else {
        LOG_INFO(LOGGER, "Uniform buffer successfully created");
        _dynamicUniformBuffer.label = @"UniformBuffer";
    }

    _commandQueue = [_device newCommandQueue];
    if (!_commandQueue)
    {
        LOG_ERROR(LOGGER, "Failed to created command queue");
    }
    else {
        LOG_INFO(LOGGER, "Command queue successfully created");
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
    _mtlVertexDescriptor.attributes[VertexAttributeMaterialID].bufferIndex = BufferIndexMeshMaterialID;

    _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stride = sizeof(VtxPositionType);
    _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stepRate = 1;
    _mtlVertexDescriptor.layouts[BufferIndexMeshPositions].stepFunction = MTLVertexStepFunctionPerVertex;

    _mtlVertexDescriptor.layouts[BufferIndexMeshNormals].stride = sizeof(VtxNormalType);
    _mtlVertexDescriptor.layouts[BufferIndexMeshNormals].stepRate = 1;
    _mtlVertexDescriptor.layouts[BufferIndexMeshNormals].stepFunction = MTLVertexStepFunctionPerVertex;

    _mtlVertexDescriptor.layouts[BufferIndexMeshMaterialID].stride = sizeof(VtxMaterialIDType);
    _mtlVertexDescriptor.layouts[BufferIndexMeshMaterialID].stepRate = 1;
    _mtlVertexDescriptor.layouts[BufferIndexMeshMaterialID].stepFunction = MTLVertexStepFunctionPerVertex;

    LOG_INFO(LOGGER, "Vertex descriptor initialized");
}

- (void)_loadAssets
{

    BufferDataAllocator* bufferDataAllocator = [[BufferDataAllocator alloc] initWithDevice:_device];
    _testMesh = [Mesh newCubeWithDimensionX:5.0f Y:1.0f Z:10.0f Allocator:bufferDataAllocator];
    _testMesh = [Mesh newIcosphereWithSubdivisions:3
                                         Allocator:bufferDataAllocator];
    
    LOG_INFO(LOGGER, "Asset loaded");

    /// Load assets into metal objects

    // NSError *error;

    // MTKMeshBufferAllocator *metalAllocator = [[MTKMeshBufferAllocator alloc]
    //                                           initWithDevice: _device];

    // MDLMesh *mdlMesh = [MDLMesh newEllipsoidWithRadii:mathutil::float3(3.0f, 3.0f, 3.0f)
    //                                    radialSegments:20
    //                                  verticalSegments:20
    //                                      geometryType:MDLGeometryTypeTriangles
    //                                     inwardNormals:NO
    //                                        hemisphere:NO
    //                                         allocator:metalAllocator];

    // MDLVertexDescriptor *mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(_mtlVertexDescriptor);

    // mdlVertexDescriptor.attributes[VertexAttributePosition].name  = MDLVertexAttributePosition;
    // mdlVertexDescriptor.attributes[VertexAttributeNormal].name  = MDLVertexAttributeNormal;

    // mdlMesh.vertexDescriptor = mdlVertexDescriptor;

    // _mesh = [[MTKMesh alloc] initWithMesh:mdlMesh
    //                                device:_device
    //                                 error:&error];

    // if(!_mesh || error)
    // {
    //     NSLog(@"Error creating MetalKit mesh %@", error.localizedDescription);
    // }

    // MTKTextureLoader* textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];

    // NSDictionary *textureLoaderOptions =
    // @{
    //   MTKTextureLoaderOptionTextureUsage       : @(MTLTextureUsageShaderRead),
    //   MTKTextureLoaderOptionTextureStorageMode : @(MTLStorageModePrivate)
    //   };

    // _colorMap = [textureLoader newTextureWithName:@"ColorMap"
    //                                   scaleFactor:1.0
    //                                        bundle:nil
    //                                       options:textureLoaderOptions
    //                                         error:&error];

    // if(!_colorMap || error)
    // {
    //     NSLog(@"Error creating texture %@", error.localizedDescription);
    // }
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
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    /// Per frame updates here
    // NSLog(@"[mouse location] %f, %f", NSEvent.mouseLocation.x, NSEvent.mouseLocation.y);

    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);

    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer)
     {
         dispatch_semaphore_signal(block_sema);
     }];

    [self _updateDynamicBufferState];

    [self _updateGameStateWithDeltaTime:_timer.deltaTime()];

    /// Delay getting the currentRenderPassDescriptor until we absolutely need it to avoid
    ///   holding onto the drawable and blocking the display pipeline any longer than necessary
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;

    if(renderPassDescriptor != nil) {

        /// Final pass rendering code here
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.6f, 0.7f, 0.9f, 1.0f);

        id <MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"FinalRenderEncoder";

        [renderEncoder pushDebugGroup:@"DrawBox"];

        [renderEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
        [renderEncoder setCullMode:MTLCullModeBack];
        [renderEncoder setRenderPipelineState:_pipelineState];
        [renderEncoder setDepthStencilState:_depthState];

        [renderEncoder setVertexBuffer:_dynamicUniformBuffer
                                offset:_uniformBufferOffset
                               atIndex:BufferIndexUniforms];

        [renderEncoder setFragmentBuffer:_dynamicUniformBuffer
                                  offset:_uniformBufferOffset
                                 atIndex:BufferIndexUniforms];

        for (NSUInteger bufferIndex = 0; bufferIndex < _testMesh.vertexBuffers.count; bufferIndex++)
        {
            MeshBuffer *vertexBuffer = _testMesh.vertexBuffers[bufferIndex];
            if((NSNull*)vertexBuffer != [NSNull null])
            {
                [renderEncoder setVertexBuffer:vertexBuffer.buffer
                                        offset:vertexBuffer.offset
                                       atIndex:bufferIndex];
            }
        }

        // [renderEncoder setFragmentTexture:_colorMap
        //                           atIndex:TextureIndexColor];

        for(Submesh *submesh in _testMesh.submeshes)
        {
            [renderEncoder drawIndexedPrimitives:submesh.primitiveType
                                      indexCount:submesh.indexCount
                                       indexType:submesh.indexType
                                     indexBuffer:submesh.indexBuffer.buffer
                               indexBufferOffset:submesh.indexBuffer.offset];
        }

        [renderEncoder popDebugGroup];

        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    /// Respond to drawable size or orientation changes here
    [_camera onResizeWidth:size.width Height:size.height];
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

@end
