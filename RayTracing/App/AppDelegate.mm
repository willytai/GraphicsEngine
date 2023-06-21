//
//  AppDelegate.mm
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import "AppDelegate.h"
#import "../Utils/Logger.h"


static os_log_t LOGGER = os_log_create("App.RayTracing.GraphicsEngine", "AppDelegate");


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification*)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
    return YES;
}

- (IBAction)toggleStatusWindow:(NSMenuItem*)sender {
    // If the state is off and the item is clicked, we want to toggle it on
    bool showWindow = sender.state == NSControlStateValueOff;
    LOG_INFO(LOGGER, "%s status window", showWindow ? "Showing" : "Closing");

    // TODO show window
    //      don't know how to send signals to game view controller

    // toggle the checkmark
    sender.state = showWindow ? NSControlStateValueOn : NSControlStateValueOff;
}

@end
