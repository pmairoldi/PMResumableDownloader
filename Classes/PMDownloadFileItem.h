//
//  DownloadFileItem.h
//  MC
//
//  Created by Pierre-Marc Airoldi on 12/6/2013.
//  Copyright (c) 2013 Mobia Canada Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMDownloadFileItem : NSObject <NSCoding>

@property NSURL *url;
@property BOOL hasFinished;
@property BOOL wasSuccesful;
@property BOOL hasStarted;
@property (copy) void(^completionBlock)();

@property unsigned long long bytesRecieved;
@property unsigned long long totalBytes;

-(id)initWithURL:(NSURL *)url andCompletionBlock:(void(^)(void))completionBlock;

@end
