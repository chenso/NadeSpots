//
//  DetailViewController.m
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "DetailViewController.h"


#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

@interface DetailViewController ()

@property (strong, nonatomic) NSString * nadeType;
@property (strong, nonatomic) NSMutableArray * nadeSpotButtons;
@property (strong, nonatomic) NSMutableArray * nadeFromButtons;
@property (strong, nonatomic) NSMutableArray * nadeTypeButtons;
@property (strong, nonatomic) UIView * videoView;
@property (strong, nonatomic) MPMoviePlayerController * videoPlayer;
@property (strong, nonatomic) UIButton * transparentPlayerExiterButton;
@property (strong, nonatomic) NadeSpotButton * currentlySelectedSpot;
@property (strong, nonatomic) UIButton * smokesButton;
@property (strong, nonatomic) UIButton * flashesButton;

@end

@implementation DetailViewController
@synthesize mapName;
@synthesize mapDetails;
@synthesize nadeFromButtons;
@synthesize videoView;
@synthesize nadeType = _nadeType;
@synthesize scrollView = _scrollView;
@synthesize mapView = _mapView;
@synthesize nadeSpotButtons;
@synthesize nadeTypeButtons;
@synthesize videoPlayer;
@synthesize transparentPlayerExiterButton;
@synthesize currentlySelectedSpot;
@synthesize smokesButton = _smokesButton;
@synthesize flashesButton = _flashesButton;

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mapView;
}

// remove for 436 submission
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    CGPoint pointInView = [recognizer locationInView:self.mapView];
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

// remove for 436 submission
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.mapView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.mapView.frame = contentsFrame;
}

- (void) openJWYT {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/c/jamiew"]];
}

-(void) clearNadeFrom {
    for (NadeFromButton * buttonToRemove in nadeFromButtons) {
        [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            buttonToRemove.transform = CGAffineTransformScale(buttonToRemove.transform, 0.01, 0.01);
        } completion:nil];
        [buttonToRemove removeFromSuperview];
    }
}

-(void) clearNadeSpots {
    for (NadeSpotButton * buttonToRemove in nadeSpotButtons) {
        [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            buttonToRemove.transform = CGAffineTransformScale(buttonToRemove.transform, 0.01, 0.01);
        } completion:nil];
        [buttonToRemove removeFromSuperview];
    }
    [nadeSpotButtons removeAllObjects];
}

// load nades of type
-(void) loadNades {
    // remove previous Nade buttons
    [self clearNadeSpots];
    [self clearNadeFrom];
    NSDictionary * nades = [mapDetails objectForKey:self.nadeType];
    
    for (id key in nades) {
        // load all Nade Spots with destination and origins
        NSDictionary * destination = [nades objectForKey:key];
        NSMutableArray * origins = [[NSMutableArray alloc] initWithCapacity:1];
        for (id key in destination) {
            if (![key isEqualToString:@"xCord"] && ![key isEqualToString:@"yCord"]) {
                // add all origins to single destination spot
                NSDictionary * anOrigin = [destination objectForKey:key];
                NadeFrom * originSpot = [[NadeFrom alloc] initWithPath:anOrigin[@"path"] xCord:[anOrigin[@"xCord"] floatValue] yCord:[anOrigin[@"yCord"] floatValue]];
                [origins addObject:originSpot];
            }
        }
        
        // create button for the spot
        NadeSpot * aSpot = [[NadeSpot alloc] initWithX:[destination[@"xCord"] floatValue] Y:[destination[@"yCord"] floatValue]fromLocations:origins];
        CGRect buttonLocation = CGRectMake(aSpot.xCord, aSpot.yCord, 55, 55);
        NadeSpotButton * nadeButton;
        if ([self.nadeType isEqualToString:@"Smokes"]) {
            nadeButton = [[SmokeSpotButton alloc] initWithFrame:buttonLocation];
        } else {
            nadeButton = [[FlashSpotButton alloc] initWithFrame:buttonLocation];
        }
        nadeButton.exclusiveTouch = YES;
        [nadeButton addTarget:self action:@selector(nadeDestButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        nadeButton.nadeFromSpots = aSpot.nadeFrom;
        nadeButton.alpha = 0.0;
        
        //animate button appear
        [UIView animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            nadeButton.alpha = 1.0;
        } completion:nil];
        
        [self.mapView addSubview:nadeButton];
        [self.nadeSpotButtons addObject:nadeButton];
        
    }
}

-(void)selectNadeType:(id)sender {
    UIButton * type = (UIButton *) sender;
    self.nadeType = [type titleForState:UIControlStateNormal];
    for (UIButton * types in self.nadeTypeButtons) {
        types.selected = types == type;
    }
    [self loadNades];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // jamiew yt channel nav bar link
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"navJWButton.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openJWYT) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 243, 32)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    //initialize arrays
    self.nadeSpotButtons = [[NSMutableArray alloc] initWithCapacity:20]; // increase when more are added
    self.nadeFromButtons = [[NSMutableArray alloc] initWithCapacity:5];
    self.nadeTypeButtons = [[NSMutableArray alloc] initWithCapacity:2];
    // load the map view and nade destination view
    UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", mapName]];
    self.mapView = [[UIImageView alloc] initWithImage:image];
    self.mapView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size = image.size};
    self.mapView.userInteractionEnabled = YES;
    self.mapView.exclusiveTouch = YES;
    [self.scrollView addSubview:self.mapView];
    // initial and minimum zoom fill screen by x-axis
    [self.scrollView setContentSize:image.size];
    self.scrollView.frame = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    self.scrollView.minimumZoomScale = [[UIScreen mainScreen] bounds].size.width / image.size.width;
    self.scrollView.maximumZoomScale = 1.0;
    self.scrollView.delegate = self;
    [self.scrollView setBackgroundColor:[UIColor blackColor] ];
    self.scrollView.canCancelContentTouches = YES;
    self.scrollView.delaysContentTouches = YES;
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    // initialize showSmokes and showFlashes buttons
    UIView * bar = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 40 , [[UIScreen mainScreen] bounds].size.width, 40)];
    [bar setBackgroundColor:[UIColor whiteColor]];
    [bar setAlpha:0.2];
    [self.view addSubview:bar];
    self.smokesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [self.smokesButton setTitle:@"Smokes" forState:UIControlStateNormal];
    [self.smokesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.smokesButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.smokesButton setTitleColor:[UIColor colorWithRed:188/255.0f green:255/255.0f blue:81/255.0f alpha:1.0f] forState:UIControlStateSelected];
    [self.smokesButton setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width / 3, [[UIScreen mainScreen]bounds].size.height - 20)];
    [self.smokesButton addTarget:self action:@selector(selectNadeType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.smokesButton];
    [self.nadeTypeButtons addObject:self.smokesButton];
    
    
    self.flashesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    [self.flashesButton setTitle:@"Flashes" forState:UIControlStateNormal];
    [self.flashesButton setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width * 2 / 3, [[UIScreen mainScreen]bounds].size.height - 20)];
    [self.flashesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.flashesButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.flashesButton setTitleColor:[UIColor colorWithRed:188/255.0f green:255/255.0f blue:81/255.0f alpha:1.0f] forState:UIControlStateSelected];
    [self.flashesButton addTarget:self action:@selector(selectNadeType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashesButton];
    [self.nadeTypeButtons addObject:self.flashesButton];
    // Default nades are smokes
    
    self.nadeType = [NSMutableString stringWithFormat:@"Smokes"];
    self.smokesButton.selected = YES;
    [self loadNades];
    
    // initialize video player view
    CGRect frame = [self videoViewScale];
    self.videoView = [[UIView alloc] initWithFrame:frame];
    self.videoView.backgroundColor = [UIColor blackColor];
    self.videoView.hidden = true;
    [self.view addSubview:videoView];
    
    // create transparent button on superview for removing the video player view
    transparentPlayerExiterButton = [[UIButton alloc] initWithFrame:self.scrollView.bounds];
    transparentPlayerExiterButton.backgroundColor = [UIColor clearColor];
    [transparentPlayerExiterButton addTarget:self action:@selector(dismissPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:transparentPlayerExiterButton];
    transparentPlayerExiterButton.hidden = true;
}

-(void)nadeDestButtonTouchUp:(id)sender {
    NadeSpotButton * myButton = (NadeSpotButton *) sender;
    if (currentlySelectedSpot == myButton) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        return;
    }
    // remove previous NadeFrom buttons

    [self clearNadeFrom];
    [nadeFromButtons removeAllObjects];
    
    // prepare zoom and scroll to fit relevant buttons
    CGFloat rightmost = myButton.frame.origin.x;
    CGFloat leftmost = rightmost;
    CGFloat topmost = myButton.frame.origin.y;
    CGFloat botmost = topmost;

    for (NadeFrom * aSpot in myButton.nadeFromSpots) {
        // check button location to determine scoll edges
        rightmost = rightmost > aSpot.xCord ? rightmost : aSpot.xCord;
        leftmost = leftmost < aSpot.xCord ? leftmost : aSpot.xCord;
        topmost = topmost < aSpot.yCord ? topmost : aSpot.yCord;
        botmost = botmost > aSpot.yCord ? botmost : aSpot.yCord;
        
        // make NadeFromButtons for destination button
        CGRect buttonLocation = CGRectMake(aSpot.xCord, aSpot.yCord, 45, 45);
        NadeFromButton * nadeFromButton = [[NadeFromButton alloc] initWithPath:aSpot.path];
        nadeFromButton.frame = buttonLocation;
        [nadeFromButton addTarget:self action:@selector(nadeOriginButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];

        CGAffineTransform trans = CGAffineTransformScale(nadeFromButton.transform, 0.01, 0.01);
        nadeFromButton.transform = trans;
        [self.mapView addSubview:nadeFromButton];
        [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        nadeFromButton.transform = CGAffineTransformScale(nadeFromButton.transform, 100.0, 100.0);
        } completion:nil];
        
        [nadeFromButtons addObject:nadeFromButton];
    }
    
    // scroll to relevant area
    //TODO
    
    // switch other NadeSpotButtons to deselected image

    for (NadeSpotButton * buttonToDeselect in self.nadeSpotButtons){
        if (buttonToDeselect != myButton) {
            [buttonToDeselect deselect];
        } else {
            [buttonToDeselect defaultImage];
        }
    }
    currentlySelectedSpot = myButton;

}

// Play video on nade from dest to origin
-(void)nadeOriginButtonTouchUp:(id)sender {
    NadeFromButton * button = (NadeFromButton *)sender;
    NSString * path = [[NSBundle mainBundle] pathForResource:button.path ofType:@"mp4"];
    NSURL *videoURL = [NSURL fileURLWithPath:path];
    videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    videoPlayer.controlStyle = MPMovieControlStyleDefault;
    [[videoPlayer view] setFrame:[self.videoView bounds]];
    [self.videoView addSubview:videoPlayer.view];
    [videoPlayer play];
    self.videoView.hidden = false;
    transparentPlayerExiterButton.hidden = false;
    
}

-(void)dismissPlayer:(UIButton *) sender{
    [self.videoPlayer stop];
    self.videoView.hidden = YES;
    sender.hidden = YES;
}

-(CGRect) videoViewScale {
    CGRect frame;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGFloat videoWidth, videoHeight;
    if (UIDeviceOrientationIsPortrait(orientation)) {
        videoWidth = [[UIScreen mainScreen] bounds].size.width - 40.0;
        
    } else {
        videoWidth = [[UIScreen mainScreen] bounds].size.width - 100.0;
    }
    videoHeight = videoWidth * 0.5625;
    CGFloat videoWidthMargin = ([[UIScreen mainScreen] bounds].size.width - videoWidth ) / 2.0;
    CGFloat videoHeightMargin = ([[UIScreen mainScreen] bounds].size.height - videoHeight ) / 2.0 ;
    frame = CGRectMake(videoWidthMargin, videoHeightMargin, videoWidth, videoHeight);
    return frame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
