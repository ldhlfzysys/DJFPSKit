//
//  DJFPSLogrStorage.h
//  FPSExample
//
//  Created by Dwight on 16/9/7.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJProtocols.h"

@interface DJFPSBaseStorage : NSObject
- (void)logRecoder:(DJFPSRecoder*)recoder userInfo:(NSDictionary*)dict;
- (void)logError:(DJFPSLoggerError)error onRecoder:(DJFPSRecoder*)recoder;
@end
