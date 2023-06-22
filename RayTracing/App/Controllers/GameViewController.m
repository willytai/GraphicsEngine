//
//  GameViewController.m
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import "GameViewController.h"
#import "SummaryViewController.h"
#import "../EventCallbacks.h"
#import "../Views/GameView.h"
#import "../../Renderer/Renderer.h"
#import "../../Utils/Logger.h"


@implementation GameViewController
{
    GameView* _view;

    Renderer* _renderer;

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
    [super viewDidLoad];

    _view = (GameView*)self.view;

    _view.device = MTLCreateSystemDefaultDevice();

    if (!_view.device)
    {
        NSLog(@"Metal is not supported on this device");
        self.view = [[NSView alloc] initWithFrame:self.view.frame];
        return;
    }

    _renderer = [[Renderer alloc] initWithMetalKitView:_view];

    [_renderer mtkView:_view drawableSizeWillChange:_view.bounds.size];

    _view.delegate = _renderer;

    [self _setupEventCallbacks];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    /// Register observers
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(switchSitched:)
                                               name:SummaryViewController.NotificationName_SwitchSwitched
                                             object:nil];
}

#pragma mark Notifications

- (void)switchSitched:(NSNotification*)notification
{
    LOG_INFO("%s called, notification %@ received", __PRETTY_FUNCTION__, notification.name);
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
    }

    // mouse down
    {
        typeof(self) __weak weakself = self;
        _mouseDownCallback = ^(MouseButton button){
            typeof(weakself) __strong self = weakself;
            [self->_renderer onMouseDown:button];
        };
    }

    // mouse up
    {
        typeof(self) __weak weakself = self;
        _mouseUpCallback = ^(void){
            typeof(weakself) __strong self = weakself;
            [self->_renderer onMouseUp];
        };
    }

    // key down
    {
        typeof(self) __weak weakself = self;
        _keyDownCallback = ^(unsigned short keyCode, NSUInteger modifierFlags){
            typeof(weakself) __strong self = weakself;
            [self->_renderer onKeyDown:keyCode
                          WithModifier:modifierFlags];
        };
    }

    // key up
    {
        typeof(self) __weak weakself = self;
        _keyUpCallback = ^(unsigned short keyCode){
            typeof(weakself) __strong self = weakself;
            [self->_renderer onKeyUp:keyCode];
        };
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
