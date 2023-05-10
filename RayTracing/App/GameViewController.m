//
//  GameViewController.m
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import "GameViewController.h"
#import "Renderer.h"
#import "MyView.h"
#import "EventCallbacks.h"

@implementation GameViewController
{
    MyView *_view;

    Renderer *_renderer;

    ScrollEventCallback _scrollEventCallback;
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
    typeof(self) __weak weakself = self;
    _scrollEventCallback = ^(float deltaY){
        typeof(weakself) __strong self = weakself;
        [self->_renderer onScrolled:deltaY];
    };
}


/// Event Handling Here

- (void)keyDown:(NSEvent *)event {
    NSLog(@"%s, %@, %u, %lu", __PRETTY_FUNCTION__, event.characters, event.keyCode, (unsigned long)event.modifierFlags);
    if (event.modifierFlags & NSEventModifierFlagOption) {
        NSLog(@"option is pressed");
    }
    // NSLog(@"%lu", (unsigned long)NSEvent.pressedMouseButtons);
}

- (void)keyUp:(NSEvent *)event {
    // NSLog(@"%s, %@, %u", __PRETTY_FUNCTION__, event.characters, event.keyCode);
}

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"%s, %lu", __PRETTY_FUNCTION__, (unsigned long)NSEvent.pressedMouseButtons);
}

- (void)scrollWheel:(NSEvent *)event {
    _scrollEventCallback(event.deltaY);
}

@end
