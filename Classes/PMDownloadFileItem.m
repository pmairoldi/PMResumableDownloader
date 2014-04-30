//
//  DownloadFileItem.m
//  MC
//
//  Created by Pierre-Marc Airoldi on 12/6/2013.
//  Copyright (c) 2013 Mobia Canada Inc. All rights reserved.
//

#import "PMDownloadFileItem.h"

#define OBJC_STRINGIFY(x) @#x
#define encodeObject(x) [aCoder encodeObject:x forKey:OBJC_STRINGIFY(x)]
#define decodeObject(x) x = [aDecoder decodeObjectForKey:OBJC_STRINGIFY(x)]
#define encodeBool(x) [aCoder encodeBool:x forKey:OBJC_STRINGIFY(x)]
#define decodeBool(x) x = [aDecoder decodeBoolForKey:OBJC_STRINGIFY(x)]
#define encodeInt64(x) [aCoder encodeInt64:x forKey:OBJC_STRINGIFY(x)]
#define decodeInt64(x) x = [aDecoder decodeInt64ForKey:OBJC_STRINGIFY(x)]

@implementation PMDownloadFileItem

-(id)init {
    
    return [self initWithURL:[NSURL URLWithString:@""] andCompletionBlock:nil];
}

-(id)initWithURL:(NSURL *)url andCompletionBlock:(void(^)(void))completionBlock {

    self = [super init];
    
    if (self) {
        
        _bytesRecieved = 0;
        _totalBytes = ULONG_LONG_MAX;
        
        _url = url;
        _completionBlock = completionBlock;
    }
    
    return self;
}

-(BOOL)isEqual:(id)object {
    
    if ([object isKindOfClass:[PMDownloadFileItem class]]) {
        
        PMDownloadFileItem *downloadItem = (PMDownloadFileItem *)object;
        
        if ([_url.absoluteString isEqualToString:downloadItem.url.absoluteString]) {
            return YES;
        }
        
        else {
            return NO;
        }
    }
    
    return NO;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    //TODO:get the block to save to file
    if (self) {
                
        decodeObject(_url);
        decodeBool(_hasFinished);
        decodeBool(_wasSuccesful);
        decodeBool(_hasStarted);
//        decodeObject(_completionBlock);
        decodeInt64(_bytesRecieved);
        decodeInt64(_totalBytes);
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
 
    encodeObject(_url);
    encodeBool(_hasFinished);
    encodeBool(_wasSuccesful);
    encodeBool(_hasStarted);
//    encodeObject(_ompletionBlock);
    encodeInt64(_bytesRecieved);
    encodeInt64(_totalBytes);
}

@end
