//
//  MapsTableViewController.h
//  Nade Spots
//
//  Created by Songge Chen on 2/23/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/Storekit.h>
#import "MapTableViewCell.h"
#import "MapsFileManager.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MapsTableViewController : UITableViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) NSDictionary * mapIdentifiers;
@property (nonatomic, strong) NSArray * maps;
@property BOOL debug;
@property MapsFileManager * MFM;
@end
