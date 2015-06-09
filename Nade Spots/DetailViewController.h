//
//  DetailViewController.h
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//
#import "NadeFromButton.h"
#import "NadeSpotButton.h"
#import "VideoView.h"
#import <iAd/iAd.h>
#import <QuartzCore/QuartzCore.h>

#define BOTTOM_BAR_HEIGHT ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)? 80 : 40)
#define VIDEO_INVERSE_ASPECT 0.5625
#define IADBANNER_HEIGHT 50
#define NADE_BUTTON_DIM 45
#define PLAYER_BUTTON_DIM 35

@interface DetailViewController : UIViewController <UIScrollViewDelegate, ADBannerViewDelegate>

@property (strong, nonatomic) NSString * mapName;
@property (strong, nonatomic) NSString * nadeType;
@property (nonatomic, strong) UIImageView * mapView;
@property (strong, nonatomic) NSDictionary * mapDetails;

@property BOOL debug;
@end
