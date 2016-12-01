//
//  DJFPLogger.h
//  FPSExample
//
//  Created by Dwight on 16/9/7.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJFPSRecoder.h"
#import "DJFPSLogStorage.h"
#import "DJProtocols.h"

/*logger 本身支持global方式，但不推荐*/
@interface DJFPSLogger : NSObject
@property (nonatomic,strong)NSMutableDictionary *userInfo;

- (instancetype)initWithStorageClass:(Class)storageClass;
- (void)startRecoderWithEstimateTime:(NSTimeInterval)estimateTime RecordOnlyScrolling:(BOOL)scrolling;
- (void)stopRecoderWithParameters:(NSDictionary*)extraParameters;
- (void)stopRecord;
- (void)setRecorderPause:(BOOL)pause;
@end






