//
//  DJFPSData.h
//  FPSExample
//
//  Created by Dwight on 16/9/7.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJProtocols.h"

@interface DJFPSBaseData : NSObject <DJFPSDataProtocol>
- (id<DJFPSDataProtocol>)initWithMaxRecord:(size_t)maxRecord;
@end






