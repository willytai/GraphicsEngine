//
//  Convert2Metal.h
//  RayTracing
//
//  Created by Willy Tai on 6/1/23.
//

#ifndef Convert2Metal_h
#define Convert2Metal_h

#import <Metal/Metal.h>
#import "../Renderer/Geometries/GeometryObj.hpp"


static MTLIndexType toMetalIndexType(GeometryIndexType type) {
    switch (type) {
        case GeometryIndexType::UInt16: return MTLIndexTypeUInt16;
        case GeometryIndexType::UInt32: return MTLIndexTypeUInt32;
    }
}


#endif /* Convert2Metal_h */
