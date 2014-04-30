//
//  DownloadFileHandler.m
//  MC
//
//  Created by Pierre-Marc Airoldi on 12/6/2013.
//  Copyright (c) 2013 Mobia Canada Inc. All rights reserved.
//

#import "PMResumableDownloader.h"
#import "PMNetworkActivityHandler.h"
#import "PMDownloadFileOperation.h"
#import "PMQueue.h"

#define MAX_NUMBER_OF_DOWNLOADS 5
#define FILE_DOWNLOAD_QUEUE @"com.peteappdesigns.pm-resumable-downloads-queue"

static dispatch_queue_t downloadFileQueue = nil;
static dispatch_once_t onceToken;

@interface PMResumableDownloader ()

@property NSOperationQueue *operationQueue;
@property PMQueue *queue;

@end

@implementation PMResumableDownloader

@synthesize maxConcurrentDownloads = _maxConcurrentDownloads;

+(instancetype)sharedDownloadHandler {
    
    static PMResumableDownloader *shared = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self setMaxConcurrentDownloads:NSNotFound];
        
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:[self maxConcurrentDownloads]];
        
        _queue = [[PMQueue alloc] init];
        
        dispatch_once(&onceToken, ^{
            downloadFileQueue = dispatch_queue_create([FILE_DOWNLOAD_QUEUE UTF8String], DISPATCH_QUEUE_SERIAL);
        });
    }
    
    return self;
}

-(NSUInteger)maxConcurrentDownloads {
    
    if (_maxConcurrentDownloads == NSNotFound) {
        _maxConcurrentDownloads = MAX_NUMBER_OF_DOWNLOADS;
    }
    
    return _maxConcurrentDownloads;
}

-(void)setMaxConcurrentDownloads:(NSUInteger)maxConcurrentDownloads {
    
    _maxConcurrentDownloads = maxConcurrentDownloads;
}

-(void)addItemToDownloadFrom:(NSURL *)url withCompletionBlock:(void(^)(void))completionBlock startImmediately:(BOOL)startImmediately {
    
    PMDownloadFileItem *downloadItem = [[PMDownloadFileItem alloc] initWithURL:url andCompletionBlock:completionBlock];

    [self addItemToDownload:downloadItem startImmediately:startImmediately];
}

-(void)addItemToDownload:(PMDownloadFileItem *)downloadFileItem startImmediately:(BOOL)startImmediately {

    [self.queue enqueue:downloadFileItem];
    
    if (startImmediately) {
        [self startDownloads];
    }
}

-(void)startDownloads {
    
    dispatch_async(downloadFileQueue, ^{
        
        [self startAllOperations];
        
    });
}

-(void)startAllOperations {
    
    if ([self.queue count] == 0) {
        return;
    }
    
    NSMutableArray *newOperations = [[NSMutableArray alloc] init];
    
    while ([self.queue count] != 0) {
        
        PMDownloadFileItem *item = [self.queue dequeue];
        
        PMDownloadFileOperation *downloadFileOperation = [[PMDownloadFileOperation alloc] initWithDownloadFileItem:item];
        
        if ([self operation:downloadFileOperation inQueue:self.operationQueue] == NO) {
         
            if (![newOperations containsObject:downloadFileOperation]) {
                [newOperations addObject:downloadFileOperation];
            }
        }
    }
    
    [self.operationQueue addOperations:newOperations waitUntilFinished:NO];
}


-(BOOL)operation:(PMDownloadFileOperation *)operation inQueue:(NSOperationQueue *)queue {
    
    if ([queue.operations containsObject:operation]) {
        return YES;
    }
    
    else {
        
        return NO;
    }
}

-(void)addOperation:(PMDownloadFileOperation *)operation toQueue:(NSOperationQueue *)queue {
    
    if ([queue.operations containsObject:operation]) {
        return;
    }
    
    else {
        [queue addOperation:operation];
    }
}

-(void)cancelAllDownloads {
    
    [self.operationQueue cancelAllOperations];
}

-(NSArray *)getOperations {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObjectsFromArray:[_operationQueue operations]];
    
    return array;
}

-(void)cancelDownloadForItem:(PMDownloadFileItem *)item {
    
    PMDownloadFileOperation *downloadFileOperation = [[PMDownloadFileOperation alloc] initWithDownloadFileItem:item];
    
    if ([_operationQueue.operations containsObject:downloadFileOperation]) {
        [downloadFileOperation cancelAndClear:YES];
    }
}

-(void)cancelDownloadWithTag:(NSString *)tag {
    
    NSInteger index = [_operationQueue.operations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        PMDownloadFileOperation *downloadFileOperation = obj;
        
        if ([[downloadFileOperation getTag] isEqualToString:tag]) {
            return YES;
        }
        
        else {
            return NO;
        }
    }];
    
    if (index != NSNotFound) {
        
        PMDownloadFileOperation *downloadFileOperation = [_operationQueue.operations objectAtIndex:index];
        
        if ([downloadFileOperation isExecuting]) {
            
            [downloadFileOperation cancelAndClear:YES];
        }
        
        else {
            [downloadFileOperation cancelBeforeStart];
        }
    }
}

-(void)resumeDownloadsWithCompletionBlock:(void(^)(void))completionBlock {
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    dispatch_async(downloadFileQueue, ^{
        
        NSString *directoryName = NSTemporaryDirectory();
        
        NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:directoryName];
        
        NSString *filePath;
        
        while (filePath = [direnum nextObject]) {
            
            if ([filePath hasSuffix:RESUME_OPERATION_FILE_EXTENSION]) {
                
                PMDownloadFileItem *item = [NSKeyedUnarchiver unarchiveObjectWithFile:[directoryName stringByAppendingPathComponent:filePath]];
                item.completionBlock = completionBlock;
                
                if (item != nil) {
                    [[[self class] sharedDownloadHandler] addItemToDownload:item startImmediately:YES];
                }
            }
        }
        
        dispatch_semaphore_signal(sema);
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    [[[self class] sharedDownloadHandler] startDownloads];
}

@end
