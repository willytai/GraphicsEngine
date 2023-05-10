//
//  EventCallbacks.h
//  RayTracing
//
//  Created by Willy Tai on 5/10/23.
//

#ifndef EventCallbacks_h
#define EventCallbacks_h

#include "InputCodes.h"

typedef void(^ScrollCallback)(float);
typedef void(^MouseDownCallback)(MouseButton);
typedef void(^MouseUpCallback)(void);
typedef void(^KeyDownCallback)(unsigned short, NSUInteger);
typedef void(^KeyUpCallback)(unsigned short);

#endif /* EventCallbacks_h */
