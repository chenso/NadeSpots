//
//  MapsFileManager.m
//  Nade Spots
//
//  Created by Songge Chen on 5/31/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

#import "MapsFileManager.h"

@implementation MapsFileManager

-(id) initWithDebug:(BOOL) debug {
    if (self = [super init]) {
        self.debug = debug;
    }
    return self;
}

-(BOOL) filesFoundForMap:(NSDictionary *) mapDict {
    return [self filesFoundForNadeType:mapDict[@"Flashes"]] &&
    [self filesFoundForNadeType:mapDict[@"Smokes"]] &&
    [self filesFoundForNadeType:mapDict[@"HEMolotov"]];
}

-(BOOL) filesFoundForNadeType:(NSDictionary *) destinationDictionary {
    for (id key in destinationDictionary) {
        if(![self filesFoundForDestination:[destinationDictionary objectForKey:key]]) return NO;
    }
    return YES;
}

-(BOOL) filesFoundForDestination:(NSDictionary *) destination {
    for (id key in destination) {
        if (![key isEqualToString:@"xCord"] && ![key isEqualToString:@"yCord"]) {
            NSDictionary * origin = [destination objectForKey:key];
            if (![self fileFoundForOrigin:origin]) return NO;
        }
    }
    return YES;
}

-(BOOL) fileFoundForOrigin:(NSDictionary *) origin {
    NSString * path = [origin objectForKey:@"path"];
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:path ofType:@"mp4"];
    BOOL fileExists =[self fileExistsAtPath:bundlePath];
    if (self.debug && !fileExists) {
        NSLog(@"%@ not found", path);
    }
    return fileExists;
}

-(void) getNadeCountForMap:(NSDictionary *) map smokes:(NSNumber **) smokesCount flashes:(NSNumber **) flashesCount HEMolotovs:(NSNumber **) hemCount {
    *smokesCount = [self countForNadeType:map[@"Smokes"]];
    *flashesCount = [self countForNadeType:map[@"Flashes"]];
    *hemCount = [self countForNadeType:map[@"HEMolotov"]];
}

-(NSNumber *) countForNadeType:(NSDictionary *) destDict {
    int count = 0;
    for (id key in destDict) {
        count += [self countForDestination:[destDict objectForKey:key]];
    }
    return [NSNumber numberWithInt:count];
}

-(int) countForDestination:(NSDictionary *) destination {
    int count = 0;
    for (id key in destination) {
        if (![key isEqualToString:@"xCord"] && ![key isEqualToString:@"yCord"]) {
            count++;
        }
    }
    return count;
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

@end
