//
//  Notification.h
//  RayTracing
//
//  Created by Willy Tai on 6/21/23.
//

#ifndef Notification_h
#define Notification_h

#define GEN_NOTIFICATION_NAME(name) \
+ (NSNotificationName)name \
{ \
    static NSNotificationName name = @#name; \
    return name; \
}


#endif /* Notification_h */
