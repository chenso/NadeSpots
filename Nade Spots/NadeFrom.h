//
//  NadeFrom.h
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NadeFrom : NSObject
@property CGFloat xCord;
@property CGFloat yCord;
@property NSString * path;
-(id) initWithPath:(NSString *)path  xCord:(CGFloat) xCord yCord:(CGFloat) yCord ;
@end
