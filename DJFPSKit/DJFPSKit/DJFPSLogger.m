//
//  DJFPLogger.m
//  FPSExample
//
//  Created by Dwight on 16/9/7.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import "DJFPSLogger.h"
#import "DJFPSRecoder.h"

@interface DJFPSLogger()<DJFPSRecoderDelegate>{
    DJFPSRecoder* _recoder;
    id<DJFPSLogStorageProtocol> _storage;
    dispatch_queue_t safe_queue;
}

@end

@implementation DJFPSLogger

#pragma mark DJFPSRecoderDelegate

- (void)DJFPSRecoderOverFlow:(DJFPSRecoder*)recoder userInfo:(NSDictionary *)userInfo_;
{
    if (nil == recoder)
    {
        assert(0);
        return;
    }

    [recoder stop];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (nil != _storage  &&  [_storage respondsToSelector:@selector(logError:onRecoder:)]){
            
            [_storage logRecoder:recoder userInfo:_userInfo];
            
        }
    });
}

- (void)DJFPSRecoderStoped:(DJFPSRecoder*)recoder userInfo:(NSDictionary *)userInfo_;
{
    
}

- (void)DJFPSRecoderStart:(DJFPSRecoder*)recoder;
{
    
}


#pragma mark lifecrycle
- (instancetype)initWithStorageClass:(Class)storageClass
{
    self = [super init];
    if (self) {
        safe_queue = dispatch_queue_create("com.fps.logger.safe.queue", DISPATCH_QUEUE_SERIAL);
        _recoder = nil;
        _userInfo = [[NSMutableDictionary alloc]init];
        if (NULL == storageClass){
            storageClass = [DJFPSBaseStorage class];
        }
        _storage = [[storageClass alloc] init];
    }
    
    return self;
}


- (void)dealloc
{
    [self _shutdownRecoder];
}

- (void)stopRecord
{
    [self _shutdownRecoder];
}

#pragma mark private
- (void)_shutdownRecoder{
    
    dispatch_sync(safe_queue, ^{
        if (nil != _recoder){
            [_recoder stop];
        }
    });
    
}

- (void)setRecorderPause:(BOOL)pause
{
    if (pause)
    {
        [_recoder pause];
    }
    else
    {
        [_recoder fire];
    }
}

- (void)startRecoderWithEstimateTime:(NSTimeInterval)estimateTime RecordOnlyScrolling:(BOOL)scrolling
{
    dispatch_sync(safe_queue, ^{
        
        if (nil != _recoder){
            [_recoder stop];
        }
        
        _recoder = [[DJFPSRecoder alloc] initWithEstimatedTimeForRecord:estimateTime userInfo:_userInfo];
        [_recoder setDelegate:self];
        if (scrolling) {
            [_recoder pause];
        }
        [_recoder start];
    });
}


- (void)stopRecoderWithParameters:(NSDictionary*)extraParameters
{
    
    dispatch_sync(safe_queue, ^{
        
        if (nil != _recoder){
            DJFPSRecoder *currentRecord  = _recoder;
            [_recoder stop];
            [_userInfo addEntriesFromDictionary:extraParameters];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (nil != _storage  &&  [_storage respondsToSelector:@selector(logRecoder:userInfo:)])
                {
                    [_storage logRecoder:currentRecord userInfo:extraParameters];
                }
                
            });
            
        }
    });
}

@end




