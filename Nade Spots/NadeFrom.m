//
//  NadeFrom.m
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "NadeFrom.h"

@implementation NadeFrom
@synthesize path = _path;
@synthesize xCord = _xCord;
@synthesize  yCord = _yCord;

-(id) initWithPath:(NSString *)path xCord:(CGFloat) xCord yCord:(CGFloat) yCord {
    if (self = [super init]) {
        self.path = path;
        self.xCord = xCord;
        self.yCord = yCord;
    }
    return self;
}
@end
