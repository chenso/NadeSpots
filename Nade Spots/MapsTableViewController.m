//
//  MapsTableViewController.m
//  Nade Spots
//
//  Created by Songge Chen on 2/23/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "MapsTableViewController.h"
#import "DetailViewController.h"

@implementation MapsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.debug = NO;
    /*self.mapIdentifiers = @{
                            @"de_dust2" : @"com.nadespots.dust2"
                            };*/
    
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
    [[cell mapTitle] setTextColor:[UIColor blackColor]];

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

- (IBAction)purchase:(SKProduct *)product{
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
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MapTableViewCell * cell = (MapTableViewCell *) sender;
    NSString * theMap = [[cell mapTitle] text];
    DetailViewController * DVC = [segue destinationViewController];
    NSIndexPath * path = [self.tableView indexPathForSelectedRow];

    NSDictionary * mapDetails = [self.maps objectAtIndex:path.row];
    DVC.mapName = theMap;
    DVC.title = theMap;
    DVC.mapDetails = mapDetails;
    DVC.debug = self.debug;
}
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}



@end
