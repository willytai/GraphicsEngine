//
//  InputCodes.h
//  RayTracing
//
//  Created by Willy Tai on 5/10/23.
//

#ifndef InputCodes_h
#define InputCodes_h

typedef enum : NSUInteger {
    Left = 1 << 0,
    Right = 1 << 1,
    LeftNRight = Left | Right,
} MouseButton;

#endif /* InputCodes_h */
