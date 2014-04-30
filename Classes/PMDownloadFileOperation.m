//
//  DownloadFileItem.m
//  MC
//
//  Created by Pierre-Marc Airoldi on 12/6/2013.
//  Copyright (c) 2013 Mobia Canada Inc. All rights reserved.
//

#import "PMDownloadFileOperation.h"
#import "PMDownloadFileItem.h"
#import "PMNetworkActivityHandler.h"

#ifdef DEBUG
    #define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
    #define NSLog(...)
#endif

#define FILES_FOLDER @"Files"

@interface PMDownloadFileOperation ()

@property NSURLConnection *fileDownloadConnection;
@property NSOutputStream *fileOutputStream;
@property NSString *resumableFilePath;
@property NSString *tag;
@property BOOL executing;
@property BOOL finished;
@property BOOL cancelled;

@end

@implementation PMDownloadFileOperation


-(id)init {
    
    return [self initWithDownloadFileItem:[[PMDownloadFileItem alloc] init]];
}

-(id)initWithDownloadFileItem:(PMDownloadFileItem *)item {
    
    self = [super init];
    
    if (self) {
        
        _item = item;
        _tag = _item.url.absoluteString;
        _executing = NO;
        _finished = NO;
        _cancelled = NO;
        
        self.completionBlock = item.completionBlock;
        
        if (_item.url == nil) {
            _resumableFilePath = nil;
        }
        
        else {
            _resumableFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[[[_item url] lastPathComponent] stringByDeletingPathExtension]] stringByAppendingPathExtension:RESUME_OPERATION_FILE_EXTENSION];
            
            [self getBytesDownloadedFromFile:_resumableFilePath];
        }
        
    }
    
    return self;
}

-(NSURLRequest *)createRequest:(NSURL *)url startingAt:(unsigned long long)bytesWritten {
    
    if (url == nil) {
        return nil;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:TIMEOUT];
    
    if (bytesWritten > 0) {
        
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", bytesWritten];
        [request setValue:requestRange forHTTPHeaderField:@"Range"];
    }
    
    return request;
}

-(unsigned long long)getBytesDownloadedFromFile:(NSString *)filePath {
    
    if ([filePath isEqualToString:@""] || filePath == nil) {
        return  0;
    }
    
    else {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            self.item = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            
            if (self.item != nil) {
                
                return self.item.bytesRecieved;
            }
            
            else {
                
                NSError *deleteError;
                
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&deleteError];
                
                if (deleteError != nil) {
                    NSLog(@"%@",[[deleteError userInfo] description]);
                }
                
                return [self getBytesDownloadedFromFile:filePath];
            }
        }
        
        else {
            
            [self writeResumableFile];
            
            return [self getBytesDownloadedFromFile:filePath];
        }
    }
}

- (void)start {
    
    // Bail out early if cancelled.
    
    [[PMNetworkActivityHandler sharedNetworkIndicator] addToCount:1];
    
    //add condiction here
    BOOL shouldCancel = NO;
    
    if (shouldCancel) {
        
        [self willChangeValueForKey:@"isCancelled"];
        self.cancelled = YES;
        [self didChangeValueForKey:@"isCancelled"];
        
        [self willChangeValueForKey:@"isFinished"];
        self.finished = YES;
        [self didChangeValueForKey:@"isFinished"];
    }
    
    if ([self isCancelled]) {
        
        [self.fileDownloadConnection cancel];
        [self.fileOutputStream close];
        
        [[PMNetworkActivityHandler sharedNetworkIndicator] reduceCount:1];
        
        [self cancelAndClear:YES];
        
        return;
    }
    
    if ([self isFinished]) {
        
        [self.fileDownloadConnection cancel];
        [self.fileOutputStream close];
        
        [[PMNetworkActivityHandler sharedNetworkIndicator] reduceCount:1];
        
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    self.executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[_item url] lastPathComponent]];
    
    self.fileOutputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
    
    [self.fileOutputStream open];
    
//    NSLog(@"item: %@", _item.url.absoluteString);
//    NSLog(@"file size: %llu", _item.bytesRecieved);
    
    self.fileDownloadConnection = [[NSURLConnection alloc] initWithRequest:[self createRequest:self.item.url startingAt:_item.bytesRecieved] delegate:self startImmediately:NO];
    
    [self.fileDownloadConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.fileDownloadConnection start];
    
    while ([self isExecuting]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [[PMNetworkActivityHandler sharedNetworkIndicator] reduceCount:1];
}

-(BOOL)isExecuting {
    return _executing;
}

-(BOOL)isCancelled {
    return _cancelled;
}

-(BOOL)isFinished {
    return _finished;
}

-(BOOL)isConcurrent {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
//    NSLog(@"%@ %llu %llu %llu", [[[connection currentRequest] URL] absoluteString], (unsigned long long)bytesWritten, (unsigned long long)totalBytesWritten, (unsigned long long)totalBytesExpectedToWrite);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    NSInteger statusCode = [httpResponse statusCode];
    
    if ((statusCode < 200 || statusCode > 299) && statusCode != 416) {
        
//        NSLog(@"%@ canceled", [[[connection currentRequest] URL] absoluteString]);
        [self cancelAndClear:YES];
    }
    
//    NSLog(@"status code: %d", (int)statusCode);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSOutputStream *outputStream;
    
    self.item.bytesRecieved += [data length];
    
    outputStream = self.fileOutputStream;
    
    if (![self writeData:data toStream:outputStream]) {
        [self cancelAndClear:NO];
    };
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
//   NSLog(@"%@ finished", [[[connection currentRequest] URL] absoluteString]);

    [self.fileOutputStream close];
    self.fileDownloadConnection = nil;
    
    [self writeResumableFile];
    
    [self addFileToDirectory];
    
    [self willChangeValueForKey:@"isExecuting"];
    self.executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    self.finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
//    NSLog(@"%@",[[[connection currentRequest] URL] absoluteString]);
    
    [self.fileOutputStream close];
    
    //also delete
    
    [self cancelAndClear:NO];
}

-(BOOL)writeData:(NSData *)data toStream:(NSOutputStream *)stream {
    
    NSInteger startWriteLength = [data length];
    NSInteger actualStartWrittenLength = [stream write:[data bytes] maxLength:startWriteLength];
    
    if (actualStartWrittenLength == -1 || actualStartWrittenLength != startWriteLength) {
        return NO;
    }
    
    else {
        
        self.item.bytesRecieved += [data length];
        
        return YES;
    }
}

-(void)addFileToDirectory {
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[self.item url] lastPathComponent]];

    NSString *documentsDirectory = [[self class] getFileFolder];
    
    NSError *moveError;
    
    [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:[documentsDirectory stringByAppendingPathComponent:[[self.item url] lastPathComponent]] error:&moveError];
    
    if (moveError != nil) {
        
        if ([moveError code] != NSFileWriteFileExistsError) {
            NSLog(@"%@",[[moveError userInfo] description]);
        }
        
        [self removeFileFromTemp];
    }
    
    [self removeResumableFile];
}

-(void)removeResumableFile {
    
    NSString *tempfilePath = [[[NSTemporaryDirectory() stringByAppendingPathComponent:[[_item url] lastPathComponent]] stringByDeletingPathExtension] stringByAppendingPathExtension:RESUME_OPERATION_FILE_EXTENSION];

    NSError *error;
    
    [[NSFileManager defaultManager] removeItemAtPath:tempfilePath error:&error];
    
    if (error != nil) {
        NSLog(@"%@",[[error userInfo] description]);
    }
}

-(void)removeFileFromTemp {

    NSString *tempfilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[_item url] lastPathComponent]];
    
    NSError *error;
    
    [[NSFileManager defaultManager] removeItemAtPath:tempfilePath error:&error];
    
    if (error != nil) {
        NSLog(@"%@",[[error userInfo] description]);
    }
}

-(void)cancel {
    
    [self cancelAndClear:NO];
}

-(void)cancelAndClear:(BOOL)clear {
    
    [self.fileDownloadConnection cancel];
    
    if (clear) {
        [self removeFileFromTemp];
    }
    
    else {
        [self writeResumableFile];
    }
    
    [self willChangeValueForKey:@"isCancelled"];
    self.cancelled = YES;
    [self didChangeValueForKey:@"isCancelled"];
    
    [self willChangeValueForKey:@"isExecuting"];
    self.executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    self.finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}

-(void)cancelBeforeStart {
    
    [self.fileDownloadConnection cancel];
    
    [self removeFileFromTemp];
    
    [self willChangeValueForKey:@"isCancelled"];
    self.cancelled = YES;
    [self didChangeValueForKey:@"isCancelled"];
    
    [self willChangeValueForKey:@"isExecuting"];
    self.executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
}

-(BOOL)writeResumableFile {
    
    BOOL success = [NSKeyedArchiver archiveRootObject:self.item toFile:self.resumableFilePath];
    
    if (!success) {
        NSLog(@"failed to save rfd object");
    }
    
    return success;
}

-(BOOL)isEqual:(id)object {
    
    if ([object isKindOfClass:[self class]]) {
        
        id<PMDownloadFileOperationProtocol> downloadItem = object;
        
        if ([_item.url isEqual:[downloadItem getDownloadFileItem].url]) {
            return YES;
        }
        
        else {
            return NO;
        }
    }
    
    return NO;
    
}

-(PMDownloadFileItem *)getDownloadFileItem {
    
    return _item;
}

-(void)setQueuePriority:(NSOperationQueuePriority)priority {
    
    super.queuePriority = priority;
}

-(NSString *)getTag {
    
    return _tag;
}

+(NSString *)getDocumentsDirectionPath:(NSString *)path {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory stringByAppendingPathComponent:path];
    
    return documentsPath;
}

+(NSString *)getFileFolder {
    
    NSString *path = [[self class] getDocumentsDirectionPath:FILES_FOLDER];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if ([fileManager fileExistsAtPath:path] == NO) {
        
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }

    return path;
}

@end
