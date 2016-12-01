//
//  DJFPSLogrStorage.m
//  FPSExample
//
//  Created by Dwight on 16/9/7.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import "DJFPSLogStorage.h"
#import "DJFPSRecoder.h"
#import "DJFPSLogger.h"
#import "DJFPSManager.h"
#import "DJFileManager.h"
@implementation DJFPSBaseStorage : NSObject 

- (void)logRecoder:(DJFPSRecoder*)recoder userInfo:(NSDictionary *)dict
{
    [self reciveFPSData:[recoder getFPSData] userInfo:dict];

}

- (void)logError:(DJFPSLoggerError)error onRecoder:(DJFPSRecoder*)recoder
{


}

- (void)reciveFPSData:(NSArray *)array userInfo:(NSDictionary *)dict;
{
    double counter = 0;
    double time = 0;
    NSMutableArray *fpsValue = [[NSMutableArray alloc]init];
    //取半秒平均值
    for (int i = 0; i < array.count; i ++) {
        double currentTime = [array[i] doubleValue];
        //将fps小于62.5和大于20的视为有效数据
        if (currentTime > 0.016 && currentTime < 0.05) {
            time += [array[i] doubleValue];
            counter += 1;
        }
        
        if (counter == 30 || i == (array.count - 1)) {
            double averageTime = time/counter;
            int intfps = ceil(1.0/averageTime);
            NSUInteger fpsUValue = MIN(60, intfps);
            [fpsValue addObject:@(fpsUValue)];
            time = 0;
            counter = 0;
        }
    }
    
    __block NSArray *uploadArr = [NSArray arrayWithArray:fpsValue];
    __block NSMutableDictionary *mergeDict = [NSMutableDictionary dictionary];
    [mergeDict setObject:uploadArr forKey:@"fpsvalue"];
    [mergeDict addEntriesFromDictionary:dict];
    [self saveData:mergeDict];
    
}

- (void)saveData:(NSDictionary *)dict
{
    [DJFileManager setData:dict forKey:[dict objectForKey:@"loggertype"] handle:^(BOOL status) {
        if (status) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"记录完成" message:@"" delegate:nil cancelButtonTitle:@"阅" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}



@end



