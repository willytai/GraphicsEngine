//
//  GameViewController.m
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import "GameViewController.h"
#import "SummaryViewController.h"
#import "../EventCallbacks.h"
#import "../Notification.h"
#import "../Views/GameView.h"
#import "../../Renderer/Asset/DataAllocator.h"
#import "../../Renderer/Renderer.h"
#import "../../Renderer/Scene.h"
#import "../../Utils/Logger.h"


@implementation GameViewController
{
    GameView*           _view;

    DataAllocator*      _dataAllocator;
    Scene*              _scene;
    Renderer*           _renderer;

    ScrollCallback      _scrollCallback;
    MouseDownCallback   _mouseDownCallback;
    MouseUpCallback     _mouseUpCallback;
    KeyDownCallback     _keyDownCallback;
    KeyUpCallback       _keyUpCallback;
}
GEN_CLASS_LOGGER("GameViewController.RayTracing.GraphicsEngine", "GameViewController")

#pragma mark View Controller Lifecycle

- (void)viewDidLoad
{
    LOG_INFO("View loaded into memory");
    [super viewDidLoad];

    _view = (GameView*)self.view;

    /// Select device
    if (!(_view.device = [self _selectDevice]))
    {
        LOG_ERROR("Both Metal and Ray Tracing should be supported on this device");
        self.view = [[NSView alloc] initWithFrame:self.view.frame];
        return;
    }
    else
    {
        LOG_INFO("Selected Device: %@", _view.device.name);
    }

    /// Rgister callbacks
    [self _setupEventCallbacks];

    /// Register observers
    [self _registerNotificationObservers];
    
    /// Initialize allocator
    _dataAllocator = [[DataAllocator alloc] initWithDevice:_view.device];
    
    /// Create scene
    _scene = [[Scene alloc] initWithBufferDataAllocator:_dataAllocator];

    /// Initialize renderer
    _renderer = [[Renderer alloc] initWithMetalKitView:_view Scene:_scene];

    /// sync view size
    [_renderer mtkView:_view drawableSizeWillChange:_view.bounds.size];

    /// set delegate
    _view.delegate = _renderer;
}

- (id<MTLDevice>)_selectDevice
{
    NSArray<id<MTLDevice> >* devices = MTLCopyAllDevices();
    id<MTLDevice> selected = nil;
    for (id<MTLDevice> device in devices) {
        if (!device.supportsRaytracing) continue;
        if (selected && !selected.isLowPower) break;
        // prioritize high power device that supports ray tracing
        selected = device;
    }
    return selected;
}

#pragma mark Notifications

- (void)_switchSitched:(NSNotification*)notification
{
    LOG_INFO("%s called, notification %@ received", __PRETTY_FUNCTION__, notification.name);
}

- (void)_renderingModeChanged:(NSNotification*)notification
{
    NSString* str = notification.userInfo[NotificationUserInfoTag_StringVal];
    LOG_INFO("%s called, notification %@ received, switching mode to %@", __PRETTY_FUNCTION__, notification.name, str);
    RendererMode rendererMode = [Renderer getRendererModeFromString:str];
    [_renderer setRendererMode:rendererMode WithView:_view];
}

#pragma mark Observers
- (void)_registerNotificationObservers
{
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(_switchSitched:)
                                               name:SummaryViewController.NotificationName_SwitchSwitched
                                             object:nil];
    LOG_INFO("Observer registered for %@", SummaryViewController.NotificationName_SwitchSwitched);
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(_renderingModeChanged:)
                                               name:SummaryViewController.NotificationName_RenderingModeChanged
                                             object:nil];
    LOG_INFO("Observer registered for %@", SummaryViewController.NotificationName_RenderingModeChanged);
}

#pragma mark Callbacks

- (void)_setupEventCallbacks
{
    // mouse scrolled
    {
        typeof(self) __weak weakself = self;
        _scrollCallback = ^(float deltaY){
            typeof(weakself) __strong self = weakself;
            [self->_renderer onScrolled:deltaY];
        };
        LOG_INFO("Event callback registered for mouse scrolled");
    }

    // mouse down
    {
        typeof(self) __weak weakself = self;
        _mouseDownCallback = ^(MouseButton button){
            typeof(weakself) __strong self = weakself;
            [self->_renderer onMouseDown:button];
        };
        LOG_INFO("Event callback registered for mouse down");
    }

    // mouse up
    {
        typeof(self) __weak weakself = self;
        _mouseUpCallback = ^(void){
            typeof(weakself) __strong self = weakself;
            [self->_renderer onMouseUp];
        };
        LOG_INFO("Event callback registered for mouse up");
    }

    // key down
    {
        typeof(self) __weak weakself = self;
        _keyDownCallback = ^(unsigned short keyCode, NSUInteger modifierFlags){
            typeof(weakself) __strong self = weakself;
            [self->_renderer onKeyDown:keyCode
                          WithModifier:modifierFlags];
        };
        LOG_INFO("Event callback registered for key down");
    }

    // key up
    {
        typeof(self) __weak weakself = self;
        _keyUpCallback = ^(unsigned short keyCode){
            typeof(weakself) __strong self = weakself;
            [self->_renderer onKeyUp:keyCode];
        };
        LOG_INFO("Event callback registered for key up");
    }
}


/// Event Handling Here

- (void)keyDown:(NSEvent *)event {
    // NSLog(@"%s, %@, %u, %lu", __PRETTY_FUNCTION__, event.characters, event.keyCode, (unsigned long)event.modifierFlags);
    _keyDownCallback(event.keyCode, event.modifierFlags);
}

- (void)keyUp:(NSEvent *)event {
    _keyUpCallback(event.keyCode);
}

- (void)mouseDown:(NSEvent *)event {
    _mouseDownCallback(NSEvent.pressedMouseButtons);
}

/// This will only be called when the LEFT mouse button is down -> up
- (void)mouseUp:(NSEvent *)event {
    _mouseUpCallback();
}

/// The window defaults to not accept mouse moved events.
/// To change the behavior, set acceptsMouseMovedEvent to Yes in the MyWindow class.
- (void)mouseMoved:(NSEvent *)event
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)scrollWheel:(NSEvent *)event
{
    _scrollCallback(event.deltaY);
}

@end
