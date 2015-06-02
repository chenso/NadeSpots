//
//  NadeSpotButton.h
//  Nade Spots
//
//  Created by Songge Chen on 3/17/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NadeSpotButton : UIButton
@property (strong, nonatomic) NSArray * nadeFromSpots;
@property (strong, nonatomic) NSString * nadeType;

-(id) initWithFrame:(CGRect)frame NadeType:(NSString *) nadeType;
@end
