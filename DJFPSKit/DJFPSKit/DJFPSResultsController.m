//
//  DJFPSResultsController.m
//  FPSExample
//
//  Created by donghuan1 on 16/12/1.
//  Copyright © 2016年 Dwight. All rights reserved.
//

#import "DJFPSResultsController.h"
#import "DJFileManager.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define M_PI 3.14159265358979323846264338327950288
#define kScreenFrame [UIScreen mainScreen].bounds

@interface DJFPSHighChartsView : UIView<UIWebViewDelegate>
@property (nonatomic,strong)UIView *targetView;
@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)UIButton *closeBtn;
@property (nonatomic,strong)JSContext *jsContext;
@property (nonatomic,strong)NSArray *fpsarrs;
@end

@implementation DJFPSHighChartsView
#pragma UI
+ (void)showWebView:(NSArray *)fpsarr
{
    UIWindow *payWindow = [[UIWindow alloc]initWithFrame:kScreenFrame];
    payWindow.windowLevel = UIWindowLevelAlert;
    [payWindow makeKeyAndVisible];
    [DJFPSHighChartsView showIn:payWindow FPSArr:fpsarr];
}


+ (void)showIn:(UIView *)view FPSArr:(NSArray *)fpsarr
{
    DJFPSHighChartsView *payView =  [[DJFPSHighChartsView alloc]initWithArr:fpsarr];
    payView.targetView = view;
    [view addSubview:payView];
    payView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        payView.alpha = 1;
    }];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // 设置javaScriptContext上下文
    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSValue *picCallback = self.jsContext[@"picCallBack"];
    [picCallback callWithArguments:@[_fpsarrs]];
}

- (instancetype)initWithArr:(NSArray *)arr
{
    if (self = [super init]) {
        
        _fpsarrs = [NSArray arrayWithArray:arr];

        //毛玻璃背景
        self.backgroundColor = [UIColor clearColor];
        self.frame = kScreenFrame;
        self.userInteractionEnabled = YES;
        //背景
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(-(kScreenFrame.size.height-kScreenFrame.size.width)/2, (kScreenFrame.size.height-kScreenFrame.size.width)/2, kScreenFrame.size.height,kScreenFrame.size.width)];
        _webView.delegate = self;
        [self addSubview:_webView];
        _webView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _webView.transform = CGAffineTransformIdentity;
            _webView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        } completion:^(BOOL finished) {
        }];

        NSBundle *bundle = [NSBundle bundleForClass:[DJFPSResultsController class]];
        NSURL *bundleUrl = [bundle URLForResource:@"DJFPSKit" withExtension:@"bundle"];
        NSBundle *readBundle = [NSBundle bundleWithURL:bundleUrl];
        NSString * htmlPath = [readBundle pathForResource:@"ShowFPS"
                                                   ofType:@"html"];
        
        NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                        encoding:NSUTF8StringEncoding
                                                           error:nil];
        [self.webView loadHTMLString:htmlCont baseURL:bundleUrl];
        
        self.closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenFrame.size.width - 40, 20, 40, 20)];
        self.closeBtn.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        self.closeBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [self.closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [self.closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeBtn];
    }
    return self;
}

- (void)close{
    [UIView animateWithDuration:0.3 animations:^{
        _webView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.targetView = nil;
    }];
}


@end


@interface DJFPSResultsController ()
{
    NSMutableArray *files;
    
}
@property(nonatomic,strong)UIView *targetView;
@end

@implementation DJFPSResultsController

+ (void)show
{
    UIWindow *showWindow = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    DJFPSResultsController *results = [[DJFPSResultsController alloc]init];
    results.targetView = showWindow;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:results];
    [showWindow setRootViewController:nav];
    showWindow.windowLevel = UIWindowLevelAlert;
    [showWindow makeKeyAndVisible];
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        files = [[NSMutableArray alloc]init];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightButton;
        self.title = @"查看FPS";
        [self setupfiles];
        
    }
    return self;
}

- (void)rightButtonClicked
{
    [self.targetView setHidden:YES];
    self.targetView = nil;
}

- (void)setupfiles
{
    NSFileManager *tmpFileManager=[NSFileManager defaultManager];
    NSDirectoryEnumerator *tmpDirectoryEnumerator;
    NSString *path = [DJFileManager rootFilePath];
    tmpDirectoryEnumerator=[tmpFileManager enumeratorAtPath:path];
    [files removeAllObjects];
    while((path=[tmpDirectoryEnumerator nextObject])!=nil)
    {
        [files addObject:path];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupfiles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resultscell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"resultscell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [files objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fileName = [files objectAtIndex:indexPath.row];
    NSData *jsonData = [DJFileManager dataFor:fileName];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSArray *arr = [jsonObject objectForKey:@"fpsvalue"];
        [DJFPSHighChartsView showWebView:arr];
    }
    
}

@end
