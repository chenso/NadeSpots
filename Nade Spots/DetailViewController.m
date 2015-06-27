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

@implementation DetailViewController {
    NSFileManager * NSFM;
    UIView * bottomBar;
    ADBannerView * adView;
    NSMutableArray * nadeSpotButtons;
    NSMutableArray * nadeFromButtons;
    NSMutableArray * nadeTypeButtons;
    NadeSpotButton * currentlySelectedSpot;
    IBOutlet UIScrollView * scrollView;
    IBOutlet UIButton * transparentPlayerExiterButton;
    IBOutlet VideoView * videoView;
    IBOutlet UIView * channelBar;
    IBOutlet UILabel * byLabel;
    IBOutlet UIButton * channelName;
    IBOutlet UIButton * channelLogo;
    UIImageView * mapView;
}

@synthesize mapName;
@synthesize mapDetails;
@synthesize debug;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray * nadeTypes = @[@"Smokes", @"Flashes", @"HEMolotov"];   
    NSFM = [[NSFileManager alloc] init];
    channelBar.hidden = YES;
    videoView.hidden = YES;
    //initialize arrays
    nadeSpotButtons = [[NSMutableArray alloc] initWithCapacity:20]; // increase when more are added
    nadeFromButtons = [[NSMutableArray alloc] initWithCapacity:5];
    nadeTypeButtons = [[NSMutableArray alloc] initWithCapacity:3];
    
    // load the map view and nade destination view
    UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", mapName]];
    mapView = [[UIImageView alloc] initWithImage:image];
    mapView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size = image.size};
    mapView.userInteractionEnabled = YES;
    mapView.exclusiveTouch = YES;
    [scrollView addSubview:mapView];
    
    // initial and minimum zoom fill screen by x-axis
    [scrollView setContentSize:image.size];
    scrollView.minimumZoomScale = [self.view bounds].size.width / image.size.width;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        scrollView.maximumZoomScale = 1.0f;
    } else {
        scrollView.maximumZoomScale = 1.5f;
    }
    if (self.debug) {
        NSLog(@"minscale: %f, maxscale: %f", scrollView.minimumZoomScale, scrollView.maximumZoomScale);
    }
    scrollView.delegate = self;
    [scrollView setBackgroundColor:[UIColor blackColor]];
    scrollView.canCancelContentTouches = YES;
    scrollView.delaysContentTouches = YES;
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [scrollView addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [scrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    // initialize showSmokes and showFlashes buttons
    bottomBar = [[UIView alloc] initWithFrame: CGRectMake(0, [[UIScreen mainScreen] applicationFrame].size.height - BOTTOM_BAR_HEIGHT - self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, BOTTOM_BAR_HEIGHT)];
    // create effect
    [bottomBar setBackgroundColor:[[UIColor colorWithRed:0.937f green:0.325f blue:0.314f alpha:1.0f] colorWithAlphaComponent:0.4f]];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = CGRectMake(0, 0, MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width), BOTTOM_BAR_HEIGHT);
    
    [bottomBar addSubview:effectView];
    for (int i = 0; i < nadeTypes.count; i++) {
        [self createNadeTypeSelectorButtonsForType:[nadeTypes objectAtIndex:i] atIndex:i numberTypes:(int)nadeTypes.count];
    }
    [self.view addSubview:bottomBar];
    // Default nades are smokes
    UIButton * defaultSelection =[nadeTypeButtons objectAtIndex:0];
    self.nadeType = [NSMutableString stringWithFormat:@"%@", [defaultSelection titleForState:UIControlStateNormal]];
    defaultSelection.selected = YES;
    
    [self loadNades];
    
    // create transparent button on superview for removing the video player view
    //transparentPlayerExiterButton = [[UIButton alloc] initWithFrame:scrollView.bounds];
    transparentPlayerExiterButton.backgroundColor = [UIColor blackColor];
    transparentPlayerExiterButton.alpha = 0.0f;
    [transparentPlayerExiterButton addTarget:self action:@selector(dismissVideoPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:transparentPlayerExiterButton];
    
    transparentPlayerExiterButton.hidden = true;
    scrollView.zoomScale = scrollView.maximumZoomScale;
    CGFloat centerx = mapView.center.x;
    CGFloat centery = mapView.center.y;
    CGFloat leftCornerx = centerx - self.view.frame.size.width / 2;
    CGFloat leftCornery = centery - self.view.frame.size.height / 2;
    NSLog(@"%f, %f", leftCornerx, leftCornery);
    [scrollView setContentOffset:CGPointMake(leftCornerx, leftCornery) animated:NO];
    [self.view bringSubviewToFront:transparentPlayerExiterButton];
    [self.view bringSubviewToFront:bottomBar];
    for (UIButton * nadeTypeButton in nadeTypeButtons) {
        nadeTypeButton.userInteractionEnabled = YES;
        [bottomBar bringSubviewToFront:nadeTypeButton];
    }
    bottomBar.userInteractionEnabled = YES;
    
    [byLabel setText:@"video source:"];
    [byLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:15]];
    [byLabel setTextAlignment:NSTextAlignmentCenter];
    
    [channelName.titleLabel setTextAlignment:NSTextAlignmentRight];
    [channelName.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]];
    
    [channelName addTarget:self action:@selector(openYT) forControlEvents:UIControlEventTouchUpInside];
}

 - (void) openYT {
 if ([channelName.titleLabel.text isEqualToString:@"Jamiew_"]) {
 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/c/jamiew"]];
 } else if ([channelName.titleLabel.text isEqualToString:@"TrilluXe"]) {
 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/TrilluXe"]];
 }
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createNadeTypeSelectorButtonsForType:(NSString *) nadeType atIndex:(int) index numberTypes:(int) totalTypeAmount {
    UIButton * nadeTypeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, BOTTOM_BAR_HEIGHT, BOTTOM_BAR_HEIGHT)];
    NSMutableString * deselected_path = [NSMutableString stringWithFormat: @"small_icon_deselected_"];
    [nadeTypeButton setImage:[UIImage imageNamed:[deselected_path stringByAppendingString:nadeType]] forState:UIControlStateNormal];
    
    NSMutableString * selected_path = [NSMutableString stringWithFormat: @"small_icon_selected_"];
    [nadeTypeButton setImage:[UIImage imageNamed:[selected_path stringByAppendingString:nadeType]] forState:UIControlStateSelected];
    [nadeTypeButton setTitle:nadeType forState:UIControlStateNormal];
    [nadeTypeButton setCenter:CGPointMake([[UIScreen mainScreen] applicationFrame].size.width * (index + 1) / (totalTypeAmount + 1), BOTTOM_BAR_HEIGHT / 2)];
    [nadeTypeButton addTarget:self action:@selector(selectNadeType:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBar addSubview:nadeTypeButton];
    [nadeTypeButtons addObject:nadeTypeButton];
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
                CGRect buttonLocation = CGRectMake([anOrigin[@"xCord"] floatValue], [anOrigin[@"yCord"] floatValue], PLAYER_BUTTON_DIM, PLAYER_BUTTON_DIM);
                NadeFromButton * nadeFromButton = [[NadeFromButton alloc] initWithFrame:buttonLocation path:anOrigin[@"path"] video_creator:anOrigin[@"creator"]];
                [nadeFromButton addTarget:self action:@selector(nadeOriginButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
                [origins addObject:nadeFromButton];
            }
        }
        
        // create button for the spot
        CGRect buttonLocation = CGRectMake([destination[@"xCord"] floatValue], [destination[@"yCord"] floatValue], NADE_BUTTON_DIM, NADE_BUTTON_DIM);
        NadeSpotButton * nadeButton = [[NadeSpotButton alloc] initWithFrame:buttonLocation NadeType:self.nadeType nadeFromSpots:origins];
        nadeButton.exclusiveTouch = YES;
        [nadeButton addTarget:self action:@selector(nadeDestButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        nadeButton.alpha = 0.0;
        
        //animate button appear
        [UIView animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            nadeButton.alpha = 0.8;
        } completion:nil];
        
        [mapView addSubview:nadeButton];
        [nadeSpotButtons addObject:nadeButton];
        
    }
}

-(void)selectNadeType:(id)sender {
    UIButton * type = (UIButton *) sender;
    self.nadeType = [type titleForState:UIControlStateNormal];
    for (UIButton * types in nadeTypeButtons) {
        types.selected = types == type;
    }
    [self loadNades];
}
-(void) clearNadeFrom {
    [self clearButtonArray:nadeFromButtons];
}

-(void) clearNadeSpots {
    [self clearButtonArray:nadeSpotButtons];
}

-(void) clearButtonArray:(NSMutableArray *) nadeButtons {
    for (UIButton * buttonToRemove in nadeButtons) {
        [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            buttonToRemove.alpha = 0.0f;
        } completion:nil];
        [buttonToRemove removeFromSuperview];
    }
    [nadeButtons removeAllObjects];
}

-(void)nadeDestButtonTouchUp:(id)sender {
    NadeSpotButton * myButton = (NadeSpotButton *) sender;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    // remove previous NadeFrom buttons

    [self clearNadeFrom];
    
    // prepare zoom and scroll to fit relevant buttons
    CGFloat leftmost = myButton.frame.origin.x;
    CGFloat rightmost = leftmost + myButton.frame.size.width;
    CGFloat topmost = myButton.frame.origin.y;
    CGFloat botmost = topmost + myButton.frame.size.height;

    for (NadeFromButton * nadeFromButton in myButton.nadeFromSpots) {
        // check button location to determine scoll edges
        rightmost = rightmost > nadeFromButton.frame.origin.x ? rightmost : nadeFromButton.frame.origin.x;
        leftmost = leftmost < nadeFromButton.frame.origin.x ? leftmost : nadeFromButton.frame.origin.x;
        topmost = topmost < nadeFromButton.frame.origin.y ? topmost : nadeFromButton.frame.origin.y;
        botmost = botmost > nadeFromButton.frame.origin.y ? botmost : nadeFromButton.frame.origin.y;
        
        nadeFromButton.alpha = 0.0f;
        
        // make NadeFromButtons for destination button
        [mapView addSubview:nadeFromButton];
        [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            nadeFromButton.alpha = 1.0f;
        } completion:nil];
        
        [nadeFromButtons addObject:nadeFromButton];
    }
    
    if (self.debug) {
        NSLog(@"Leftmost: %f, Rightmost: %f, Topmost: %f, Botmost: %f", leftmost, rightmost, topmost, botmost);
    }
    
    // scroll to relevant area
    leftmost -= PLAYER_BUTTON_DIM + 100;
    rightmost += PLAYER_BUTTON_DIM + 100;
    CGFloat width = rightmost - leftmost;
    CGFloat height = (botmost - topmost) +BOTTOM_BAR_HEIGHT + 2 * PLAYER_BUTTON_DIM + 250;
    CGRect relevantNadesBox = CGRectMake(leftmost, topmost, width, height);
    [scrollView zoomToRect:relevantNadesBox animated:YES];
    
    // switch other NadeSpotButtons to deselected image

    for (NadeSpotButton * buttonToDeselect in nadeSpotButtons){
        buttonToDeselect.selected = buttonToDeselect == myButton;
    }
    currentlySelectedSpot = myButton;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

}

// Play video on nade from dest to origin
-(void)nadeOriginButtonTouchUp:(id)sender {
    NadeFromButton * button = (NadeFromButton *)sender;
    [channelName setTitle:button.video_creator forState:UIControlStateNormal];
    NSString * logoName = [button.video_creator stringByAppendingString:@"_logo"];
    [channelLogo setImage:[UIImage imageNamed:logoName] forState:UIControlStateNormal];
    [videoView awakeVideoPlayerWithVideoPath:button.path fromCreator:button.video_creator];
    
    transparentPlayerExiterButton.hidden = false;
    videoView.hidden = NO;
    channelBar.hidden = NO;
    [self bringUpAdView];
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         transparentPlayerExiterButton.alpha = 0.4f;
                         bottomBar.frame = CGRectOffset(bottomBar.frame, 0, BOTTOM_BAR_HEIGHT);
                     }
                     completion:nil];
}

-(void) bringUpAdView {
    adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 0, 0)];
    adView.delegate = self;
    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    adView.hidden = YES;
    [self.view addSubview:adView];
}

-(void) bringDownAdView {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         adView.frame = CGRectOffset(adView.frame, 0, adView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [adView removeFromSuperview];
                         adView = 0;
                     }
     ];

}


-(void) dismissVideoPlayer:(UIButton *) sender{
    [videoView putVideoPlayerToSleep];
    channelBar.hidden = YES;
    videoView.hidden = YES;
    [self bringDownAdView];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         sender.alpha = 0.0f;
                         bottomBar.frame = CGRectOffset(bottomBar.frame, 0, -BOTTOM_BAR_HEIGHT);
                     }
                     completion:^(BOOL finished){
                         sender.hidden = YES;
                     }
     ];
    
    
}

#pragma mark - ADBannerViewDelegate
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (self.debug) NSLog(@"banner loaded");
    
    // Display BannerView
    adView.hidden = NO;
    [UIView animateWithDuration:0.4f
                     animations:^{
                         adView.frame = CGRectOffset(adView.frame, 0, -adView.frame.size.height);
                     }];
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    if (!willLeave) {
        [videoView pauseVideoPlayer];
    }
    return YES;
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner {
    [videoView playVideoPlayer];
}

-(void)bannerView:(ADBannerView *)aBanner didFailToReceiveAdWithError:(NSError *)error {
    if (!adView.hidden) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             adView.frame = CGRectOffset(adView.frame, 0, adView.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             [adView removeFromSuperview];
                             adView = 0;
                         }
         ];
    }
}

#pragma mark - UIGestureHandling

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return mapView;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    if (scrollView.minimumZoomScale >= scrollView.maximumZoomScale) return;
    CGPoint pointInView = [recognizer locationInView:mapView];
    CGFloat newZoomScale = scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, scrollView.maximumZoomScale);
    CGSize scrollViewSize = scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    [scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, scrollView.minimumZoomScale);
    [scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = mapView.frame;
    
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
    
    mapView.frame = contentsFrame;
}
/*
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
        if (videoView.hidden) {
            
        } else {
            [UIView animateWithDuration:duration animations:^{
                bottomBar.frame = CGRectOffset(bottomBar.frame, 0, BOTTOM_BAR_HEIGHT);
            } completion:^(BOOL completed) {
                NSLog(@"HI");
                bottomBar.hidden = YES;
            }];
        }
}
 
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationMaskPortrait) {
        scrollView.minimumZoomScale = [self.view bounds].size.width / 750;
    } else {
        scrollView.minimumZoomScale = [self.view bounds].size.height / 750;
    }
    if (adView) {
        if (adView.isBannerLoaded) {
            adView.frame = CGRectMake(0, self.view.frame.size.height - adView.frame.size.height, 0, 0);
        } else {
            
        }
    }
    NSUInteger nadeTypeCount = nadeTypeButtons.count;
    CGFloat screen_height = [[UIScreen mainScreen] applicationFrame].size.height - self.navigationController.navigationBar.frame.size.height;
    CGFloat bottom_bar_y_height = videoView.hidden ? screen_height - BOTTOM_BAR_HEIGHT : screen_height;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         bottomBar.frame = CGRectMake(0, bottom_bar_y_height, [[UIScreen mainScreen] bounds].size.width, BOTTOM_BAR_HEIGHT);
                         for (int i = 0; i < nadeTypeCount; i++) {
                             [[nadeTypeButtons objectAtIndex:i] setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width * (i + 1) / (nadeTypeCount + 1), BOTTOM_BAR_HEIGHT / 2)];
                         }
                     }
                     completion:nil
     ];
    
    if (scrollView.minimumZoomScale >= scrollView.maximumZoomScale) {
        mapView.center = self.view.center;
    }
    videoView.frame = [self videoViewScale];
    channelName.frame = CGRectMake(videoView.frame.size.width / 3, 0, videoView.frame.size.width * 2 / 3, CHANNEL_PLUG_HEIGHT);
    channelLogo.frame = [self getChannelLogoFrame];
    video_by.frame = CGRectMake(0, 0, videoView.frame.size.width / 3, CHANNEL_PLUG_HEIGHT);
    [[videoPlayer view] setFrame:CGRectMake(0, CHANNEL_PLUG_HEIGHT, videoView.frame.size.width, videoView.frame.size.height - CHANNEL_PLUG_HEIGHT)];
}*/

- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

@end
