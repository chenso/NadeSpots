//
//  DetailViewController.h
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "NadeSpot.h"
#import "NadeSpotButton.h"
#import "NadeFromButton.h"
#import <MediaPlayer/MediaPlayer.h>

@interface DetailViewController : UIViewController <UIScrollViewDelegate> {
    UIScrollView * scrollView;
    UIImageView * mapView;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *mapView;
@property (strong, nonatomic) NSString * mapName;
@property (strong, nonatomic) NSDictionary * mapDetails;
- (void)centerScrollViewContents;
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer;

@end
