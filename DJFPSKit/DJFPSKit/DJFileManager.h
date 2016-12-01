//
//  DJFileManager.h
//  FPSExample
//
//  Created by donghuan1 on 16/11/30.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJFPSLogStorage.h"
#import "DJProtocols.h"

typedef void (^setData)(BOOL status);
typedef void (^dataForKey)(BOOL status,id data);

@interface DJFileManager : NSObject

+ (void)setData:(id)data forKey:(NSString *)key handle:(setData)addStatus_;
+ (void)dataForKey:(NSString *)key handle:(dataForKey)addStatus_;
+ (void)removeDataForKey:(NSString *)key handle:(setData)removeStatus_;
+ (void)removeAllData:(setData)removeStatus_;

+ (NSString *)rootFilePath;
+ (NSData *)dataFor:(NSString *)path;
+ (BOOL)removeFile:(NSString *)path;
+ (BOOL)removeAllFile;
@end
