//
//  MapsTableViewController.h
//  Nade Spots
//
//  Created by Songge Chen on 2/23/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapTableViewCell.h"
#import "MapsFileManager.h"
#import "DetailViewController.h"
//#import "MBProgressHUD.h"
#import <iAd/iAd.h>


@interface MapsTableViewController : UITableViewController// <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) NSDictionary * mapIdentifiers;
@property (nonatomic, strong) NSArray * maps;
@property BOOL debug;
@property MapsFileManager * MFM;
@property (nonatomic, strong) DetailViewController * DVC;

@end
