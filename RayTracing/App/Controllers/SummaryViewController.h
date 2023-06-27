//
//  SummaryViewController.h
//  RayTracing
//
//  Created by Willy Tai on 6/20/23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SummaryViewController : NSViewController

@property(class, readonly, strong) NSNotificationName NotificationName_SwitchSwitched;
@property(class, readonly, strong) NSNotificationName NotificationName_RenderingModeChanged;

@end

NS_ASSUME_NONNULL_END
