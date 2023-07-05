//
//  DefaultMaterial.h
//  RayTracing
//
//  Created by Willy Tai on 7/3/23.
//

#import <Foundation/Foundation.h>
#import "MaterialBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DefaultMaterial : NSObject <MaterialBase>

@property(class, readonly) VtxMaterialIDType MaterialID;

@end

NS_ASSUME_NONNULL_END
