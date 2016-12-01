//
//  DJFPSManager.h
//  FPSExample
//
//  Created by Dwight on 16/9/7.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DJProtocols.h"

@interface DJFPSManager : NSObject<UIAlertViewDelegate>

@property (nonatomic,assign)BOOL needRecording;

@property (nonatomic,assign)BOOL mainSwitch;

+ (DJFPSManager *)sharedManager;

- (void)startRecordType:(id)type;

- (void)showControlPanel;
- (void)stopRecrod;
@end
