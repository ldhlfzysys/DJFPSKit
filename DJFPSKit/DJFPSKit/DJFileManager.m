//
//  DJFileManager.m
//  FPSExample
//
//  Created by donghuan1 on 16/11/30.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import "DJFileManager.h"

#define SingleSelf [DJFileManager sharedManager]

@interface DJFileManager()
{
    dispatch_queue_t safe_queue;
}

@end

@implementation DJFileManager

long DJ_getDiskFreeSize()
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    id obj = [fattributes objectForKey:NSFileSystemFreeSize];
    if ([obj respondsToSelector:@selector(longValue)])
    {
        return [obj longValue];
    }
    return -1;
}

#pragma mark operation
+ (void)setData:(NSData *)jsonData forKey:(NSString *)key handle:(setData)addStatus_;
{
    [SingleSelf _setData:jsonData forKey:key handle:addStatus_];
}

+ (void)dataForKey:(NSString *)key handle:(dataForKey)addStatus_;
{
    [SingleSelf _dataForKey:key handle:addStatus_];
}

+ (void)removeDataForKey:(NSString *)key handle:(setData)removeStatus_;
{
    [SingleSelf _removeDataForKey:key handle:removeStatus_];
}

+ (void)removeAllData:(setData)removeStatus_;
{
    [SingleSelf _removeAllData:removeStatus_];
}

#pragma mark filehandle

#pragma mark lifecycle

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static DJFileManager *_djManager = nil;
    dispatch_once(&onceToken, ^{
        _djManager = [[self alloc]init];
    });
    return _djManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        safe_queue = dispatch_queue_create("com.djfpskit.filemanager", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)_setData:(id)data forKey:(NSString *)key handle:(setData)addStatus_;
{
    long freeDiskSize = DJ_getDiskFreeSize();
    if ((freeDiskSize/1000000)>=10.0)
    {
        dispatch_async(safe_queue, ^{
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            BOOL success = [DJFileManager writeData:jsonData For:key];
            dispatch_async(dispatch_get_main_queue(), ^{
                addStatus_(success);
            });
        });
    }

}

- (void)_dataForKey:(NSString *)key handle:(dataForKey)addStatus_;
{
    dispatch_async(safe_queue, ^{
        NSData *jsonData = [DJFileManager dataFor:key];
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            addStatus_(jsonObject!=nil,jsonObject);
        });
    });
}

- (void)_removeDataForKey:(NSString *)key handle:(setData)removeStatus_;
{
    dispatch_async(safe_queue, ^{
        BOOL removeSuccess = [DJFileManager removeFile:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            removeStatus_(removeSuccess);
        });
    });
}

- (void)_removeAllData:(setData)removeStatus_;
{
    dispatch_async(safe_queue, ^{
        BOOL removeSuccess = [DJFileManager removeAllFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            removeStatus_(removeSuccess);
        });
    });
}

+ (BOOL)writeData:(NSData *)data For:(NSString *)path
{
    NSString *filePath = [[DJFileManager rootFilePath] stringByAppendingPathComponent:path];
    [DJFileManager removeFile:path];
    NSFileManager *tmpFileManager = [NSFileManager defaultManager];
    BOOL isPathValid = NO;
    if (![tmpFileManager fileExistsAtPath:filePath])
    {
        isPathValid = [tmpFileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    else
    {
        isPathValid = YES;
    }
    if (isPathValid)
    {
        [[NSFileHandle fileHandleForUpdatingAtPath:filePath] writeData:data];
        return YES;
    }
    return NO;
    
}

+ (NSData *)dataFor:(NSString *)path
{
    NSString *filePath = [[DJFileManager rootFilePath] stringByAppendingPathComponent:path];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    return data;
}

+ (BOOL)removeFile:(NSString *)path
{
    NSString *filePath = [[DJFileManager rootFilePath] stringByAppendingPathComponent:path];
    NSFileManager *tmpFileManager = [NSFileManager defaultManager];
    NSError *error;
    return [tmpFileManager removeItemAtPath:filePath error:&error];

}

+ (BOOL)removeAllFile
{
    NSString *filePath = [DJFileManager rootFilePath];
    NSError *error;
    NSFileManager *tmpFileManager = [NSFileManager defaultManager];
    return [tmpFileManager removeItemAtPath:filePath error:&error];
}

+ (NSString *)rootFilePath
{
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *directoryPath = [documentsDirectory stringByAppendingPathComponent:@"DJFPSKit"];
    NSFileManager *tmpFileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = [tmpFileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    BOOL isSuccess = NO;
    if (!(isExists && isDir))
    {
        isSuccess = [tmpFileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    else
    {
        isSuccess = YES;
    }
    return isSuccess?directoryPath:@"";

}

@end
