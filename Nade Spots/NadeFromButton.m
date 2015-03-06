//
//  NadeFromButton.m
//  Nade Spots
//
//  Created by Songge Chen on 2/26/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "NadeFromButton.h"

@implementation NadeFromButton
@synthesize path = _path;

-(id) initWithPath:(NSString *)path{
    if (self = [super init]) {
        self.path = path;
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self setImage:[UIImage imageNamed:@"nadeFromIcon"] forState:UIControlStateNormal];
}


@end
