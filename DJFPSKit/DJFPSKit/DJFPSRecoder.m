//
//  DJFPSRecoder.m
//  FPSExample
//
//  Created by Dwight on 16/9/7.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import "DJFPSRecoder.h"
#import "DJFPSData.h"
#import <QuartzCore/QuartzCore.h>

#define DJFPSRecoder_DEFAULT_ESTIMATED_TIME 5 //10s

#define DJFPSRecoder_INVALIDATE_TIMEINTERVAL ( (NSTimeInterval)(-1) )
#define validateTimeStamp(timestamp) ( (DJFPSRecoder_INVALIDATE_TIMEINTERVAL != timestamp)? YES : NO )

typedef NSTimeInterval FPSFrame;

@interface DJFPSRecoder(){
    CADisplayLink *_displayLink;
    NSTimeInterval _startTimestamp;
    NSTimeInterval _stopTimestamp;
    id<DJFPSDataProtocol> _data;
    BOOL _pause;
    NSMutableDictionary *userInfo;
}

@end

@implementation DJFPSRecoder

#pragma mark lifecrycle

- (instancetype)initWithEstimatedTimeForRecord:(NSTimeInterval)time userInfo:(NSMutableDictionary *)userInfo_{
    
    self = [super init];
    if (self) {
        _displayLink = nil;
        _data = [[DJFPSBaseData alloc] initWithMaxRecord:(size_t)(time *60)];
        _delegate = nil;
        userInfo = userInfo_;
    }
    return self;
}

- (instancetype)init{
    return [self initWithEstimatedTimeForRecord:DJFPSRecoder_DEFAULT_ESTIMATED_TIME userInfo:nil];
}

- (void)dealloc{
    
    [self stop];
    _displayLink = nil;
    _data = nil;
}

- (void)start
{
    if (YES == [self isRunning])
        [self stop];
    
    assert(nil == _displayLink);

    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_displayLinkCallback:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];//如果使用default mode，table滚动时不会更新s
    
    if (nil != _delegate  &&  [_delegate respondsToSelector:@selector(DJFPSRecoderStart:)])
    {
        [_delegate DJFPSRecoderStart:self];
    }
}

- (void)stop
{
    if (YES == [self isRunning])
    {
        assert(nil != _displayLink);
        
        [_displayLink invalidate];
        _displayLink = nil;
        
        _stopTimestamp = [[NSDate date] timeIntervalSince1970];
        
        if (nil != _delegate  &&  [_delegate respondsToSelector:@selector(DJFPSRecoderStoped:userInfo:)])
        {
            [_delegate DJFPSRecoderStoped:self userInfo:userInfo];
        }
    }
}

- (void)pause;
{
    _pause = YES;
}

- (void)fire;
{
    _pause = NO;
}


- (void)reset //必需在stop时调用
{
    if (YES == [self isRunning])
        return;
    [_data reset];
    _startTimestamp = DJFPSRecoder_INVALIDATE_TIMEINTERVAL;
    _stopTimestamp = DJFPSRecoder_INVALIDATE_TIMEINTERVAL;
    [self setDelegate:nil];
}

- (BOOL)isRunning{
    return (nil != _displayLink)? YES : NO;
}

- (NSArray*)getFPSData{
    
    if (YES == self.isRunning)
        return nil;
    
    return [_data allRecord];
}

#pragma mark private
- (void)_displayLinkCallback:(CADisplayLink *)link{
    
    if (_pause) {
        return;
    }
    
    if (YES == [_data addTimeStampOverflow:link.timestamp])
    {
        if (nil != _delegate  &&  [_delegate respondsToSelector:@selector(DJFPSRecoderOverFlow:userInfo:)])
        {
            [_delegate DJFPSRecoderOverFlow:self userInfo:userInfo];
        }
    }
    
}

@end





