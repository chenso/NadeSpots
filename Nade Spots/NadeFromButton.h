//
//  NadeFromButton.h
//  Nade Spots
//
//  Created by Songge Chen on 2/26/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NadeFromButton : UIButton
@property NSString * path;
@property NSString * video_creator;

-(id) initWithPath:(NSString *)path video_creator:(NSString *)video_creator;

@end
