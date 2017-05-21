//
//  ShadowMapRenderer.h
//  ModelViewer
//
//  Created by middleware on 1/16/17.
//  Copyright © 2017 middleware. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <simd/simd.h>

#import "NuoRenderPass.h"


@class LightSource;
@class NuoMeshCompound;
@class NuoShadowMapTarget;


@interface ShadowMapRenderer : NuoRenderPass

/**
 *  The light source for which the shadow map is generated for.
 */
@property (nonatomic, weak) LightSource* lightSource;

/**
 *  Scene information, mostly passed from the model renderer, hence the
 *  weak renference.
 */
@property (nonatomic, weak) NuoMeshCompound* mesh;

/**
 *  Shadow map, the depth texture from the view point of the light source.
 */
@property (nonatomic, strong) NuoShadowMapTarget* shadowMap;


- (instancetype)initWithDevice:(id<MTLDevice>)device withName:(NSString*)name;


/**
 *  The projection matrix from the view point of the lightSource.
 */
- (matrix_float4x4)lightCastMatrix;


@end
