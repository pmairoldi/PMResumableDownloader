//
//  NetworkActivityHandler.m
//  MC
//
//  Created by Pierre-Marc Airoldi on 11/20/2013.
//  Copyright (c) 2013 Mobila Canada Inc. All rights reserved.
//

#import "PMNetworkActivityHandler.h"

@implementation PMNetworkActivityHandler

+(id)sharedNetworkIndicator {
    
    static PMNetworkActivityHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    
    self = [super init];
    
    if (self) {
        _processingCount = 0;
    }
    
    return self;
}

-(void)addToCount:(NSInteger)difference {
    
    _processingCount += difference;
    [self setNetworkIndicator];
}

-(void)reduceCount:(NSInteger)difference {
    
    _processingCount -= difference;
    [self setNetworkIndicator];
}

-(void)setNetworkIndicator {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_processingCount > 0) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
        
        else {
            _processingCount = 0;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    });
}

-(void)reset {
    _processingCount = 0;
    [self setNetworkIndicator];
}

@end
