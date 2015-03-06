//
//  NadeSpot.m
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "NadeSpot.h"

@implementation NadeSpot
@synthesize xCord = _xCord;
@synthesize yCord = _yCord;

@synthesize nadeFrom = _nadeFrom;

-(id) initWithX:(CGFloat) xCord Y:(CGFloat)yCord fromLocations:(NSArray *)origin{
    if (self = [super init]) {
        self.xCord = xCord;
        self.yCord = yCord;
        self.nadeFrom = origin;
    }
    return self;
}

@end

