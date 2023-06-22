//
//  MainWindow.mm
//  RayTracing
//
//  Created by Willy Tai on 5/10/23.
//

#import "MainWindow.h"
#import "../Utils/Logger.h"


@implementation MainWindow
GEN_CLASS_LOGGER("App.RayTracing.GraphicsEngine", "MainWindow")

- (BOOL)acceptsMouseMovedEvents {
    return NO;
}

- (void)performClose:(id)sender {
    LOG_INFO("Closing main window...");
    [super performClose:sender];
}

@end
