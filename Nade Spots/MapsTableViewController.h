//
//  MapsTableViewController.h
//  Nade Spots
//
//  Created by Songge Chen on 2/23/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapsTableViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIImageView *mapTitle;
@property (nonatomic, strong) NSArray * maps;
@end
