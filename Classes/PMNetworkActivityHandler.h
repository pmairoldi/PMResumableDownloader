//
//  NetworkActivityHandler.h
//  MC
//
//  Created by Pierre-Marc Airoldi on 11/20/2013.
//  Copyright (c) 2013 Mobila Canada Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMNetworkActivityHandler : NSObject

@property NSInteger processingCount;

+(id)sharedNetworkIndicator;

-(void)addToCount:(NSInteger)difference;
-(void)reduceCount:(NSInteger)difference;
-(void)reset;

@end
