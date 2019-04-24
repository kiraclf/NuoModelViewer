//
//  NuoInspectableMaster.m
//  ModelViewer
//
//  Created by middleware on 9/7/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#import "NuoInspectableMaster.h"



static NuoInspectableMaster* sInspectableMaster = nil;


NSString* const kInspectable_Immediate = @"inspectable_immediate";
NSString* const kInspectable_ImmediateAlpha = @"inspectable_immediateAlpha";
NSString* const kInspectable_Illuminate = @"inspectable_illuminate";
NSString* const kInspectable_Ambient = @"inspectable_ambient";
NSString* const kInspectable_Shadow = @"inspectable_shadow";
NSString* const kInspectable_ShadowTranslucent = @"inspectable_shadowTranslucent";
NSString* const kInspectable_ShadowOverlay = @"inspectable_shadowOverlay";
NSString* const kInspectable_PrimaryRay = @"inspectable_primaryRay";


@implementation NuoInspectable


+ (NuoInspectable*)inspectableTextureWithTitle:(NSString*)title withMean:(NSString*)mean
{
    NuoInspectable* inspect = [NuoInspectable new];
    inspect.displayTitle = title;
    inspect.inspectingTextureMean = mean;
    
    return inspect;
}


+ (NuoInspectable*)inspectableBufferWithTitle:(NSString*)title withMean:(NSString*)mean
{
    NuoInspectable* inspect = [NuoInspectable new];
    inspect.displayTitle = title;
    inspect.inspectingBufferMean = mean;
    
    return inspect;
}


@end


@implementation NuoInspectableMaster

+ (NuoInspectableMaster*)sharedMaster
{
    if (!sInspectableMaster)
    {
        sInspectableMaster = [NuoInspectableMaster new];
    }
    
    return sInspectableMaster;
}


+ (NSDictionary<NSString*, NuoInspectable*>*)inspectableList
{
    return @{ kInspectable_Immediate: [NuoInspectable inspectableTextureWithTitle:@"Immediate" withMean:nil],
              kInspectable_ImmediateAlpha: [NuoInspectable inspectableTextureWithTitle:@"Immediate Alpha" withMean:@"fragment_alpha"],
              kInspectable_Illuminate: [NuoInspectable inspectableTextureWithTitle:@"Illumination" withMean:nil],
              kInspectable_Ambient: [NuoInspectable inspectableTextureWithTitle:@"Ambient" withMean:nil],
              kInspectable_Shadow: [NuoInspectable inspectableTextureWithTitle:@"Shadow on Opaque" withMean:@"fragment_r"],
              kInspectable_ShadowTranslucent: [NuoInspectable inspectableTextureWithTitle:@"Shadow on Translucent" withMean:@"fragment_g"],
              kInspectable_ShadowOverlay: [NuoInspectable inspectableTextureWithTitle:@"Shadow Overlay" withMean:@"fragment_r"],
              kInspectable_PrimaryRay: [NuoInspectable inspectableBufferWithTitle:@"Primary Ray" withMean:@"compute_visualize_ray_direction"] };
}


- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _inspectables = [NSMutableDictionary new];
    }
    
    return self;
}



- (NuoInspectable*)inspectableForName:(NSString*)name create:(BOOL)create
{
    NuoInspectable* inspectable = [_inspectables objectForKey:name];
    
    if (!inspectable && create)
    {
        inspectable = [NuoInspectableMaster inspectableList][name];
        [_inspectables setObject:inspectable forKey:name];
    }
    
    return inspectable;
}


- (void)updateTexture:(id<MTLTexture>)texture forName:(NSString*)name
{
    NuoInspectable* inspectable = [self inspectableForName:name create:NO];
    inspectable.inspectedTexture = texture;
}


- (void)updateBuffer:(id<MTLBuffer>)buffer
            forRange:(const NuoRangeUniform&)range
             forName:(NSString*)name
{
    NuoInspectable* inspectable = [self inspectableForName:name create:NO];
    inspectable.inspectedBuffer = buffer;
    inspectable.inspectedBufferRange = range;
}



- (void)removeInspectorForName:(NSString*)name
{
    NuoInspectable* inspectable = [[NuoInspectable alloc] init];
    inspectable.inspector = [self inspectableForName:name create:NO].inspector;
    
    [_inspectables removeObjectForKey:name];
}


- (NuoInspectable*)setInspector:(id<NuoInspector>)inspector forName:(NSString*)name;
{
    NuoInspectable* inspectable = [self inspectableForName:name create:YES];
    inspectable.inspector = inspector;
    
    return inspectable;
}



- (void)inspect
{
    for (NSString* inspectable in _inspectables)
    {
        id<MTLTexture> inspectedTexture = _inspectables[inspectable].inspectedTexture;
        if (inspectedTexture)
            [_inspectables[inspectable].inspector setInspectAspectRatio:(float)[inspectedTexture width] / (float)[inspectedTexture height]];
        
        id<MTLBuffer> inspectedBuffer = _inspectables[inspectable].inspectedBuffer;
        NuoRangeUniform range = _inspectables[inspectable].inspectedBufferRange;
        if (inspectedBuffer)
            [_inspectables[inspectable].inspector setInspectAspectRatio:range.w / range.h];
        
        [_inspectables[inspectable].inspector inspect];
    }
}


@end
