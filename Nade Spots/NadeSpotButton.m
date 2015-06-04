//
//  NadeSpotButton.m
//  Nade Spots
//
//  Created by Songge Chen on 3/17/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "NadeSpotButton.h"

@implementation NadeSpotButton

@synthesize nadeFromSpots = _nadeFromSpots;
-(id) initWithFrame:(CGRect)frame NadeType:(NSString *) nadeType nadeFromSpots:(NSArray *) nadeFromSpots{
    if (self = [super initWithFrame:frame]) {
        self.nadeType = nadeType;
        self.nadeFromSpots = nadeFromSpots;
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    UIImage * defaultImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_deselected",self.nadeType]];
    [self setImage:defaultImage forState:UIControlStateNormal];
    
    UIImage * selectedImage =[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",self.nadeType]];
    [self setImage:selectedImage forState:UIControlStateSelected];
}

@end
