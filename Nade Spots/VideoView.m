//
//  VideoView.m
//  Nade Spots
//
//  Created by Songge Chen on 6/8/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "VideoView.h"

@implementation VideoView {
    UILabel * byLabel;
    UIButton * channelName;
    UIButton * channelLogo;
    MPMoviePlayerController * videoPlayer;
}

-(id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        byLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 3, CHANNEL_PLUG_HEIGHT)];
        channelName = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width / 3, 0, frame.size.width * 2 / 3, CHANNEL_PLUG_HEIGHT)];
        channelLogo = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width / 3 - CHANNEL_PLUG_HEIGHT /3, CHANNEL_PLUG_HEIGHT / 6, CHANNEL_PLUG_HEIGHT * 5 / 6, CHANNEL_PLUG_HEIGHT * 5 / 6)];
        videoPlayer = [[MPMoviePlayerController alloc] init];
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    [byLabel setText:@"video source:"];
    [byLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:15]];
    [byLabel setBackgroundColor:[UIColor whiteColor]];
    [byLabel setTextAlignment:NSTextAlignmentCenter];
    byLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    byLabel.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    byLabel.layer.shadowRadius = 5.5f;
    byLabel.layer.shadowOpacity = 0.2f;
    byLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:byLabel];
    
    [channelName.titleLabel setTextAlignment:NSTextAlignmentRight];
    [channelName setBackgroundColor:[UIColor colorWithRed:0.803f green:0.125f blue:0.122f alpha:1.0f]];
    [channelName.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:20]];
    [channelName.titleLabel setTextColor:[UIColor whiteColor]];
    
    [channelName addTarget:self action:@selector(openYT) forControlEvents:UIControlEventTouchUpInside];
    
    channelName.titleLabel.shadowColor = [UIColor colorWithRed:0.702f green:0.071f blue:0.09f alpha:1.0f];
    channelName.titleLabel.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    channelName.titleLabel.layer.shadowRadius = 1.3f;
    channelName.titleLabel.layer.shadowOpacity = 0.5f;
    channelName.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:channelName];
    
    [channelLogo addTarget:self action:@selector(openYT) forControlEvents:UIControlEventTouchUpInside];
    channelLogo.layer.shadowColor = UIColorFromRGB(0x2f342b).CGColor;
    channelLogo.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    channelLogo.layer.shadowRadius = 1.5f;
    channelLogo.layer.shadowOpacity = 0.6f;
    
    [self addSubview:channelLogo];
    
    [[videoPlayer view] setFrame:CGRectMake(0, CHANNEL_PLUG_HEIGHT, self.frame.size.width, self.frame.size.height - CHANNEL_PLUG_HEIGHT)];
    videoPlayer.controlStyle = MPMovieControlStyleDefault;
    [self addSubview:videoPlayer.view];
}

-(void)awakeVideoPlayerWithVideoPath:(NSString *) filename fromCreator:(NSString *) video_creator {
    [channelName setTitle:video_creator forState:UIControlStateNormal];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp4"];
    NSURL * videoURL;
    @try {
        videoURL = [NSURL fileURLWithPath:path];
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to locate file for filename %@", filename);
        return;
    }
    
    NSString * logoName = [video_creator stringByAppendingString:@"_logo"];
    [channelLogo setImage:[UIImage imageNamed:logoName] forState:UIControlStateNormal];
    
    videoPlayer.contentURL = videoURL;
    [videoPlayer play];
}

-(void)putVideoPlayerToSleep {
    [videoPlayer stop];
}

-(void)pauseVideoPlayer {
    [videoPlayer pause];
}

-(void) playVideoPlayer {
    [videoPlayer play];
}

- (void) openYT {
    if ([channelName.titleLabel.text isEqualToString:@"Jamiew_"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/c/jamiew"]];
    } else if ([channelName.titleLabel.text isEqualToString:@"TrilluXe"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.youtube.com/TrilluXe"]];
    }
}
@end
