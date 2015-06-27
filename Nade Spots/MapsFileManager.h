//
//  MapsFileManager.h
//  Nade Spots
//
//  Created by Songge Chen on 5/31/15.
//  Copyright (c) 2015 Songge Chen. All rights reserved.
//

/*
 Maps.plist arranged as:
 item #
 -> { mapname(contained in item#), nadetype[] }
 -> { destination[] }
 -> { xCord, yCord, origin[] }
 -> { xCord, yCord, creator, path}
 */

#import <Foundation/Foundation.h>
#import <StoreKit/Storekit.h>

@interface MapsFileManager : NSFileManager <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property BOOL debug;

-(id) initWithDebug:(BOOL) debug;
-(BOOL) filesFoundForMap:(NSDictionary *) mapDict;
-(void) getNadeCountForMap:(NSDictionary *) map smokes:(NSNumber **) smokesCount flashes:(NSNumber **) flashesCount HEMolotovs:(NSNumber **) hemCount;
@end
