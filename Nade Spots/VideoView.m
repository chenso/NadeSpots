//
//  VideoView.m
//  Nade Spots
//
//  Created by Songge Chen on 6/8/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "VideoView.h"

@implementation VideoView {
    MPMoviePlayerController * videoPlayer;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        videoPlayer = [[MPMoviePlayerController alloc] init];
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    [[videoPlayer view] setFrame:self.bounds];
    videoPlayer.controlStyle = MPMovieControlStyleDefault;
    [self addSubview:videoPlayer.view];
}

-(void)awakeVideoPlayerWithVideoPath:(NSString *) filename fromCreator:(NSString *) video_creator {
    
    NSString * path = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp4"];
    NSURL * videoURL;
    @try {
        videoURL = [NSURL fileURLWithPath:path];
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to locate file for filename %@", filename);
        return;
    }
    
    //NSString * logoName = [video_creator stringByAppendingString:@"_logo"];
    //[channelLogo setImage:[UIImage imageNamed:logoName] forState:UIControlStateNormal];
    
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

@end
