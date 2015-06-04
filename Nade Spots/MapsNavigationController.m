//
//  MapsNavigationController.m
//  Nade Spots
//
//  Created by Songge Chen on 6/3/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "MapsNavigationController.h"

@implementation MapsNavigationController
-(BOOL)shouldAutorotate
{
    return NO;
}
- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}
@end
