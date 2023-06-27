//
//  SummaryViewController.m
//  RayTracing
//
//  Created by Willy Tai on 6/20/23.
//

#import "SummaryViewController.h"
#import "../Notification.h"
#import "../../Utils/Logger.h"


@interface SummaryViewController ()

@end

@implementation SummaryViewController
GEN_CLASS_LOGGER("SummarViewController.RayTracing.GraphicsEngine", "SummaryViewController")
GEN_NOTIFICATION_NAME(NotificationName_SwitchSwitched)
GEN_NOTIFICATION_NAME(NotificationName_RenderingModeChanged)

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark Actions

- (IBAction)switchSwitchedAction:(NSSwitch*)sender
{
    LOG_INFO("Posting notification from %s", __PRETTY_FUNCTION__);
    [NSNotificationCenter.defaultCenter postNotificationName:SummaryViewController.NotificationName_SwitchSwitched
                                                      object:self];
}

- (IBAction)RenderingModeChangedAction:(NSComboBox*)sender {
    LOG_INFO("Posting notification from %s", __PRETTY_FUNCTION__);
    [NSNotificationCenter.defaultCenter postNotificationName:SummaryViewController.NotificationName_RenderingModeChanged
                                                      object:self
                                                    userInfo:@{
                                                        NotificationUserInfoTag_StringVal: sender.stringValue
                                                    }
    ];
}

@end
