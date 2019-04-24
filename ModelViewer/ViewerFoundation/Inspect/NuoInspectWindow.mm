//
//  NuoInspectWindow.m
//  ModelViewer
//
//  Created by middleware on 9/7/18.
//  Copyright © 2018 middleware. All rights reserved.
//

#import "NuoInspectWindow.h"
#import "NuoMetalView.h"

#import "NuoInspectableMaster.h"

#import "NuoInspectPass.h"
#import "NuoRenderPassTarget.h"


@interface NuoInspectWindow() < NSWindowDelegate >

@end



@implementation NuoInspectWindow
{
    NuoMetalView* _inspectView;
    NSString* _name;
    
    NuoInspectPass* _renderPass;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device
                      withName:(NSString*)name
{
    self = [super init];
    
    if (self)
    {
        self.releasedWhenClosed = NO;
        
        CGRect rect = self.contentView.bounds;
        
        _inspectView = [[NuoMetalView alloc] initWithFrame:rect device:device];
        
        [_inspectView commonInit];
        [self.contentView addSubview:_inspectView];
        [self setDelegate:self];
        [self setTitle:[NSString stringWithFormat:@"Inspect - %@", NuoInspectableMaster.inspectableList[name].displayTitle]];
        
        _name = name;
        NuoInspectableMaster* inspectMaster = [NuoInspectableMaster sharedMaster];
        NuoInspectable* inspectable = [inspectMaster setInspector:self forName:_name];
        
        BOOL forBuffer = inspectable.inspectingBufferMean != nil;
        NSString* inspectingMean = forBuffer ? inspectable.inspectingBufferMean :
                                               inspectable.inspectingTextureMean;
        
        _renderPass = [[NuoInspectPass alloc] initWithCommandQueue:_inspectView.commandQueue
                                                   withPixelFormat:MTLPixelFormatBGRA8Unorm
                                                       withProcess:inspectingMean
                                                         forBuffer:forBuffer];
        
        NuoRenderPassTarget* renderTarget = [[NuoRenderPassTarget alloc] initWithCommandQueue:_inspectView.commandQueue
                                                                              withPixelFormat:MTLPixelFormatBGRA8Unorm
                                                                              withSampleCount:1];
        renderTarget.clearColor = MTLClearColorMake(0, 0, 0, 0);
        renderTarget.manageTargetTexture = NO;
        renderTarget.name = @"Inspect";
        
        [_renderPass setRenderTarget:renderTarget];
        [_renderPass setShowCheckerboard:YES];
        
        [self setupPipeline];
    }
    
    return self;
}



- (void)setupPipeline
{
    [_inspectView setRenderPasses:@[_renderPass]];
}


- (void)windowDidResize:(NSNotification *)notification
{
    CGRect frame = self.contentView.bounds;
    
    _inspectView.frame = frame;
}


- (BOOL)windowShouldClose:(NSNotification *)notification
{
    NuoInspectableMaster* inspectMaster = [NuoInspectableMaster sharedMaster];
    [inspectMaster removeInspectorForName:_name];
    
    return YES;
}


- (void)inspect
{
    NuoInspectableMaster* inspectMaster = [NuoInspectableMaster sharedMaster];
    NuoInspectable* inspectable = [inspectMaster.inspectables objectForKey:_name];
    
    id<MTLTexture> texture = inspectable.inspectedTexture;
    inspectable.inspector = self;
    _renderPass.sourceTexture = texture;
    
    id<MTLBuffer> buffer = inspectable.inspectedBuffer;
    if (buffer)
        [_renderPass updateBuffer:buffer withRange:inspectable.inspectedBufferRange];
    
    [_inspectView render];
}


- (void)setInspectAspectRatio:(CGFloat)aspectRatio
{
    [self setContentAspectRatio:CGSizeMake(aspectRatio, 1.0)];
}


@end
