//
//  DJFPSManager.m
//  FPSExample
//
//  Created by Dwight on 16/9/7.
//  Copyright © 2016年 Dwight. All rights reserved.
//


#import "DJFPSManager.h"
#import "objc/runtime.h"
#import "DJFPSLogger.h"
#import "DJFPSLogStorage.h"
#import "DJFPSResultsController.h"

@protocol DJNodeFakeProperty <NSObject>

- (NSString *)containerId;

@end

@interface DJFPSManager()
{
    NSMutableArray *classMaps;
}

@property (nonatomic,strong)DJFPSLogger *logger;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,copy)NSString *tmpCachetype;

@property (nonatomic,weak)id currentVC;
@property (nonatomic,weak)id tmpCacheVC;

@property (nonatomic,strong)UIWindow *controlpanel;
@property (nonatomic,strong)UIButton *controlButton;
@property (nonatomic,strong)UIButton *showButton;
@property (nonatomic,strong)UILabel *logInfo;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@end

@implementation DJFPSManager

#pragma mark - LifeCycle

+ (DJFPSManager *)sharedManager
{
    static DJFPSManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DJFPSManager alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        classMaps = [[NSMutableArray alloc]initWithCapacity:2];
        _mainSwitch = NO;
        [self swizzledViewController];
        

    }
    return self;
}

-(void)setMainSwitch:(BOOL)mainSwitch
{
    if (_mainSwitch == mainSwitch) {
        return;
    }
    _mainSwitch = mainSwitch;
    
    if (!_mainSwitch)
    {
        [self hideControlPanel];
    }else
    {
        [self showControlPanel];
    }
}

- (void)fpsViewDidAppear:(BOOL)animated
{
    [self fpsViewDidAppear:animated];
    [[DJFPSManager sharedManager] startRecordType:self];
}

- (void)fpsViewDidDisappear:(BOOL)animated
{
    [self fpsViewDidDisappear:animated];
    [[DJFPSManager sharedManager] stopRecrod];
}

- (void)stopRecrod
{
    if (self.logger) {
        [self.logger stopRecord];
    }
}

- (void)fpsScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self respondsToSelector:@selector(fpsScrollViewWillBeginDragging:)] && [self respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self fpsScrollViewWillBeginDragging:scrollView];
    }
    [DJFPSManager sharedManager].needRecording = YES;
}

- (void)fpsScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
{
    if ([self respondsToSelector:@selector(fpsScrollViewDidEndDragging:willDecelerate:)] && [self respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self fpsScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (!decelerate) {
        [DJFPSManager sharedManager].needRecording = NO;
    }
}

- (void)setNeedRecording:(BOOL)needRecording
{
    _needRecording = needRecording;
    [self.logger setRecorderPause:!needRecording];
}

- (void)fpsScrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if ([self respondsToSelector:@selector(fpsScrollViewDidEndDecelerating:)] && [self respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self fpsScrollViewDidEndDecelerating:scrollView];
    }
    
    [DJFPSManager sharedManager].needRecording = NO;
}

- (void)recoverSwizzledMethod:(SEL)originSEL swizzled:(SEL)swizzlSEL Class:(Class)class
{
    Method originalMethod = class_getInstanceMethod(class, originSEL);
    Method swizzledMethod = class_getInstanceMethod(class, swizzlSEL);
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
}

- (void)swizzledMethod:(SEL)originSEL swizzled:(SEL)swizzlSEL Class:(Class)class
{
    Method originalMethod = class_getInstanceMethod(class, originSEL);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzlSEL);
    BOOL didAddMethod = class_addMethod(class, originSEL, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod)
    {
        IMP originalIMP = method_getImplementation(originalMethod);
        class_addMethod(class, swizzlSEL, originalIMP, method_getTypeEncoding(originalMethod));
    }
    else
    {
        class_addMethod(class, swizzlSEL, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        Method cSwizzledMethod = class_getInstanceMethod(class, swizzlSEL);
        method_exchangeImplementations(originalMethod, cSwizzledMethod);
    }

}

- (void)swizzledViewController
{
    [self swizzledMethod:@selector(viewDidAppear:) swizzled:@selector(fpsViewDidAppear:) Class:NSClassFromString(@"UITableViewController")];
    [self swizzledMethod:@selector(viewDidDisappear:) swizzled:@selector(fpsViewDidDisappear:) Class:NSClassFromString(@"UITableViewController")];
}


- (void)swizzledScrollView
{
    [self swizzledMethod:@selector(scrollViewWillBeginDragging:) swizzled:@selector(fpsScrollViewWillBeginDragging:) Class:[_currentVC class]];
    [self swizzledMethod:@selector(scrollViewDidEndDragging:willDecelerate:) swizzled:@selector(fpsScrollViewDidEndDragging:willDecelerate:) Class:[_currentVC class]];
    [self swizzledMethod:@selector(scrollViewDidEndDecelerating:) swizzled:@selector(fpsScrollViewDidEndDecelerating:) Class:[_currentVC class]];
}

- (void)startRecordType:(id)type_;
{
    if (!self.mainSwitch) {
        return;
    }

    _tmpCacheVC = type_;
    NSString *type = NSStringFromClass([type_ class]);
    _tmpCachetype = type;

}

- (void)hideControlPanel
{
    if (_controlpanel) {
        [_controlpanel setHidden:YES];
        _controlpanel = nil;
    }
    
    [_logger stopRecord];
}

- (void)showControlPanel
{
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    if (_controlpanel == nil) {
        _controlpanel = [[UIWindow alloc]initWithFrame:CGRectMake(screenFrame.size.width/2, screenFrame.size.height - 80, screenFrame.size.width/2, 40)];
        _controlpanel.backgroundColor = [UIColor grayColor];
        _controlpanel.windowLevel = UIWindowLevelStatusBar;
    }
    [_controlpanel makeKeyAndVisible];
    if (_controlButton == nil) {
        _controlButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
        [_controlButton addTarget:self action:@selector(controlButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_controlButton setTitle:@"开启" forState:UIControlStateNormal];
        _controlButton.accessibilityLabel = @"开启";
        [_controlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }
    [_controlpanel addSubview:_controlButton];

    if (_showButton == nil) {
        _showButton = [[UIButton alloc]initWithFrame:CGRectMake(60, 0, 50, 40)];
        [_showButton addTarget:self action:@selector(showButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_showButton setTitle:@"查看" forState:UIControlStateNormal];
        _showButton.accessibilityLabel = @"查看";
        [_showButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [_controlpanel addSubview:_showButton];
}

- (void)showButtonClicked
{
    [DJFPSResultsController show];
    
    
}

- (void)controlButtonClick
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@%@",@"当前：",_tmpCachetype] message:@"可以输入别名如：评论列表" delegate:self cancelButtonTitle:@"不统计" otherButtonTitles:@"开始统计", nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    UITextField *des = [alert textFieldAtIndex:0];
    des.accessibilityLabel = @"logname";
    des.placeholder = @"描述，如：评论列表";
    UITextField *seconds = [alert textFieldAtIndex:1];
    seconds.secureTextEntry = NO;
    seconds.placeholder = @"时长(秒)，默认30秒";
    seconds.accessibilityLabel = @"logtime";
    seconds.keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
}

- (DJFPSLogger *)logger
{
    if (_logger == nil) {
        _logger = [[DJFPSLogger alloc] initWithStorageClass:[DJFPSBaseStorage class]];
    }
    return _logger;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        UITextField *typeFiled = [alertView textFieldAtIndex:0];
        if (typeFiled.text.length > 0) {
            _tmpCachetype = typeFiled.text;
        }
        UITextField *secondsFiled = [alertView textFieldAtIndex:1];
        NSUInteger second = 0;
        if (secondsFiled.text.length > 0) {
            second = [secondsFiled.text integerValue];
            if (second == 0) {
                second = 30;
            }
        }
        [self activeTimer:second];
    }
}

- (void)activeTimer:(NSUInteger)seconds;
{
    self.needRecording = NO;
    _currentVC = _tmpCacheVC;
    self.type = _tmpCachetype;
    if (_tmpCacheVC == nil) {
        return;
    }
    [self.logger startRecoderWithEstimateTime:seconds RecordOnlyScrolling:YES];

    [self.logger.userInfo setObject:self.type forKey:@"loggertype"];
    
    if (![classMaps containsObject:[_tmpCacheVC class]]) {
        __block NSMutableArray *removeClasses = [[NSMutableArray alloc] initWithCapacity:2];
        [classMaps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isSubclassOfClass:[_tmpCacheVC class]] || [[_tmpCacheVC class] isSubclassOfClass:obj]) {
                [removeClasses addObject:obj];
                [self recoverSwizzledMethod:@selector(scrollViewWillBeginDragging:) swizzled:@selector(fpsScrollViewWillBeginDragging:) Class:obj];
                [self recoverSwizzledMethod:@selector(scrollViewDidEndDragging:willDecelerate:) swizzled:@selector(fpsScrollViewDidEndDragging:willDecelerate:) Class:obj];
                [self recoverSwizzledMethod:@selector(scrollViewDidEndDecelerating:) swizzled:@selector(fpsScrollViewDidEndDecelerating:) Class:obj];
            }
        }];
        [classMaps removeObjectsInArray:removeClasses];
        
        [self swizzledScrollView];
        [classMaps addObject:[_tmpCacheVC class]];
    }
}

@end
