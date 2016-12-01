//
//  DJFPSData.m
//  FPSExample
//
//  Created by Dwight on 16/9/7.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import "DJFPSData.h"

#define DJFPS_UNLIKELY(x)  __builtin_expect(!!(x), 0)
#define DJFPS_LIKELY(x)    __builtin_expect(!!(x), 1)

#define _DJFPSRecoder_INVALIDATE_TIMEINTERVAL ( (NSTimeInterval)(-1) )
#define isTimeStampValid(timestamp) ( (_DJFPSRecoder_INVALIDATE_TIMEINTERVAL != (timestamp))? YES : NO )
#define setTimeStampInvalid(timestamp)   ( (timestamp) = _DJFPSRecoder_INVALIDATE_TIMEINTERVAL )

@interface DJFPSBaseData(){
    NSTimeInterval* _frameInterval;
    size_t _maxRecord;
    size_t _count;
    BOOL _isOverflow;
    NSTimeInterval _startTimestamp;
    NSTimeInterval _lastLoopTimestamp;
}

- (BOOL)_pushtimeInterval:(NSTimeInterval)timeInterval;

@end

@implementation DJFPSBaseData


#pragma mark DJFPSData protocol

- (BOOL)addTimeStampOverflow:(CFTimeInterval)timeStamp
{
    NSTimeInterval interval;
    
    if (YES == isTimeStampValid(_lastLoopTimestamp))
    {
        interval = timeStamp - _lastLoopTimestamp;
    }
    else
    {
        NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
        interval = (currentTimestamp - _startTimestamp);
    }
    
    if (DJFPS_UNLIKELY(interval < 0)){
        interval = 0.0f;
        NSLog(@"Timestamp disorder !!!!");
    }
    
    BOOL overflow = [self _pushtimeInterval:interval];

    _lastLoopTimestamp = timeStamp;
    
    return overflow;
}


- (NSArray*)allRecord
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:_count];
    
    for (int i=0; i < _count; i++){
        
        [array addObject:[NSNumber numberWithDouble:_frameInterval[i]]];
    }
    
    return array;
}

- (void)reset
{
    _count = 0;
    _isOverflow = NO;
    setTimeStampInvalid(_startTimestamp);
    setTimeStampInvalid(_lastLoopTimestamp);
}

#pragma mark lifecrycle

- (id<DJFPSDataProtocol>)initWithMaxRecord:(size_t)maxRecord{
    
    self = [super init];
    if (self) {
        _frameInterval = (NSTimeInterval*)malloc(sizeof(NSTimeInterval) * maxRecord);
        _maxRecord = maxRecord;
        _count = 0;
        _isOverflow = NO;
        setTimeStampInvalid(_lastLoopTimestamp);
        setTimeStampInvalid(_startTimestamp);
        _startTimestamp = [[NSDate date] timeIntervalSince1970];
    }
    
    return self;
}

- (instancetype)init{
    return [self initWithMaxRecord:60*10];
}

- (void)dealloc
{
    free(_frameInterval);
}

- (size_t)maxRecord{
    return _maxRecord;
}

- (BOOL)isOverflow{
    return _isOverflow;
}

#pragma mark private
- (BOOL)_pushtimeInterval:(NSTimeInterval)timeInterval
{
    if (_count >= _maxRecord) {
        _isOverflow = YES;
        return YES;
    }
    _frameInterval[_count] = timeInterval;
    _count++;
    return NO;
}


@end
