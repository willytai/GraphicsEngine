//
//  MainWindow.mm
//  RayTracing
//
//  Created by Willy Tai on 5/10/23.
//

#import "MainWindow.h"
#import "../Utils/Logger.h"

static os_log_t LOGGER = os_log_create("App.RayTracing.GraphicsEngine", "MainWindow");

@implementation MainWindow

- (BOOL)acceptsMouseMovedEvents {
    return NO;
}

- (void)performClose:(id)sender {
    LOG_INFO(LOGGER, "Closing main window...");
    [super performClose:sender];
}

@end
