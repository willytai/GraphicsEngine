//
//  AppDelegate.mm
//  RayTracing
//
//  Created by Willy Tai on 5/1/23.
//

#import "AppDelegate.h"
#import "../Utils/Logger.h"


@interface AppDelegate ()

@end

@implementation AppDelegate
GEN_CLASS_LOGGER("App.RayTracing.GraphicsEngine", "AppDelegate")

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
    LOG_INFO("%s status window", showWindow ? "Showing" : "Closing");

    // TODO show window
    //      don't know how to send signals to game view controller

    // toggle the checkmark
    sender.state = showWindow ? NSControlStateValueOn : NSControlStateValueOff;
}

@end
