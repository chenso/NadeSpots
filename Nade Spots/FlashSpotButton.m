//
//  FlashSpotButton.m
//  Nade Spots
//
//  Created by Songge Chen on 3/17/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "FlashSpotButton.h"

@implementation FlashSpotButton



- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self setImage:[UIImage imageNamed:@"flashbangIcon"] forState:UIControlStateNormal];
}

-(void) deselect {
    UIImage * toImage = [UIImage imageNamed:@"flashbang_deselected.png"];
    [UIView transitionWithView:self.imageView
                      duration:0.4f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageView.image = toImage;
                    } completion:nil];
    
}

-(void) defaultImage {
    UIImage * toImage = [UIImage imageNamed:@"flashbangIcon.png"];
    [UIView transitionWithView:self.imageView
                      duration:0.4f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageView.image = toImage;
                    } completion:nil];
}

@end
