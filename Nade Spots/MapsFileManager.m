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
@end
