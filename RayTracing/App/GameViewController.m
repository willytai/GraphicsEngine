//
//  GameViewController.m
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import "GameViewController.h"
#import "EventCallbacks.h"
#import "MyView.h"
#import "../Renderer/Renderer.h"

@implementation GameViewController
{
    MyView* _view;

    Renderer* _renderer;

    ScrollCallback      _scrollCallback;
    MouseDownCallback   _mouseDownCallback;
    MouseUpCallback     _mouseUpCallback;
    KeyDownCallback     _keyDownCallback;
    KeyUpCallback       _keyUpCallback;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _view = (MyView *)self.view;

    _view.device = MTLCreateSystemDefaultDevice();

    if(!_view.device)
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

- (void)_setupEventCallbacks {
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
- (void)mouseMoved:(NSEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)scrollWheel:(NSEvent *)event {
    _scrollCallback(event.deltaY);
}

@end
