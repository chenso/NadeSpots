//
//  DetailViewController.h
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "NadeSpot.h"
#import "NadeFromButton.h"
#import "NadeSpotButton.h"
#import <iAd/iAd.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#define BOTTOM_BAR_HEIGHT 40
#define VIDEO_INVERSE_ASPECT 0.5625
#define CHANNEL_PLUG_HEIGHT 40
#define IADBANNER_HEIGHT 50
#define NADE_BUTTON_DIM 45
#define PLAYER_BUTTON_DIM 35

@interface DetailViewController : UIViewController <UIScrollViewDelegate, ADBannerViewDelegate>

@property (strong, nonatomic) NSString * mapName;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *mapView;
@property (strong, nonatomic) NSDictionary * mapDetails;
@property (strong, nonatomic) NSString * nadeType;
@property (strong, nonatomic) NSMutableArray * nadeSpotButtons;
@property (strong, nonatomic) NSMutableArray * nadeFromButtons;
@property (strong, nonatomic) NSMutableArray * nadeTypeButtons;
@property (strong, nonatomic) UIView * videoView;
@property (strong, nonatomic) MPMoviePlayerController * videoPlayer;
@property (strong, nonatomic) UIButton * transparentPlayerExiterButton;
@property (strong, nonatomic) NadeSpotButton * currentlySelectedSpot;
@property (strong, nonatomic) UIView * nadesBottomBar;
@property (strong, nonatomic) UIButton * channelName;
@property (strong, nonatomic) UIButton * channelLogo;
@property (strong, nonatomic) NSFileManager * NSFM;
@property (strong, nonatomic) ADBannerView * adView;
@property BOOL debug;

@property bool scrollAvailable;
- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end
