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
@synthesize scrollAvailable;
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
@synthesize hemolotovButton = _hemolotovButton;

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
    scrollAvailable = self.scrollView.minimumZoomScale >= self.scrollView.maximumZoomScale;
    if (scrollAvailable) {
        self.mapView.center = self.view.center;
    }
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
    [bar setAlpha:0.5];
    [self.view addSubview:bar];
    NSArray * nadeTypes = @[@"Smokes", @"Flashes", @"HEMolotov"];
    
    for (int i = 0; i < nadeTypes.count; i++) {
        [self createNadeTypeSelectorButtonsForType:[nadeTypes objectAtIndex:i] atIndex:i numberTypes:(int)nadeTypes.count];
    }
    
    // Default nades are smokes
    UIButton * defaultSelection =[self.nadeTypeButtons objectAtIndex:0];
    self.nadeType = [NSMutableString stringWithFormat:@"%@", [defaultSelection titleForState:UIControlStateNormal]];
    defaultSelection.selected = YES;
    
    [self loadNades];
    
    // initialize video player view
    CGRect frame = [self videoViewScale];
    self.videoView = [[UIView alloc] initWithFrame:frame];
    self.videoView.backgroundColor = [UIColor blackColor];
    self.videoView.hidden = true;
    [self.view addSubview:videoView];
    
    // create transparent button on superview for removing the video player view
    transparentPlayerExiterButton = [[UIButton alloc] initWithFrame:self.scrollView.bounds];
    transparentPlayerExiterButton.backgroundColor = [UIColor blackColor];
    transparentPlayerExiterButton.alpha = 0.0f;
    [transparentPlayerExiterButton addTarget:self action:@selector(dismissPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:transparentPlayerExiterButton];
    transparentPlayerExiterButton.hidden = true;
}

-(void) createNadeTypeSelectorButtonsForType:(NSString *) nadeType atIndex:(int) index numberTypes:(int) totalTypeAmount {
    UIButton * nadeTypeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    NSMutableString * deselected_path = [NSMutableString stringWithFormat: @"small_icon_deselected_"];
    [nadeTypeButton setImage:[UIImage imageNamed:[deselected_path stringByAppendingString:nadeType]] forState:UIControlStateNormal];
    
    NSMutableString * selected_path = [NSMutableString stringWithFormat: @"small_icon_selected_"];
    [nadeTypeButton setImage:[UIImage imageNamed:[selected_path stringByAppendingString:nadeType]] forState:UIControlStateSelected];
    [nadeTypeButton setTitle:nadeType forState:UIControlStateNormal];
    [nadeTypeButton setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width * (index + 1) / (totalTypeAmount + 1), [[UIScreen mainScreen]bounds].size.height - 20)];
    [nadeTypeButton addTarget:self action:@selector(selectNadeType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nadeTypeButton];
    [self.nadeTypeButtons addObject:nadeTypeButton];
}

- (void) openJWYT {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/c/jamiew"]];
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
        CGRect buttonLocation = CGRectMake(aSpot.xCord, aSpot.yCord, 45, 45);
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
    if (currentlySelectedSpot == myButton) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        return;
    }
    // remove previous NadeFrom buttons

    [self clearNadeFrom];

    
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
        CGRect buttonLocation = CGRectMake(aSpot.xCord, aSpot.yCord, 35, 35);
        NadeFromButton * nadeFromButton = [[NadeFromButton alloc] initWithPath:aSpot.path video_creator:@"jamiew"];
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
    if (scrollAvailable) {
        
    }
    
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
    NSURL * videoURL = [NSURL fileURLWithPath:path];
    videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    videoPlayer.controlStyle = MPMovieControlStyleDefault;
    [[videoPlayer view] setFrame:[self.videoView bounds]];
    [self.videoView addSubview:videoPlayer.view];
    [videoPlayer play];
    self.videoView.hidden = false;
    transparentPlayerExiterButton.hidden = false;
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        transparentPlayerExiterButton.alpha = 0.3f;
    } completion:nil];
    
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
            buttonToRemove.transform = CGAffineTransformScale(buttonToRemove.transform, 0.01, 0.01);
        } completion:nil];
        [buttonToRemove removeFromSuperview];
    }
    [nadeButtons removeAllObjects];
}


-(void)dismissPlayer:(UIButton *) sender{
    [self.videoPlayer stop];
    self.videoView.hidden = YES;
    [UIView animateWithDuration:0.25 delay:0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
        sender.alpha = 0.0f;
        }
                     completion:^(BOOL finished){
                         sender.hidden = YES;
                     }];


}

/* 
 - (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

} 
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (self.scrollView.minimumZoomScale >= self.scrollView.maximumZoomScale) {
        self.mapView.center = self.view.center;
    }
    self.videoView.frame = [self videoViewScale];
    [[self.videoPlayer view] setFrame:[self.videoView bounds]];
    
    [self.smokesButton setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width / 3, [[UIScreen mainScreen]bounds].size.height - 20)];
    [self.flashesButton setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width * 2 / 3, [[UIScreen mainScreen]bounds].size.height - 20)];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
