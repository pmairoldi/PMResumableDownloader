//
//  Queue.h
//  MC
//
//  Created by Pierre-Marc Airoldi on 11/1/2013.
//  Copyright (c) 2013 Mobila Canada Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMQueue : NSObject

-(void)enqueue:(id)obj;
-(id)dequeue;
-(id)peek;
-(NSUInteger)count;
-(void)enqueueArray:(NSArray *)array;

@end
