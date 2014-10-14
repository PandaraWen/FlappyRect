//
//  SRScene.m
//  FlappyRect
//
//  Created by Pandara on 14-10-1.
//  Copyright (c) 2014年 Pandara. All rights reserved.
//

#import "SRScene.h"

@interface SRScene()

@property BOOL contentCreated;

@end

@implementation SRScene

- (void)didMoveToView:(SKView *)view
{
    if (_contentCreated) {
        return;
    }
    
    [self initalize];
    self.contentCreated = YES;
}

- (void)initalize
{
    
}

@end
