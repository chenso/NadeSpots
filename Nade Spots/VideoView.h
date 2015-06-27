//
//  VideoView.h
//  Nade Spots
//
//  Created by Songge Chen on 6/8/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define CHANNEL_PLUG_HEIGHT 40

#ifndef _COLOR_FROM_HEX
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#endif

@interface VideoView : UIView

-(void)awakeVideoPlayerWithVideoPath:(NSString *) filename fromCreator:(NSString *) video_creator;
-(void)putVideoPlayerToSleep;
-(void)pauseVideoPlayer;
-(void)playVideoPlayer;
@end
