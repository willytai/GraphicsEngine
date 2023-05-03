//
//  GameViewController.m
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import "GameViewController.h"
#import "Renderer.h"
#import "MyView.h"

@implementation GameViewController
{
    MyView *_view;

    Renderer *_renderer;
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
}


/// Event Handling Here

- (void)keyDown:(NSEvent *)event {
    NSLog(@"%s, %@, %u", __PRETTY_FUNCTION__, event.characters, event.keyCode);
}

- (void)keyUp:(NSEvent *)event {
    NSLog(@"%s, %@, %u", __PRETTY_FUNCTION__, event.characters, event.keyCode);
}

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)scrollWheel:(NSEvent *)event {
    NSLog(@"%.4f, %.4f", event.scrollingDeltaY, event.deltaY);
}

@end
