//
//  Queue.m
//  MC
//
//  Created by Pierre-Marc Airoldi on 11/1/2013.
//  Copyright (c) 2013 Mobila Canada Inc. All rights reserved.
//

#import "PMQueue.h"

@interface PMQueue()

@property NSMutableArray *queue;

@end

@implementation PMQueue

@synthesize queue;

-(id)init {
    
    self = [super init];
    
    if (self) {
        //fancy stuff here
        queue = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)enqueue:(id)item {
   
    [queue addObject:item];
}

-(id)dequeue {
    
    id item = nil;
    
    if ([self count] != 0) {
        item = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
    }
    
    return item;
}

-(id)peek {
    
    id item = nil;
    
    if ([self count] != 0) {
        item = [queue objectAtIndex:0];
    }
    
    return item;
}


-(NSUInteger)count {
    return [queue count];
}

-(void)enqueueArray:(NSArray *)array {
    
    for (id item in array) {
        [self enqueue:item];
    }
}

@end
