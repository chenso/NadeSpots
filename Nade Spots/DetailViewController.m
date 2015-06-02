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

@implementation DetailViewController
@synthesize mapName;
@synthesize mapDetails;
@synthesize debug;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.NSFM = [[NSFileManager alloc] init];
    
    //initialize arrays
    self.nadeSpotButtons = [[NSMutableArray alloc] initWithCapacity:20]; // increase when more are added
    self.nadeFromButtons = [[NSMutableArray alloc] initWithCapacity:5];
    self.nadeTypeButtons = [[NSMutableArray alloc] initWithCapacity:2];
    
    // load the map view and nade destination view
    UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", mapName]];
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
    self.scrollAvailable = self.scrollView.minimumZoomScale <= self.scrollView.maximumZoomScale;
    
    self.scrollView.delegate = self;
    [self.scrollView setBackgroundColor:[UIColor blackColor]];
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
    self.nadesBottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] applicationFrame].size.height - (BOTTOM_BAR_HEIGHT + self.navigationController.navigationBar.frame.size.height), [[UIScreen mainScreen] applicationFrame].size.width, 40)];
    [self.nadesBottomBar setBackgroundColor:[[UIColor colorWithRed:0.937f green:0.325f blue:0.314f alpha:1.0f] colorWithAlphaComponent:0.4f]];
    
    [self.view addSubview:self.nadesBottomBar];
    NSArray * nadeTypes = @[@"Smokes", @"Flashes", @"HEMolotov"];
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.nadesBottomBar.bounds;
    
    [self.nadesBottomBar addSubview:effectView];
    
    for (int i = 0; i < nadeTypes.count; i++) {
        [self createNadeTypeSelectorButtonsForType:[nadeTypes objectAtIndex:i] atIndex:i numberTypes:(int)nadeTypes.count];
    }
    
    // Default nades are smokes
    UIButton * defaultSelection =[self.nadeTypeButtons objectAtIndex:0];
    self.nadeType = [NSMutableString stringWithFormat:@"%@", [defaultSelection titleForState:UIControlStateNormal]];
    defaultSelection.selected = YES;
    
    [self loadNades];
    
    // initialize video player view
    CGRect videoViewframe = [self videoViewScale];
    self.videoView = [[UIView alloc] initWithFrame:videoViewframe];
    self.videoView.backgroundColor = [UIColor clearColor];
    self.videoView.hidden = true;
    [self.view addSubview:self.videoView];
    
    // add channel link and graphic to video player view
    UILabel * video_by = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.videoView.frame.size.width / 3, CHANNEL_PLUG_HEIGHT)];
    [video_by setText:@"video source:"];
    [video_by setFont:[UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:15]];
    [video_by setBackgroundColor:[UIColor whiteColor]];
    [video_by setTextAlignment:NSTextAlignmentCenter];
    video_by.layer.shadowColor = [UIColor blackColor].CGColor;
    video_by.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    video_by.layer.shadowRadius = 5.5f;
    video_by.layer.shadowOpacity = 0.2f;
    video_by.adjustsFontSizeToFitWidth = YES;
    [self.videoView addSubview:video_by];
    
    self.channelName = [[UIButton alloc] initWithFrame:CGRectMake(self.videoView.frame.size.width / 3, 0, self.videoView.frame.size.width * 2 / 3, CHANNEL_PLUG_HEIGHT)];
    [self.channelName.titleLabel setTextAlignment:NSTextAlignmentRight];
    [self.channelName setBackgroundColor:[UIColor colorWithRed:0.803f green:0.125f blue:0.122f alpha:1.0f]];
    [self.channelName.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]];
    [self.channelName.titleLabel setTextColor:[UIColor whiteColor]];
    
    [self.channelName addTarget:self action:@selector(openYT) forControlEvents:UIControlEventTouchUpInside];
    
    self.channelName.titleLabel.shadowColor = [UIColor colorWithRed:0.702f green:0.071f blue:0.09f alpha:1.0f];
    self.channelName.titleLabel.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    self.channelName.titleLabel.layer.shadowRadius = 1.3f;
    self.channelName.titleLabel.layer.shadowOpacity = 0.5f;
    self.channelName.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.videoView addSubview:self.channelName];
    
    self.channelLogo = [[UIButton alloc] initWithFrame:CGRectMake(self.videoView.frame.size.width / 3 - CHANNEL_PLUG_HEIGHT /3, CHANNEL_PLUG_HEIGHT / 6, CHANNEL_PLUG_HEIGHT * 5 / 6, CHANNEL_PLUG_HEIGHT * 5 / 6)];
    
    [self.channelLogo addTarget:self action:@selector(openYT) forControlEvents:UIControlEventTouchUpInside];
    self.channelLogo.layer.shadowColor = [UIColor colorWithRed:0.702f green:0.071f blue:0.09f alpha:1.0f].CGColor;
    self.channelLogo.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.channelLogo.layer.shadowRadius = 1.5f;
    self.channelLogo.layer.shadowOpacity = 0.8f;
    
    [self.videoView addSubview:self.channelLogo];
    
    // create transparent button on superview for removing the video player view
    self.transparentPlayerExiterButton = [[UIButton alloc] initWithFrame:self.scrollView.bounds];
    self.transparentPlayerExiterButton.backgroundColor = [UIColor blackColor];
    self.transparentPlayerExiterButton.alpha = 0.0f;
    [self.transparentPlayerExiterButton addTarget:self action:@selector(dismissVideoPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.transparentPlayerExiterButton];
    
    self.transparentPlayerExiterButton.hidden = true;
    if (!self.scrollAvailable) {
        self.mapView.center = self.view.center;
    } else {
        CGFloat centerx = self.mapView.center.x;
        CGFloat centery = self.mapView.center.y;
        CGFloat leftCornerx = centerx - self.view.frame.size.width / 2;
        CGFloat leftCornery = centery - self.view.frame.size.height / 2;
        [self.scrollView setContentOffset:CGPointMake(leftCornerx, leftCornery) animated:NO];
    }
}
 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGRect) videoViewScale {
    CGRect frame;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGFloat videoWidth, videoHeight;
    
    if (UIDeviceOrientationIsPortrait(orientation)) {
        videoWidth = [[UIScreen mainScreen] bounds].size.width;
    } else {
        videoWidth = [[UIScreen mainScreen] bounds].size.width - 250.0;
    }
    
    videoHeight = videoWidth * VIDEO_INVERSE_ASPECT + CHANNEL_PLUG_HEIGHT;
    
    CGFloat videoWidthMargin = ([[UIScreen mainScreen] bounds].size.width - videoWidth ) / 2.0;
    CGFloat videoHeightTopMargin = ([[UIScreen mainScreen] bounds].size.height - (videoHeight + self.navigationController.navigationBar.frame.size.height)) / 3.0;
    frame = CGRectMake(videoWidthMargin, videoHeightTopMargin, videoWidth, videoHeight);
    return frame;
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
    [self.nadesBottomBar addSubview:nadeTypeButton];
    [self.nadeTypeButtons addObject:nadeTypeButton];
}

- (void) openYT {
    if ([self.channelName.titleLabel.text isEqualToString:@"Jamiew_"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/c/jamiew"]];
    } else if ([self.channelName.titleLabel.text isEqualToString:@"TrilluXe"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/TrilluXe"]];
    }
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
                NadeFrom * originSpot = [[NadeFrom alloc] initWithPath:anOrigin[@"path"] xCord:[anOrigin[@"xCord"] floatValue] yCord:[anOrigin[@"yCord"] floatValue] video_creator:anOrigin[@"creator"]];
                [origins addObject:originSpot];
            }
        }
        
        // create button for the spot
        NadeSpot * aSpot = [[NadeSpot alloc] initWithX:[destination[@"xCord"] floatValue] Y:[destination[@"yCord"] floatValue]fromLocations:origins];
        CGRect buttonLocation = CGRectMake(aSpot.xCord, aSpot.yCord, NADE_BUTTON_DIM, NADE_BUTTON_DIM);
        NadeSpotButton * nadeButton = [[NadeSpotButton alloc] initWithFrame:buttonLocation NadeType:self.nadeType];
        nadeButton.exclusiveTouch = YES;
        [nadeButton addTarget:self action:@selector(nadeDestButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        nadeButton.nadeFromSpots = aSpot.nadeFrom;
        nadeButton.alpha = 0.0;
        
        //animate button appear
        [UIView animateWithDuration:1.0 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            nadeButton.alpha = 0.8;
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

-(void)nadeDestButtonTouchUp:(id)sender {
    NadeSpotButton * myButton = (NadeSpotButton *) sender;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if (self.currentlySelectedSpot == myButton) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        return;
    }
    // remove previous NadeFrom buttons

    [self clearNadeFrom];
    
    // prepare zoom and scroll to fit relevant buttons
    CGFloat leftmost = myButton.frame.origin.x;
    CGFloat rightmost = leftmost + myButton.frame.size.width;
    CGFloat topmost = myButton.frame.origin.y;
    CGFloat botmost = topmost + myButton.frame.size.height;

    for (NadeFrom * aSpot in myButton.nadeFromSpots) {
        // check button location to determine scoll edges
        rightmost = rightmost > aSpot.xCord ? rightmost : aSpot.xCord;
        leftmost = leftmost < aSpot.xCord ? leftmost : aSpot.xCord;
        topmost = topmost < aSpot.yCord ? topmost : aSpot.yCord;
        botmost = botmost > aSpot.yCord ? botmost : aSpot.yCord;
        
        // make NadeFromButtons for destination button
        CGRect buttonLocation = CGRectMake(aSpot.xCord, aSpot.yCord, PLAYER_BUTTON_DIM, PLAYER_BUTTON_DIM);
        NadeFromButton * nadeFromButton = [[NadeFromButton alloc] initWithPath:aSpot.path video_creator:aSpot.video_creator];
        nadeFromButton.frame = buttonLocation;
        [nadeFromButton addTarget:self action:@selector(nadeOriginButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];

        CGAffineTransform trans = CGAffineTransformScale(nadeFromButton.transform, 0.01, 0.01);
        nadeFromButton.transform = trans;
        [self.mapView addSubview:nadeFromButton];
        [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        nadeFromButton.transform = CGAffineTransformScale(nadeFromButton.transform, 100.0, 100.0);
        } completion:nil];
        
        [self.nadeFromButtons addObject:nadeFromButton];
    }
    if (self.debug) {
        NSLog(@"Leftmost: %f, Rightmost: %f, Topmost: %f, Botmost: %f", leftmost, rightmost, topmost, botmost);
    }
    
    // scroll to relevant area
    //TODO
    if (self.scrollAvailable) {
        leftmost -= PLAYER_BUTTON_DIM;
        rightmost += PLAYER_BUTTON_DIM;
        CGFloat width = rightmost - leftmost;
        CGFloat height = (botmost - topmost) +BOTTOM_BAR_HEIGHT + 2 * PLAYER_BUTTON_DIM;
        CGRect relevantNadesBox = CGRectMake(leftmost, topmost, width, height);
        [self.scrollView zoomToRect:relevantNadesBox animated:YES];
    }
    
    // switch other NadeSpotButtons to deselected image

    for (NadeSpotButton * buttonToDeselect in self.nadeSpotButtons){
        buttonToDeselect.selected = buttonToDeselect == myButton;
    }
    self.currentlySelectedSpot = myButton;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

}

// Play video on nade from dest to origin
-(void)nadeOriginButtonTouchUp:(id)sender {
    NadeFromButton * button = (NadeFromButton *)sender;
    [self.channelName setTitle:button.video_creator forState:UIControlStateNormal];
    [self awakeVideoPlayerWithVideoPath:button.path fromCreator:button.video_creator];
    
   }

-(void)awakeVideoPlayerWithVideoPath:(NSString *) filename fromCreator:(NSString *) video_creator{
    NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp4"];
    NSURL * videoURL;
    @try {
        videoURL = [NSURL fileURLWithPath:path];
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to locate file for filename %@", filename);
        return;
    }
    self.adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 0, 0)];
    [self.adView setDelegate:self];
    [self.adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    self.adView.hidden = YES;
    [self.view addSubview:self.adView];
    
    //self.adView.frame  = CGRectOffset(self.adView.frame, 0, );
    NSString * logoName = [video_creator stringByAppendingString:@"_logo"];
    [self.channelLogo setImage:[UIImage imageNamed:logoName] forState:UIControlStateNormal];
    self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    self.videoPlayer.controlStyle = MPMovieControlStyleDefault;
    [[self.videoPlayer view] setFrame:CGRectMake(0, CHANNEL_PLUG_HEIGHT, self.videoView.frame.size.width, self.videoView.frame.size.height - CHANNEL_PLUG_HEIGHT)];
    [self.videoView addSubview:self.videoPlayer.view];
    [self.videoPlayer play];
    self.videoView.hidden = false;
    self.transparentPlayerExiterButton.hidden = false;
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transparentPlayerExiterButton.alpha = 0.4f;
                         self.nadesBottomBar.frame = CGRectOffset(self.nadesBottomBar.frame, 0, BOTTOM_BAR_HEIGHT);
                     }
                     completion:nil];
}

-(void) dismissVideoPlayer:(UIButton *) sender{
    [self.videoPlayer stop];
    self.videoView.hidden = YES;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.adView.frame = CGRectOffset(self.adView.frame, 0, self.adView.frame.size.height);
                         [self.adView removeFromSuperview];
                         self.adView = 0;
                         sender.alpha = 0.0f;
                         self.nadesBottomBar.frame = CGRectOffset(self.nadesBottomBar.frame, 0, -BOTTOM_BAR_HEIGHT);
                     }
                     completion:^(BOOL finished){
                         sender.hidden = YES;
                     }
     ];
    
    
}

-(void) clearNadeFrom {
    [self clearButtonArray:self.nadeFromButtons];
}

-(void) clearNadeSpots {
    [self clearButtonArray:self.nadeSpotButtons];
}

-(void) clearButtonArray:(NSMutableArray *) nadeButtons {
    for (UIButton * buttonToRemove in nadeButtons) {
        [UIView animateWithDuration:0.4 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            buttonToRemove.transform = CGAffineTransformScale(buttonToRemove.transform, 0.01, 0.01);
        } completion:nil];
        [buttonToRemove removeFromSuperview];
    }
    [nadeButtons removeAllObjects];
}

#pragma mark - ADBannerViewDelegate
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"banner loaded");
    
    // Display BannerView
    self.adView.hidden = NO;
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.adView.frame = CGRectOffset(self.adView.frame, 0, -self.adView.frame.size.height);
                     }];
}

#pragma mark - UIGestureHandling

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mapView;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    if (self.scrollView.minimumZoomScale >= self.scrollView.maximumZoomScale) return;
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

/*
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (self.adView) {
        if (self.adView.isBannerLoaded) {
            self.adView.frame = CGRectMake(0, self.view.frame.size.height - self.adView.frame.size.height, 0, 0);
        } else {
            
        }
    }
    NSUInteger nadeTypeCount = self.nadeTypeButtons.count;
    CGFloat screen_height = [[UIScreen mainScreen] applicationFrame].size.height - self.navigationController.navigationBar.frame.size.height;
    CGFloat bottom_bar_y_height = self.videoView.hidden ? screen_height - BOTTOM_BAR_HEIGHT : screen_height;
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.nadesBottomBar.frame = CGRectMake(0, bottom_bar_y_height, [[UIScreen mainScreen] bounds].size.width, BOTTOM_BAR_HEIGHT);
                         for (int i = 0; i < nadeTypeCount; i++) {
                             [[self.nadeTypeButtons objectAtIndex:i] setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width * (i + 1) / (nadeTypeCount + 1), BOTTOM_BAR_HEIGHT / 2)];
                         }
                     }
                     completion:nil
     ];
    
    if (self.scrollView.minimumZoomScale >= self.scrollView.maximumZoomScale) {
        self.mapView.center = self.view.center;
    }
    self.videoView.frame = [self videoViewScale];
    self.channelName.frame = CGRectMake(self.videoView.frame.size.width / 3, 0, self.videoView.frame.size.width * 2 / 3, CHANNEL_PLUG_HEIGHT);
    [[self.videoPlayer view] setFrame:CGRectMake(0, CHANNEL_PLUG_HEIGHT, self.videoView.frame.size.width, self.videoView.frame.size.height - CHANNEL_PLUG_HEIGHT)];
}
*/

@end
