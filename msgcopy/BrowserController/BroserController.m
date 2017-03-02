//
//  BroserController.m
//  msgcopy
//
//  Created by wngzc on 15/5/23.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "BroserController.h"
#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>

@interface BroserController ()<UIWebViewDelegate,NJKWebViewProgressDelegate>
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    UIActivityIndicatorView *_indicatior;
    UIWebView *_webView;
    UIToolbar *_toolBar;
    UIBarButtonItem *_lastPage;
    UIBarButtonItem *_nextPage;
    UIBarButtonItem *_refresh;
}
@end

@implementation BroserController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configWebView];
    [self loadRequest];
    [self configBackButton];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)configBackButton
{
    //config some
    UIView*view = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 70, 30)];
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(0, 0, 27, 27);
    UIButton*close = [UIButton buttonWithType:UIButtonTypeCustom];
    close.frame = CGRectMake(40, 0, 27, 27);
    [close setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    [close setImage:[UIImage imageNamed:@"ico_back"] forState:UIControlStateNormal];

    [close addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
  //  back.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    [back setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:back];
    [view addSubview:close];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:view ];
    self.navigationItem.leftBarButtonItem = backItem;
    
}

-(void)configWebView
{
    self.view.bounds = CGRectMake(0, -NAV_H,self.view.width ,self.view.height - NAV_H);
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.bounds.size.height)];
    _webView.scalesPageToFit = YES;//自动对页面进行缩放以适应屏幕
    [self.view addSubview:_webView];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    _indicatior = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatior.hidesWhenStopped = true;
    [self.view addSubview:_indicatior];
    _indicatior.center = CGPointMake(CGRectGetMidX(self.view.frame), self.view.center.y - NAV_H/2);

    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width,44 )];
    _lastPage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_back"] style:UIBarButtonItemStyleDone target:self action:@selector(lastPage:)];
    _nextPage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_back"] style:UIBarButtonItemStyleDone target:self action:@selector(nextPage:)];
    _refresh = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_back"] style:UIBarButtonItemStyleDone target:self action:@selector(refreshPage:)];
    UIBarButtonItem *_space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _toolBar.items = @[_lastPage,_nextPage,_space,_refresh];
    self.automaticallyAdjustsScrollViewInsets = false;
//    _webView.scrollView.contentInset = UIEdgeInsetsMake(NAV_H, 0, 0, 0);
//    _webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(NAV_H, 0, 0, 0);
}
-(void)loadRequest
{
    NSURLRequest* request = [NSURLRequest requestWithURL:_webURL];//创建NSURLRequest
    [_webView loadRequest:request];//加载
}

#pragma mark - webViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [_indicatior startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.canGoBack) {
        _lastPage.enabled = true;
    }else{
        _lastPage.enabled = false;
    }
    if (webView.canGoForward) {
        _nextPage.enabled = true;
    }else{
        _nextPage.enabled = false;
    }
    [_indicatior stopAnimating];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_indicatior stopAnimating];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark--
#pragma mark - NJKWebViewProgressDelegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}
- (void)dealloc{
    
    _webView = nil;
    _progressView = nil;
    _progressProxy = nil;
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [CRRootNavigation().navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}


#pragma mark - actions

# pragma mark - 返回
//关闭按钮
-(void)close:(id)sender{

    [self.navigationController popViewControllerAnimated:true];


}
-(void)goBack:(id)sender{
    //do something
    if(_webView.canGoBack){
        [_webView goBack];
        return;
    }
    [self.navigationController popViewControllerAnimated:true];
}


-(void)lastPage:(id)sender{
    [_webView goBack];
}
-(void)nextPage:(id)sender{
    [_webView goForward];
}
-(void)refreshPage:(id)sender{
    [_webView reload];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
