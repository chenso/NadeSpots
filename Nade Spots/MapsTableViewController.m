//
//  MapsTableViewController.m
//  Nade Spots
//
//  Created by Songge Chen on 2/23/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "MapsTableViewController.h"


@implementation MapsTableViewController {
    //MBProgressHUD *_progress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.debug = NO;
    /*self.mapIdentifiers = @{
                            @"de_dust2" : @"com.nadespots.dust2"
                            };*/
    self.view.backgroundColor = UIColorFromRGB(0x2f342b);
    self.title = @"MAPS";
    UINavigationBar * navbar = self.navigationController.navigationBar;
    [navbar setBarTintColor:UIColorFromRGB(0xF44336)];
    [navbar setTintColor:[UIColor whiteColor]];
    navbar.translucent = NO;
    navbar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    navbar.layer.shadowColor = [UIColor blackColor].CGColor;
    navbar.layer.shadowOffset = CGSizeMake(0.0f, 2.25f);
    navbar.layer.shadowRadius = 4.0f;
    navbar.layer.shadowOpacity = 0.5f;
    self.tableView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.MFM = [[MapsFileManager alloc] initWithDebug:self.debug];
    
    NSString * mapsPath = [[NSBundle mainBundle]pathForResource:@"Maps" ofType:@"plist"];
    self.maps = [NSArray arrayWithContentsOfFile:mapsPath];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.maps count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    MapTableViewCell * cell = (MapTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary * mapInfo = self.maps[indexPath.row];
    NSString * mapName = mapInfo[@"MapName"];
    [cell.downloadButton.titleLabel setText:mapName];
    /*if ([self.MFM filesFoundForMap:mapInfo]) {
        [cell.downloadButton setImage:[UIImage imageNamed:@"delete_icon"] forState:UIControlStateNormal];
        
    } else {
        [cell.downloadButton setImage:[UIImage imageNamed:@"download_icon"] forState:UIControlStateNormal];
        [cell.downloadButton addTarget:self action:@selector(downloadVideosForMap:) forControlEvents:UIControlEventTouchUpInside];
    }*/
    cell.downloadButton.hidden = YES; // UNTIL NEXT TIME...
    
    NSNumber * smokesCount = [NSNumber numberWithInt:0];
    NSNumber * flashesCount = [NSNumber numberWithInt:0];
    NSNumber * HEMolotovCount = [NSNumber numberWithInt:0];
    [self.MFM getNadeCountForMap:mapInfo smokes:&smokesCount flashes:&flashesCount HEMolotovs:&HEMolotovCount];
    NSString * subtitle = [NSString stringWithFormat:@"%@ smokes %@ flashes %@ HE/molotovs", smokesCount, flashesCount, HEMolotovCount];
    [[cell mapSubtitle] setText:subtitle];
    [[cell mapTitle] setText:mapName];
    [[cell mapTitle] setTextColor:[UIColor whiteColor]];

    [[cell mapImage] setImage:[UIImage imageNamed:[mapName stringByAppendingString:@"_icon.png"]]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell mapImage].layer.shadowColor = [UIColor blackColor].CGColor;
    [cell mapImage].layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    [cell mapImage].layer.shadowRadius = 2.0f;
    [cell mapImage].layer.shadowOpacity = 0.5f;
    
    UIView * seperator = [[UIView alloc] initWithFrame:CGRectMake([cell mapImage].frame.size.width + 25, cell.frame.size.height - 1, fmaxf([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height), 1)];
    seperator.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2f];
    
    [cell addSubview:seperator];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
/*
#pragma mark - File Management

-(void)downloadVideosForMap:(UIButton *) sender {
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject: self.mapIdentifiers[sender.titleLabel.text]]];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = (int) [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStateDeferred: NSLog(@"Transaction state -> Deferred");
                break;
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                NSLog(@"ok");//you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}


-(void) paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    for (SKDownload *download in downloads)
    {
        switch (download.downloadState)
        {
            case SKDownloadStateActive:
            {
#ifdef DEBUG
                NSLog(@"%f", download.progress);
                NSLog(@"%f remaining", download.timeRemaining);
#endif
                
                if (download.progress == 0.0 && !_progress)
                {
#define WAIT_TOO_LONG_SECONDS 60
#define TOO_LARGE_DOWNLOAD_BYTES 4194304
                    
                    const BOOL instantDownload = (download.timeRemaining != SKDownloadTimeRemainingUnknown && download.timeRemaining < WAIT_TOO_LONG_SECONDS) ||
                    (download.contentLength < TOO_LARGE_DOWNLOAD_BYTES);
                    
                    if (instantDownload)
                    {
                        UIView *window= [[UIApplication sharedApplication] keyWindow];
                        
                        _progress = [[MBProgressHUD alloc] initWithView:[[UIApplication sharedApplication] keyWindow]];
                        [window addSubview:_progress];
                        
                        [_progress show:YES];
                        [_progress setDelegate:self];
                        [_progress setDimBackground:YES];
                        [_progress setLabelText:@"Downloading"];
                        [_progress setMode:MBProgressHUDModeAnnularDeterminate];
                    }
                    else
                    {
                        
                    }
                }
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [_progress setProgress:download.progress];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });

                
                break;
            }
                
            case SKDownloadStateCancelled: { break; }
            case SKDownloadStateFailed:
            {
                NSLog(@"Download Failed");
                break;
            }
                
            case SKDownloadStateFinished:
            {
                NSString *source = [download.contentURL relativePath];
                NSDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[source stringByAppendingPathComponent:@"ContentInfo.plist"]];
                
                if (![dict objectForKey:@"Files"])
                {
                    [[SKPaymentQueue defaultQueue] finishTransaction:download.transaction];
                    return;
                }
                
                NSAssert([dict objectForKey:@"Files"], @"The Files property must be valid");
                
                for (NSString *file in [dict objectForKey:@"Files"])
                {
                    NSString *content = [[source stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:file];
                    
                    NSLog(@"Copied");
                }
                
                if (download.transaction.transactionState == SKPaymentTransactionStatePurchased && _progress)
                {
                    NSLog(@"Purchased Complete");
                }
                
                [_progress setDimBackground:NO];
                [_progress hide:YES];
                
                [[SKPaymentQueue defaultQueue] finishTransaction:download.transaction];
                break;
            }
                
            case SKDownloadStatePaused:
            {
#ifdef DEBUG
                NSLog(@"SKDownloadStatePaused");
#endif
                break;
            }
                
            case SKDownloadStateWaiting:
            {
#ifdef DEBUG
                NSLog(@"SKDownloadStateWaiting");
#endif
                break;
            }
        }
    }
}

#pragma mark MBProgressHUDDelegate

-(void) hudWasHidden:(MBProgressHUD *)hud
{
    NSAssert(_progress, @"ddd");
    
    [_progress removeFromSuperview];
} */

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MapTableViewCell * cell = (MapTableViewCell *) sender;
    NSString * theMap = [[cell mapTitle] text];
    self.DVC = [segue destinationViewController];
    NSIndexPath * path = [self.tableView indexPathForSelectedRow];

    NSDictionary * mapDetails = [self.maps objectAtIndex:path.row];
    self.DVC.mapName = theMap;
    self.DVC.title = theMap;
    self.DVC.mapDetails = mapDetails;
    self.DVC.debug = self.debug;
}
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}
- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

@end
