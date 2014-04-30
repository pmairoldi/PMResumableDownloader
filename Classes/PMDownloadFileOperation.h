//
//  DownloadFileItem.h
//  MC
//
//  Created by Pierre-Marc Airoldi on 12/6/2013.
//  Copyright (c) 2013 Mobia Canada Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMDownloadFileOperationProtocol.h"

#define TIMEOUT 20
#define RESUME_OPERATION_FILE_EXTENSION @"rfd"

@class PMDownloadFileItem;

@interface PMDownloadFileOperation : NSOperation <NSURLConnectionDelegate, PMDownloadFileOperationProtocol>

@property PMDownloadFileItem *item;

-(id)initWithDownloadFileItem:(PMDownloadFileItem *)item;
-(void)cancelAndClear:(BOOL)clear;

@end
