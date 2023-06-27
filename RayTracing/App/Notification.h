//
//  Notification.h
//  RayTracing
//
//  Created by Willy Tai on 6/21/23.
//

#ifndef Notification_h
#define Notification_h

#import <Foundation/Foundation.h>

#define GEN_NOTIFICATION_NAME(name) \
+ (NSNotificationName)name \
{ \
    static NSNotificationName name = @#name; \
    return name; \
}

#define GEN_NOTIFICATION_USER_INFO_TAG(tag) \
static NSString* NotificationUserInfoTag_##tag = @"NotificationUserInfoTag_"#tag

GEN_NOTIFICATION_USER_INFO_TAG(StringVal);

#endif /* Notification_h */
