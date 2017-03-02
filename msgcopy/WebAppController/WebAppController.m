//
//  WebAppController.m
//  msgcopy
//
//  Created by Gavin on 15/4/14.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "WebAppController.h"
#import "UPPayPlugin.h"
#import "UPPayPluginDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "AlixPayOrder.h"
#import "DataSigner.h"
#import "UnionPay.h"
#import "UserCardsController.h"
#import "WXApi.h"
#import "DataVerifier.h"
#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>
#import "AppDelegate.h"
#import <JavaScriptCore/JavaScriptCore.h>
#define WebAppLoginUrl @"http://app.msgcopy.net/accounts/login/?next=/"
#import "SBJsonParser.h"
#import "ShareView.h"
@interface WebAppController ()<UIWebViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NJKWebViewProgressDelegate>
{
    
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    
    WebAppEntity *_app;
    BOOL _canGoBack;
    BOOL _canRefresh;
    
    NSString *_payFailed;
    NSString *_paySuccess;
    
    NSString *_successCallBack;
    NSString *_failedCallBack;
    
    NSString *_tBtnJsHandler;
    UIButton *_payTopBtn;
    
    
    NSString*_order_id;
    NSString*_total_price;
    NSArray*_payarray;
    NSString*_loadUrl;
    NSInteger _isFirstGoBack;
    UIButton*_close;
    
}
@property(nonatomic,retain) UIActivityIndicatorView *activityView;
@property(nonatomic,retain) MBProgressHUD *hudView;
@end

@implementation WebAppController

- (void)viewDidLoad {
    [super viewDidLoad];
   // [self setBackButton:nil];
    _isFirstGoBack = 0;
    [self loadRequest];
    [self configBackButton];
    self.automaticallyAdjustsScrollViewInsets = false;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CRRootNavigation().navigationBar addSubview:_progressView];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}
-(void)dealloc
{
    _callBackAction = nil;
    _goBackAction = nil;
    _webView = nil;
    
}
-(MBProgressHUD*)hudView
{
    if (!_hudView) {
        _hudView = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        _hudView.removeFromSuperViewOnHide = false;
        [_hudView hide:true];
        [self.view addSubview:_hudView];
    }
    return _hudView;
}
/**
 *  webView
 *
 *  @return webView
 */

-(UIWebView*)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.scalesPageToFit = true;
        _webView.delegate = self;
        _webView.dataDetectorTypes = 0;
        _webView.backgroundColor = [UIColor colorFromHexRGB:@"f8f8f8"];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view insertSubview:_webView atIndex:0];
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _webView.delegate = _progressProxy;
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
        CGFloat progressBarHeight = 2.f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _webView;
}
-(void)configerUIWindow{



}
/**
 *  activity
 *
 *  @return activityview
 */
-(void)configBackButton
{
    //config some
    UIView*view = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 70, 30)];
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(0, 0, 27, 27);
    _close = [UIButton buttonWithType:UIButtonTypeCustom];
    _close.frame = CGRectMake(40, 0, 27, 27);
    [_close setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    [_close setImage:[UIImage imageNamed:@"ico_back"] forState:UIControlStateNormal];
    
    [_close addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    //  back.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    [back setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:back];
    [view addSubview:_close];
    _close.hidden = YES;
//    UIView*rightView = [[UIView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-58, 0, 24, 24)];
//    rightView.backgroundColor = [UIColor redColor];
    
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:view ];
    self.navigationItem.leftBarButtonItem = backItem;
    if([_app.systitle isEqualToString:@"myshopstore"]|| _shoplist == 1){
        UIButton*rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-58, 0, 24, 24);
        [rightButton setImage:[UIImage imageNamed:@"bt_share"] forState:UIControlStateNormal];
        //rightButton.backgroundColor = [UIColor redColor];
        // [rightView addSubview:rightButton];
        [rightButton addTarget:self action:@selector(sendWeiXinMessage) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightItem;

    }
    
}
-(void)sendWeiXinMessage{

    ShareView *share = [ShareView sharedView];
    share.webView = self.webView;
    share.title = _sharetitle;
    share.desr =_desr;
    share.imgUrl = _imgUrl;
    share.link = _link;
    share.loadUrl = _loadUrl;
    NSLog(@"%@",_imgUrl);
    NSLog(@"%@",_desr);
    NSLog(@"%@",_sharetitle);

    share.isH5Share = 1;
    [ShareView show:nil];
}
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
-(void)goBack:(id)sender{
    //do something
    ++_isFirstGoBack;
    if(_webView.canGoBack){
        [_webView goBack];
        if (_isFirstGoBack == 1) {
            _close.hidden = NO;
        }
        return;
    }
    [self.navigationController popViewControllerAnimated:true];
}


-(UIActivityIndicatorView*)activityView
{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.center = self.view.center;
        _activityView.hidesWhenStopped = true;
        [self.view insertSubview:_activityView aboveSubview:_webView];
        [_activityView stopAnimating];
    }
    return _activityView;
}
# pragma mark - 传递appid

-(void)setAppid:(NSInteger)appid
{
    _appid = appid;
    _app = CRWebAppID(_appid);
}

# pragma mark - 设置返回按钮

/**
 *  设置返回按钮
 *
 *  @param image 返回按钮图片
 */
-(void)setBackButton:(NSString *)image{
    
    [self setBackButton:@"ic_back" action:@selector(goBack:event:) target:self];
    
}

# pragma mark - 返回事件

/**
 * 返回
 *
 *  @param sender sender description
 */
//-(void)goBack:(id)sender{
//    
//    if (_canGoBack==YES) {
//        
//        [self.webView stringByEvaluatingJavaScriptFromString:@"GoBack()"];
//        return;
//    }
//    [self.navigationController popViewControllerAnimated:YES];
//}

# pragma mark - 返回事件
//关闭按钮
-(void)close:(id)sender{
    
    [self.navigationController popViewControllerAnimated:true];
    
    
}


-(void)goBack:(id)sender event:(UIEvent*)event{
    UITouch *touch = [[event allTouches] anyObject];
    if (touch.tapCount>1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self goBack:nil];
}

# pragma mark - 设置返回按钮

-(void)setBackButton:(NSString*)image action:(SEL)action target:(id)target{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 27, 27);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backBarButton;
}

# pragma mark - 加载内容

/**
 *  加载内容
 */
-(void)loadRequest{
    _canRefresh = NO;
    _canGoBack = NO;
    if ((!_app.url || _app.url.length == 0) && _shoplist!=1) {
        
    NSString*url = [NSString stringWithFormat:@"http://w-33676-26771-37806.13922418239.sites.cn83.qifeiye.com/?page_id=17922&qfy_preview=1"];
        
    NSURL *loadUrl = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:loadUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [[self webView] loadRequest:request];
        [GCookieManager setCookie:url];

    }else if([_app.systitle isEqualToString:@"myshopstore"]|| _shoplist == 1){
//        [MSGRequestManager Get:GetChannel params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//            NSArray*array = data;
//            for (NSDictionary*dic in array) {
//                if ([dic[@"platform_id"] intValue]==4) {
//                    NSString*channel = dic[@"title"];
//
//                }
//            }
//            
//        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//            
//        }];
        NSString *url = [NSString stringWithFormat:@"%@?channel_id=%@&shop_id=%d",ShopstoreURL,_channel,self.sid];
        _loadUrl = url;
        NSURL *loadUrl = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:loadUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [[self webView] loadRequest:request];
        NSLog(@"_shoplist=======%ld",_shoplist);
        if (_shoplist !=1) {
            [GCookieManager setCookie:url];
        }else{
            if (LoginState) {
                [GCookieManager setCookie:url];
            }else{

            }
            
        }

      
    }else{
    
        NSString *url = [NSString stringWithFormat:@"%@?%@",_app.url,URL_CHANNEL];
        NSURL *loadUrl = [NSURL URLWithString:url];
        NSURLRequest *request = [NSURLRequest requestWithURL:loadUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [[self webView] loadRequest:request];
        [GCookieManager setCookie:url];
    }
}

#pragma mark - webappDelegate

//开始加载
-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self.activityView startAnimating];
}

//加载结束
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    //    if (isRefreshing == YES) {
    //        isRefreshing = NO;
    //        [self endPullDownRefreshing];
    //    }
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSLog(@"context%@",context);
    //定义好JS要调用的方法, share就是调用的share方法名
    context[@"getH5Data"] = ^() {
        NSArray* args = [JSContext currentArguments];
        NSLog(@"args======%@",args);

        JSValue *jsVal = [args firstObject];
        if ([jsVal.toString isEqualToString:@"wxshare"]) {
            NSString*jsonstring = [NSString stringWithFormat:@"%@",[args lastObject]];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary*dic = [parser objectWithString:jsonstring];
            
            _imgUrl = dic[@"imgUrl"];
            _desr = dic[@"desc"];
            _link = dic[@"link"];
            _sharetitle = dic[@"title"];
  
        }else if([jsVal.toString isEqualToString:@"wxpay"]){
        
            NSString*jsonstring = [NSString stringWithFormat:@"%@",[args lastObject]];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary*dic = [parser objectWithString:jsonstring];
            _total_price = dic[@"total_price"];
            _order_id = dic[@"order_id"];
            _payarray = @[_order_id,_total_price];
            
            [self weixinpay:_payarray];
        }else if ([jsVal.toString isEqualToString:@"weblogout"]){
          
            NSDictionary *keychainUser = [UserDataManager keychainUser];
            NSLog(@"确认退出时的用户信息 --- %@",keychainUser);
            
            [[UserDataManager sharedManager] doLogin:keychainUser success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                    CRBackgroundGCD(^{
                        [[XmppListenerManager sharedManager] disconnect];
                    });
                    
                    [CRRootNavigation() popToRootViewControllerAnimated:YES];
                    
                }];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [CustomToast showMessageOnWindow:msg];
            }];
            

        
        
        }
      
 
    };
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(NAV_H, 0, 0, 0);
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(NAV_H, 0, 0, 0);
    [_activityView stopAnimating];
}
//拦截跳转
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *urlString = [[request URL] absoluteString];
    if ([urlString isEqualToString:WebAppLoginUrl]) {
        if (self.navigationController.viewControllers.count>1) {
            [self.navigationController popViewControllerAnimated:false];
            /**
             *  提示登录
             */
        }
        return false;
    }
    NSArray *urlComps = [urlString componentsSeparatedByString:@"://"];
    if ([urlString beginWith:@"baidumap://"]) {
        if ([[UIApplication sharedApplication] canOpenURL:CRURL(@"baidumap://map/geocoder")]) {
            return true;
        }else{
            [[UIApplication sharedApplication] openURL:CRURL(@"https://itunes.apple.com/cn/app/bai-du-tu-yu-yin-dao-hang/id452186370?mt=8")];
            return false;
        }
    }
    NSMutableArray *args = [NSMutableArray new];
    if ([urlComps count]>1&&![urlComps[0] isEqualToString:@"http"]) {
        NSArray *arguments;
        SEL method = NSSelectorFromString(@"");
        if ([urlComps[1] length]==0) {
            return NO;
        }else{
            arguments = [urlComps[1] componentsSeparatedByString:@"-msgcopy-"];
            NSString *sel =[NSString stringWithFormat:@"%@:",arguments[0]];
            method = NSSelectorFromString(sel);
            
            for (int i = 0; i<arguments.count; i ++) {
                if (i!=0) {
                    NSString *arg = arguments[i];
                    [args addObject:arg];
                }
            }
        }
        if ([self respondsToSelector:method]) {
            NSMutableArray *newArgs = [NSMutableArray new];
            for (int i = 0;i<args.count; i++) {
                NSLog(@"before == %@",args[i]);
                NSString *arg = [[args[i] stringByReplacingOccurrencesOfString:@"MSGPLUSMSG" withString:@"+"] stringByReplacingOccurrencesOfString:@"MSGXXMSG" withString:@"/"];
                NSInteger count = 4 - arg.length%4;
                NSMutableString *str = [[NSMutableString alloc] init];
                //经base64编码的arg长度必须为4的倍数，这里以"="号补齐。查看base64相关资料
                if (count != 4) {
                    for (int i = 0;i<count ;i++ ) {
                        [str appendString:@"="];
                    }
                }
                arg = [arg stringByAppendingString:str];
                NSData *data = [[NSData alloc] initWithBase64EncodedString:arg options:NSDataBase64DecodingIgnoreUnknownCharacters];
                NSString *newArg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (newArg == nil) {
                    continue;
                }
                [newArgs addObject:newArg];
            }
            NSLog(@"after args == %@",newArgs);
            [self performSelectorOnMainThread:method withObject:newArgs waitUntilDone:NO];
            
            return NO;
        }
    }
    return YES;
}

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    if ([_app.systitle isEqualToString:@"myshopstore"]|| _shoplist == 1) {
         [_progressView setProgress:100 animated:YES];
    }else{
    
        [_progressView setProgress:progress animated:YES];

    }
   // [_progressView setProgress:100 animated:YES];

}

# pragma mark - 设置当前标题
-(void)web_set_view_title:(NSArray *)datas{
    self.title = datas[0];
}

# pragma mark - 隐藏loading

-(void)web_hide_loading_dialog:(NSArray *)datas{
    [self.activityView stopAnimating];
}

# pragma mark - 显示loading

-(void)web_show_loading_dialog:(NSArray *)datas{
    [self.activityView startAnimating];
}

# pragma mark - 下拉刷新

-(void)beginPullDownRefreshing{
    if (_canRefresh) {
        [self.webView reload];
    }
}

# pragma mark - 加载完成返回

/**
 *  加载成功
 *
 *  @param data
 */
-(void)web_finish:(id)data{
    
    if (_goBackAction) {
        _goBackAction();
    }else{
        [self.navigationController popViewControllerAnimated:true];
    }
    if (_callBackAction) {
        if ([data count]>0) {
            _callBackAction(data[0]);
            return;
        }
        _callBackAction(nil);
    }
}

#pragma mark - localFunction

#pragma mark - actionsheet代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
//    if (actionSheet.tag == 12345) {
//        if (buttonIndex == 0) {
//            [CRRootNavigation() popViewControllerAnimated:YES];
//        }
//        return;
//    }
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate  = self;
    if (actionSheet.tag == 1) {
        
        if (buttonIndex == 0) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
        }else if(buttonIndex == 1){
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        [self presentViewController:picker animated:YES completion:nil];
        picker = nil;
    }
}

#pragma mark - 相册代理

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        // Get the assets library
        NSString* fileName = [self createImageFileName];
        UIImage* image = [info valueForKey:UIImagePickerControllerOriginalImage];
        UIImage *newImage = nil;
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            NSDictionary *imageMetadata = [info objectForKey:
                                           UIImagePickerControllerMediaMetadata];
            NSInteger oritation = [[imageMetadata valueForKeyPath:@"Orientation"] integerValue];
            UIImage *oImage = [UIImage thumbImage:image];
            image = nil;
            newImage = [UIImage image:oImage rotation:oritation];
            
        }else{
            newImage = [UIImage thumbImage:image];
        }
        NSData *thData = nil;
        if (UIImagePNGRepresentation(newImage) == nil) {
            
            thData = UIImageJPEGRepresentation(newImage, 1);
            
        } else {
            
            thData = UIImagePNGRepresentation(newImage);
        }
        //图片旋转上传
        
        [self hudView].labelText = @"正在上传图片";
        [[self hudView] show:true];
        CRWeekRef(self);
        [UploadManager uploadFile:thData type:@"image" name:fileName success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [[self hudView] hide:true];
            MediaEntity* media = data;
            [__self.webView stringByEvaluatingJavaScriptFromString:CRString(@"%@(%@)",_successCallBack,media.jsonStr)];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [[self hudView] hide:true];
            [__self.webView stringByEvaluatingJavaScriptFromString:CRString(@"%@()",_failedCallBack)];
            
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

# pragma mark - 创建文件名

/**
 *  创建文件名
 *
 *  @return 创建文件名
 */
-(NSString*) createImageFileName
{
    return CRString(@"%@.png",CRUUIDString());
}

# pragma mark - 文件目录

/**
 *  文件目录
 *  @return 文件目录
 */
-(NSString*) getFileDir
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

# pragma mark -  打开投稿

/**
 *  打开投稿
 *
 *  @param data 投稿
 */
-(void)showArticleWithData:(PubEntity*)data{
    
    [PubOpenHanddler openWithPub:data placeholderView:nil];
    
}


#pragma marl -actions


# pragma mark - 代理请求数据

/**
 *
 *  利用客户端做http请求，用于跨域 post ，delete 等(×)
 *  参数:
 *  callback:返回函数，客户端会掉该方法，以json的形式返回response
 *  ulr:需要请求的地址
 *  data:请求的时附加的数据
 *  data:function callback(response){
 *
 */
-(void)web_http_proxy:(NSArray*)datas{
    
    NSDictionary *http_method = @{@"0":@"GET",@"1":@"POST",@"2":@"PUT",@"3":@"DELETE"};
    NSString *method = [http_method objectForKey:datas[0]];
    NSString* requestUrlString = datas[1];
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:[datas[2] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    if (params.allKeys.count==0) {
        params = nil;
    }
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
    MKNetworkOperation *op = [engine operationWithURLString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:params httpMethod:method];
    [_activityView startAnimating];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        [_activityView startAnimating];
        NSString *json = [[NSString alloc] initWithData:completedOperation.responseData encoding:NSUTF8StringEncoding];
        [self.webView stringByEvaluatingJavaScriptFromString:CRString(@"%@('%@')",datas[3],json)];
    } onError:^(NSError *error) {
        [_activityView startAnimating];
        [CustomToast showMessageOnWindow:error.localizedDescription];
    }];
    [engine enqueueOperation:op];
}

# pragma mark - 初始化完成

/**
 *  初始化完成调用初始化发放和参数
 *
 *  @param datas data
 */

-(void)web_load_finished:(NSArray*)datas{
    
    UserEntity *user = kCurUser;
    MSGAppEntity *app = kCurApp;
    NSArray *webapp_list = [LocalManager objectForKey:kWebAppInfo];
    NSRange range = [URL_CHANNEL rangeOfString:@"channel_id="];
    NSString *channel = [URL_CHANNEL substringFromIndex:range.length];
    NSDictionary *dict = @{
                           @"user_info":@{
                                   @"username":user.userName==nil?@"":user.userName,
                                   @"first_name":user.firstName==nil?@"":user.firstName,
                                   @"head_photo":@{
                                           @"head50":user.head50 == nil?@"":user.head50,
                                           @"head100":user.head100 == nil?@"":user.head100,
                                           @"head320":user.head320 == nil?@"":user.head320}
                                   },
                           @"web_app_info":@{
                                   @"app_id":[NSString stringWithFormat:@"%d",_app.aid],
                                   @"channel_id":channel,@"app_list":webapp_list
                                   },
                           @"device_info":@{
                                   @"app_id":[NSString stringWithFormat:@"%d",app.aid],
                                   @"version":CRAppVersionShort,
                                   @"client":@"ios",
                                   @"network":[Reachability reachabilityForInternetConnection].currentReachabilityStatus == ReachableViaWiFi?@"WIFI":@"WWAN",
                                   @"master":app.master.userName
                                   }
                           };
    NSString *jsonEnvironment = [[[SBJsonWriter alloc] init] stringWithObject:dict];
    jsonEnvironment = [jsonEnvironment stringByReplacingOccurrencesOfString:@"\\\"" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, jsonEnvironment.length)];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"kaokesdk.set_environment('%@')",jsonEnvironment]];
    NSString *_initilizedStr = [Utility dictionaryValue:_params forKey:@"init_data"];
    if (!_initilizedStr) {
        _initilizedStr = @"{}";
    }
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"init('%@')",_initilizedStr]];
    jsonEnvironment = nil;
    dict = nil;
    _canGoBack = YES;
}

# pragma mark - 打开地图

/**
 *  内容页地图
 *
 *  @return
 */
-(void)web_get_location:(NSArray*)data{
    
    NSString *jsMethod = data[0];
    [self showMyCoor:jsMethod];
    
}

# pragma mark - 添加图片

/**
 *  添加素材
 *
 *  @param datas datas
 */
-(void)web_add_pic:(NSArray*)datas{
    
    if ([datas count]>0) {
        _successCallBack = datas[0];
    }
    if ([datas count]>1) {
        _failedCallBack = datas[1];
    }
    [self addImage:nil];
    
}

# pragma mark - 添加图片

/**
 *  添加图片
 *
 *  @param datas datas
 */
- (void)addImage:(id)sender{
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选取" otherButtonTitles:@"拍照", nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
    
}


# pragma mark - 控制台打印debug信息

-(void)web_console_info:(NSArray *)datas{
    if (datas.count > 0)
        NSLog(@"console_Info: %@",datas[0]);
    
}

# pragma mark - 显示我的位置

-(void)showMyCoor:(NSString *)jsMethod{
    
    CGFloat latitude = [LocationManager sharedManager].baiduLocation.coordinate.latitude;
    CGFloat longitude =  [LocationManager sharedManager].baiduLocation.coordinate.longitude;
    [self performSelectorOnMainThread:@selector(showMyCurrentCoor:) withObject:@[jsMethod,[NSString stringWithFormat:@"%f",latitude],[NSString stringWithFormat:@"%f",longitude]] waitUntilDone:YES];
    
}

# pragma mark - 当前位置

-(void)showMyCurrentCoor:(NSArray*)data{
    if (data.count>1) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@,%@)",data[0],data[2],data[1]]];
    }
}

# pragma mark - 复制到剪切板

-(void)web_copy_to_clipboard:(NSArray *)arguments{
    
    NSString *copyStr = [self.webView stringByEvaluatingJavaScriptFromString:@"kaokesdk.clipboard"];;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = copyStr;
    NSString *str = @"已复制到剪切板";
    [CustomToast showMessageOnWindow:str];
    
}

# pragma mark - 打开一级列表

-(void)web_show_limb:(NSArray*)datas{
    NSInteger lid = [datas[0] integerValue];
    if (lid!=0) {
        [MSGTansitionManager openLimbWithID:lid withParams:nil];
        return;
    }
    [CustomToast showMessageOnWindow:@"内容为空"];
    
}

# pragma mark - 打开二级频道

-(void)web_show_leaf:(NSArray*)datas{
    
    id data = CRArrayObject(datas, 0);
    if (data) {
        NSInteger lid = [data integerValue];
        [MSGTansitionManager openLeafWithID:lid withParams:nil];
    }else{
        [CustomToast showMessageOnWindow:@"请求的内容不存在"];
    }
}

# pragma mark - 打开基础功能

-(void)web_show_base:(NSArray *)datas{
    
    if (datas.count >0) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[datas[0] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *cmd = json[@"cmd"];
        BaseTabItemEntity *tab = [[BaseTabItemEntity alloc] initWithType:cmd title:nil icon:nil];
        [tab doAction];
    }
}

# pragma mark - 新开app

-(void)web_open_app_for_rest:(NSArray *)datas{
    /*打开某个app(×)期待返回值
     *参数：
     *datas: app_id:要打开的app_id
     *datas: init_data:初始化用的参数
     *datas: callback:回调函数
     */
    if (datas.count==3) {
        NSInteger appid = [datas[0] integerValue];
        NSString *callBackMethod = [datas[2] length]>0?datas[2]:@"{}";
        NSDictionary *params = @{@"init_data":datas[1]};
        CRWeekRef(self);
        WebCallBackAction callback = ^(id data){
            [__self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@')",callBackMethod,data]];
        };
        WebGoBackAction goBack = ^{
            [CRRootNavigation() popViewControllerAnimated:false];
        };
        [MSGTansitionManager openWebappWithID:appid withParams:params goBack:goBack callBack:callback];
    }
}

# pragma mark - 打开连接

-(void)web_show_link:(NSArray*)datas{
    if (![self checkInternetStatus])
        return;
    if (datas.count>0) {
        NSString *link = datas[0];
        if ([link rangeOfString:@"http://"].location == NSNotFound&&[link rangeOfString:@"https://"].location == NSNotFound) {
            link = [NSString stringWithFormat:@"http://%@",link];
        }
        [MSGTansitionManager openLink:link];
    }
}

# pragma mark - 检查网络状态

-(BOOL)checkInternetStatus{
    if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) {
        [CustomToast showMessageOnWindow:@"网络未连接，请稍后再试"];
        return NO;
    }
    return YES;
}

# pragma mark - 打开webapp

-(void)web_open_app:(id)datas{
    /*打开某个app(×)
     *参数：
     * datas[0]: app_id:要打开的app_id
     * datas[1]: init_data:初始化用的参数
     * datas[2]: is_finish:是否关闭自己
     */
    if (![self checkInternetStatus]) return;
    if ([datas count]==3) {
        NSInteger appid = [datas[0] integerValue];
        NSDictionary *params = nil;
        if ([datas[1] length] > 0) {
            params = @{@"init_data":datas[1]};
        }
        CRWeekRef(self);
        WebCallBackAction callback = ^(id data){
            [__self.webView stringByEvaluatingJavaScriptFromString:data];
        };
        BOOL adjust = [datas[2] boolValue];
        WebGoBackAction goBack = nil;
        if (adjust) {
            goBack = ^{
                NSInteger count = [CRRootNavigation().viewControllers count];
                UIViewController *popVC = __self.navigationController.viewControllers[count - 3];
                [CRRootNavigation() popToViewController:popVC animated:false];
            };
        }
        [MSGTansitionManager openWebappWithID:appid withParams:params goBack:goBack callBack:callback];
    }
}

# pragma mark - 打开表单

-(void)web_get_user_name:(NSArray*)data{
    if (![self checkInternetStatus]) return;
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@')",data[0],kCurUser.userName]];
}

# pragma mark - 播放音频

-(void)web_show_audio:(NSArray *)data{
    [self showaudio:data];
}

# pragma mark - 播放视频

-(void)web_show_video:(NSArray *)data{
    [self playvideo:data];
}

# pragma mark - 打开投稿

-(void)web_show_pub:(NSArray *)data{
    
    NSString *str = data[0];
    if ([str integerValue]==0) {
        [CustomToast showMessageOnWindow:@"对不起您访问的内容不存在"];
        return;
    }
    [MSGTansitionManager openPubWithID:[str integerValue] withParams:nil];
    
}


# pragma mark - 设置顶栏按钮

-(void)web_set_top_button:(NSArray *)datas{
    
    _tBtnJsHandler = datas[1];
    _payTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_payTopBtn sd_setImageWithURL:[NSURL URLWithString:datas[0]] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
        image = nil;
        //        [[SDImageCache sharedImageCache] removeImageForKey:datas[0] fromDisk:NO];
    }];
    [_payTopBtn addTarget:self action:@selector(doJsMethod:) forControlEvents:UIControlEventTouchUpInside];
    _payTopBtn.frame = CGRectMake(0, 0, 22, 22);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_payTopBtn];
    
}

# pragma mark - 隐藏顶栏按钮

-(void)web_hide_top_button:(NSArray*)datas{
    self.navigationItem.rightBarButtonItem = nil;
}

# pragma mark - 执行js脚本
-(void)doJsMethod:(id)sender{
    
    NSString *jsMethod = [NSString stringWithFormat:@"%@()",_tBtnJsHandler];
    [self.webView stringByEvaluatingJavaScriptFromString:jsMethod];
    
}

# pragma mark - 播放视频

-(void)playvideo:(NSArray*)data{
    NSMutableString *strUrl = data[0];
    [MSGTansitionManager playVideo:strUrl title:@"视频"];
}


# pragma mark - 打开音频

-(void)showaudio:(NSArray*)datas{
    NSMutableString *str = datas[0];
    [MSGTansitionManager playAudio:str];
}

# pragma mark - 支付

-(void)web_pay:(NSArray *)datas{
    SEL payMethod = NSSelectorFromString([NSString stringWithFormat:@"%@:",datas[4]]);
    if ([self respondsToSelector:payMethod]) {
        [self performSelector:payMethod withObject:datas];
    }
}

# pragma mark - 支付宝支付

-(void)alipay:(NSArray *)datas
{
    if ([SellerID isEqualToString:@"null"]||[PartnerID isEqualToString:@"null"]||[PartnerPrivKey isEqualToString:@"null"]) {
        [CustomToast showMessageOnWindow:@"对不起，该app暂无支付宝信息"];
        return;
    }
    /*
     *点击获取prodcut实例并初始化订单信息
     */
    NSString *appScheme  = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
    NSString* orderInfo = [self getOrderInfo:datas];
    NSString* signedStr = [self doRsa:orderInfo];
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",orderInfo, signedStr, @"RSA"];
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSString *resultStr = resultDic[@"success"];
        resultStr = [NSString StringDecode:resultStr];
        BOOL result = false;
        if (resultStr&&[resultStr length]>0&&[resultStr rangeOfString:@"true"].location!= NSNotFound) {
            result = true;
        }
        NSInteger code = [resultDic[@"resultStatus"] integerValue];
        if (code == 9000||result)
        {
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()",_paySuccess]];
        }else{
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()",_payFailed]];
            
        }
        NSLog(@"reslut = %@",resultDic);
    }];
    
}

# pragma mark - 银联支付

-(void)unionpay:(NSArray*)datas{
    
    NSString *orderAmount = datas[0];
    NSString *num = datas[1];
    [num stringByReplacingOccurrencesOfString:@"-" withString:@"" options:NSLiteralSearch
                                        range:NSMakeRange(0, [num length])];
    NSString *orderNumber = num;
    NSString *orderDescr = datas[2];
    _paySuccess = datas[6];
    _payFailed = datas[7];
    
    /*
     测试数据
     ServiceData *data = [ServiceData new];
     data.data= @"201502021446297225608";
     [UnionPay doUnionPay:data delegate:self];
     */
    NSDictionary *params = @{
                             @"orderId":orderNumber,
                             @"orderDesc":orderDescr,
                             @"txnAmt":orderAmount
                             };
    [self hudView].labelText = @"获取流水号...";
    [[self hudView] show:true];
    CRWeekRef(self);
    [MSGRequestManager MKPost:kAPIUnionPayOrder(kCurApp.aid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [[self hudView] hide:true];
        NSString *num = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        num =[num stringByReplacingOccurrencesOfString:@"\"" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [num length])];
        NSLog(@"tn_num == %@",num);
        [UnionPay doUnionPay:num delegate:__self];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [[self hudView] hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}


# pragma mark - 银联支付结果

-(void)UPPayPluginResult:(NSString *)result
{
    //    NSString* msg = [NSString stringWithFormat:kResult, result];
    if ([result isEqualToString:@"success"]) {
        
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()",_paySuccess]];
        
    }else{
        
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()",_payFailed]];
        
    }
    
}
# pragma mark - 微信支付

-(void)weixinpay:(NSArray*)datas
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
    
        if (datas.count==2) {
            
            NSString*order_id = [datas firstObject];
            NSString*total_price = [datas lastObject];
            [self hudView].labelText = @"获取订单信息...";
            [[self hudView] show:true];
            NSDictionary *params = @{@"app":CRString(@"%d",kCurAppID),@"out_trade_no":order_id?order_id:@"",@"total_fee":CRString(@"%d",(int)([total_price floatValue]*100))};
            [MSGRequestManager Post:kAPIWXPay params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [[self hudView] hide:true];
                NSDictionary *payment = data;
                PayReq *request = [[PayReq alloc] init];
                request.partnerId = WXPartnerID;
                request.prepayId= payment[@"prepay_id"];
                request.package = @"Sign=WXPay";
                request.nonceStr= payment[@"nonce_str"];
                request.timeStamp= [payment[@"timestamp"] intValue];
                request.sign= payment[@"sign"];
                [WXApi sendReq:request];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [[self hudView] hide:true];
                [CustomToast showMessageOnWindow:msg];
            }];
            
        }else{
            NSString *orderNumber = datas[1];
            _paySuccess = datas[6];
            _payFailed = datas[7];
            CRWeekRef(self);
            void(^payCallBack)(BOOL result) = ^(BOOL result){
                if (result) {
                    [__self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()",_paySuccess]];
                }else{
                    [__self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()",_payFailed]];
                }
            };
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            delegate.weichatPayCallBack = payCallBack;
            [self hudView].labelText = @"获取订单信息...";
            [[self hudView] show:true];
            NSDictionary *params = @{@"app":CRString(@"%d",kCurAppID),@"out_trade_no":orderNumber?orderNumber:@"",@"total_fee":CRString(@"%d",(int)([datas[0] floatValue]*100))};
            [MSGRequestManager Post:kAPIWXPay params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [[self hudView] hide:true];
                NSDictionary *payment = data;
                PayReq *request = [[PayReq alloc] init];
                request.partnerId = WXPartnerID;
                request.prepayId= payment[@"prepay_id"];
                request.package = @"Sign=WXPay";
                request.nonceStr= payment[@"nonce_str"];
                request.timeStamp= [payment[@"timestamp"] intValue];
                request.sign= payment[@"sign"];
                [WXApi sendReq:request];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [[self hudView] hide:true];
                [CustomToast showMessageOnWindow:msg];
            }];
            
            
        }

    
    }else{
        
        [GVAlertView showAlert:nil message:@"你的iPhone上还没有安装微信,无法使用此功能" confirmButton:@"马上下载" action:^{
            NSString *weiXinLink = @"itms-apps://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:weiXinLink]];
        } cancelTitle:@"取消" action:nil];
    }

}

-(void)huijinpay:(NSArray *)datas{
    
    NSString *orderAmount = datas[0];
    NSString *num = datas[1];
    [num stringByReplacingOccurrencesOfString:@"-" withString:@"" options:NSLiteralSearch
                                        range:NSMakeRange(0, [num length])];
    NSString *orderNumber = num;
    _paySuccess = datas[6];
    _payFailed = datas[7];
    CRWeekRef(self);
    void(^payCallBack)(BOOL result) = ^(BOOL result){
        if (result) {
            [__self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()",_paySuccess]];
        }else{
            [__self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@()",_payFailed]];
        }
    };
    [self performSegueWithIdentifier:@"selectBankCard" sender:@{@"orderNo":orderNumber,@"amount":orderAmount,@"callBack":payCallBack}];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSDictionary *data = sender;
    NSString *orderNo = data[@"orderNo"];
    NSString *amount = data[@"amount"];
    UserCardsController *userCards = (UserCardsController*)segue.destinationViewController;
    userCards.orderNo = orderNo;
    userCards.money = amount;
    userCards.payCallBack = data[@"callBack"];
}

# pragma mark - 拿到订单信息

-(NSString *)getOrderInfo:(NSArray *)datas{
    
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.partner = PartnerID;
    order.seller = SellerID;
    order.tradeNO = datas[1]; //订单ID（由商家自行制定）
    order.productName =  datas[2]; //商品标题
    order.productDescription = datas[3]; //商品描述
    //     NSLog(@"商品标题 == %@,商品描述 == %@",order.productName,order.productDescription);
    order.amount = datas[0]; //商品价格
    order.notifyURL =  datas[5]; //回调URL
    _paySuccess = datas[6];
    _payFailed = datas[7];
    NSLog(@"___________________------------%@",order);
    return [order description];
}

# pragma mark - 订单RSA加密

-(NSString*)doRsa:(NSString*)orderInfo
{
    
    id<DataSigner> signer;
    signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderInfo];
    return signedString;
    
}

# pragma mark - 支付结果

-(void)paymentResultDelegate:(NSString *)result
{
    
    //    NSLog(@"%@",result);
    
}


# pragma mark - 是否支持刷新

-(void)web_set_refresh_enable:(NSArray *)data{
    
    if ([data[0] boolValue]){
        /**
         *  下拉刷新是否可用
         */
        _canRefresh = YES;
        
    }else{
        _canRefresh = NO;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
