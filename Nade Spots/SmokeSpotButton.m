//
//  NadeSpotButton.m
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "NadeSpotButton.h"

@implementation NadeSpotButton

@synthesize nadeFromSpots = _nadeFromSpots;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


- (void)drawRect:(CGRect)rect {
    // Drawing code
     [self setImage:[UIImage imageNamed:@"smokeIcon"] forState:UIControlStateNormal];
}

-(void) deselect {
    UIImage * toImage = [UIImage imageNamed:@"smoke_deselected.png"];
    [UIView transitionWithView:self.imageView
                      duration:0.4f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageView.image = toImage;
                    } completion:nil];
    
}

-(void) defaultImage {
    UIImage * toImage = [UIImage imageNamed:@"smokeIcon.png"];
    [UIView transitionWithView:self.imageView
                      duration:0.4f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageView.image = toImage;
                    } completion:nil];
}

@end
