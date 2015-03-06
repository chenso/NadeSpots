//
//  NadeSpot.h
//  Nade Spots
//
//  Created by Songge Chen on 2/25/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NadeFrom.h"

@interface NadeSpot : NSObject
@property CGFloat xCord;
@property CGFloat yCord;
@property (strong, nonatomic) NSArray *nadeFrom;
-(id) initWithX:(CGFloat) xCord Y:(CGFloat)yCord fromLocations:(NSArray *)origin;
@end
