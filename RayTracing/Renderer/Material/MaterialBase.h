//
//  MaterialBase.h
//  RayTracing
//
//  Created by Willy Tai on 7/3/23.
//

#ifndef MaterialBase_h
#define MaterialBase_h

#import "../Shader/VertexType.hpp"

#define GEN_MATERIAL_ID(id) \
+ (VtxMaterialIDType)MaterialID \
{ \
    static VtxMaterialIDType matid = id; \
    return matid; \
}

// TODO not final, just a thought
// base class for materials
@protocol MaterialBase <NSObject>



@end


#endif /* MaterialBase_h */
