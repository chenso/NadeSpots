//
//  DetailViewController.h
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "NadeSpot.h"
#import "SmokeSpotButton.h"
#import "NadeFromButton.h"
#import "FlashSpotButton.h"
#import <MediaPlayer/MediaPlayer.h>

@interface DetailViewController : UIViewController <UIScrollViewDelegate> 

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *mapView;
@property (strong, nonatomic) NSString * mapName;
@property (strong, nonatomic) NSDictionary * mapDetails;
@property (strong, nonatomic) NSString * nadeType;
@property (strong, nonatomic) NSMutableArray * nadeSpotButtons;
@property (strong, nonatomic) NSMutableArray * nadeFromButtons;
@property (strong, nonatomic) NSMutableArray * nadeTypeButtons;
@property (strong, nonatomic) UIView * videoView;
@property (strong, nonatomic) MPMoviePlayerController * videoPlayer;
@property (strong, nonatomic) UIButton * transparentPlayerExiterButton;
@property (strong, nonatomic) NadeSpotButton * currentlySelectedSpot;
@property (strong, nonatomic) UIButton * hemolotovButton;
@property (strong, nonatomic) UIButton * smokesButton;
@property (strong, nonatomic) UIButton * flashesButton;
@property bool scrollAvailable;
- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end
