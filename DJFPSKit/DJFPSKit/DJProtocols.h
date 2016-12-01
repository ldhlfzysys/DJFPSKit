//
//  DJProtocols.h
//  FPSExample
//
//  Created by donghuan1 on 16/11/30.
//  Copyright © 2016年 Dwight. All rights reserved.
//

//enum

@class DJFPSRecoder;

typedef enum DJFPSLoggerError{
    DJFPSLogger_error_overflow,
}DJFPSLoggerError;

/**
 
 */
@protocol DJFPSLogStorageProtocol <NSObject>
- (void)logRecoder:(DJFPSRecoder*)recoder userInfo:(NSDictionary*)parameters;
- (void)logError:(DJFPSLoggerError)error onRecoder:(DJFPSRecoder*)recoder;
@end


/**
 
 */
@protocol DJFPSDataProtocol <NSObject>
@required
- (void)reset;
- (BOOL)addTimeStampOverflow:(CFTimeInterval)timeStamp;
- (NSArray*)allRecord; //这个方法比较慢, 建议在async中执行
- (size_t)maxRecord;
@end


/**
 
 */
@protocol DJFPSRecoderDelegate <NSObject>
@optional
- (void)DJFPSRecoderStart:(DJFPSRecoder*)recoder;
- (void)DJFPSRecoderStoped:(DJFPSRecoder*)recoder userInfo:(NSDictionary *)userInfo_;
- (void)DJFPSRecoderOverFlow:(DJFPSRecoder*)recoder userInfo:(NSDictionary *)userInfo_;
@end
