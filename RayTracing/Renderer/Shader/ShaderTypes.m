//
//  ShaderTypes.m
//  RayTracing
//
//  Created by Willy Tai on 6/23/23.
//

#import "ShaderTypes.h"

size_t sizeofAttribute(VertexAttribute attribute) {
    switch (attribute) {
        case VertexAttributePosition:   return sizeof(VtxPositionType);
        case VertexAttributeNormal:     return sizeof(VtxNormalType);
        case VertexAttributeMaterialID: return sizeof(VtxMaterialIDType);
        default: printf("Undefined attribute size for attribute: %d, did you forget to add it here?\n", (int)attribute); assert(false);
    }
    return 0xffff;
}
