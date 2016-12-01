//
//  DJFPSRecoder.h
//  FPSExample
//
//  Created by Dwight on 16/9/7.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJProtocols.h"

@interface DJFPSRecoder : NSObject

@property(readwrite, assign, nonatomic) id<DJFPSRecoderDelegate>delegate;

- (instancetype)initWithEstimatedTimeForRecord:(NSTimeInterval)time userInfo:(NSMutableDictionary *)userInfo;

- (void)start;
- (void)stop;
- (void)pause;
- (void)fire;
- (void)reset;
- (NSArray*)getFPSData;

@end



