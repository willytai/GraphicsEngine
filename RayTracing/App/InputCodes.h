//
//  InputCodes.h
//  RayTracing
//
//  Created by Willy Tai on 5/10/23.
//

#ifndef InputCodes_h
#define InputCodes_h

typedef NS_ENUM(NSUInteger, MouseButton) {
    Left = 1 << 0,
    Right = 1 << 1,
    LeftNRight = Left | Right,
};

typedef NS_ENUM(unsigned short, Key) {
    A = 0,
    D = 2,
    E = 14,
    Q = 12,
    S = 1,
    W = 13,
};

#endif /* InputCodes_h */
