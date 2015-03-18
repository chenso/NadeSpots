//
//  NadeSpotButton.h
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NadeSpotButton : UIButton
@property (strong, nonatomic) NSArray * nadeFromSpots;

-(void)deselect;
-(void) defaultImage;
@end
