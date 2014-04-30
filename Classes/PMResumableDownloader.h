//
//  DownloadFileHandler.h
//  MC
//
//  Created by Pierre-Marc Airoldi on 12/6/2013.
//  Copyright (c) 2013 Mobia Canada Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMDownloadFileOperationProtocol.h"
#import "PMDownloadFileItem.h"

@interface PMResumableDownloader : NSObject

@property (nonatomic) NSUInteger maxConcurrentDownloads;

+(instancetype)sharedDownloadHandler;

-(void)addItemToDownloadFrom:(NSURL *)url withCompletionBlock:(void(^)(void))completionBlock startImmediately:(BOOL)startImmediately;
-(void)addItemToDownload:(PMDownloadFileItem *)downloadFileItem startImmediately:(BOOL)startImmediately;

-(void)startDownloads;
-(void)cancelAllDownloads;
-(void)cancelDownloadForItem:(PMDownloadFileItem *)item;
-(void)cancelDownloadWithTag:(NSString *)tag;
-(void)resumeDownloadsWithCompletionBlock:(void(^)(void))completionBlock;

@end
