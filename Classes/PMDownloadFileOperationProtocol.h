//
//  DownloadFileOperationProtocol.h
//  MC
//
//  Created by Pierre-Marc Airoldi on 1/27/2014.
//  Copyright (c) 2014 Mobia Canada Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PMDownloadFileItem;

@protocol PMDownloadFileOperationProtocol <NSObject>

-(PMDownloadFileItem *)getDownloadFileItem;
-(BOOL)isCancelled;
-(BOOL)isExecuting;
-(BOOL)isFinished;
-(void)setQueuePriority:(NSOperationQueuePriority)priority;
-(void)cancelAndClear:(BOOL)clear;
-(id)initWithDownloadFileItem:(PMDownloadFileItem *)item;
-(NSString *)getTag;
-(void)cancelBeforeStart;

@end
