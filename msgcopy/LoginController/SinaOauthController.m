//
//  SinaOauthController.m
//  msgcopy
//
//  Created by wngzc on 15/7/16.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "SinaOauthController.h"

#define HomeUrl [NSURL URLWithString:[[NSString stringWithFormat:@"%@client_id=%@&response_type=code&redirect_uri=%@",SinaHomeURL,AppKey_Sina,AppURI_Sina] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]

@interface SinaOauthController ()<UIWebViewDelegate>
@property(nonatomic,retain)UIWebView *webView;
@property(nonatomic,retain)UIActivityIndicatorView *activity;
@property(nonatomic,retain)MBProgressHUD *hudView;
@end

@implementation SinaOauthController

+(void)doOauth:(void (^)(BOOL, id data, NSString *openid))complte target:(id)target{
    
    SinaOauthController *oauth = [[SinaOauthController alloc] init];
    oauth.completeAction = complte;
    UINavigationController *navigation = nil;
    if ([target isKindOfClass:[UINavigationController class]]) {
        navigation = target;
    }else if([target isKindOfClass:[UIViewController class]]){
        UIViewController *vc = target;
        if (vc.navigationController) {
            navigation = vc.navigationController;
        }
    }
    if (!navigation) {
        navigation = CRRootNavigation();
        return;
    }
    [navigation pushViewController:oauth animated:true];
    
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configNavigationItem];
    [self configWebView];
    [self configHudView];
    [self configActivity];
    [self loadRequest];
//    [self configNavigationItem];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [Utility setDefaultNavigation:self.navigationController];
}
/*
 * activity
 */
-(void)configActivity
{
    //config some
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activity.hidesWhenStopped = true;
    [_activity stopAnimating];
    [self.view addSubview:_activity];
    _activity.center = self.view.center;
    
}
/*
 * hud
 */

-(void)configHudView
{
    //config some
    _hudView = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    _hudView.removeFromSuperViewOnHide = false;
    [_hudView hide:true];
    [AppWindow addSubview:_hudView];
}
-(void)configNavigationItem
{
    //config some
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 27, 27);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    [button setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
}

/*
 * webView
 */

-(void)configWebView
{
    //config some
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    _webView.scalesPageToFit = true;
    _webView.scrollView.backgroundColor = [UIColor colorFromHexRGB:@"f8f8f8"];
    [self.view addSubview:_webView];
}
-(void)loadRequest
{
    NSURLRequest *request = [NSURLRequest requestWithURL:HomeUrl];
    [_webView loadRequest:request];
}

# pragma mark - actions
-(void)goBack:(id)sender
{
    if (self.completeAction) {
        self.completeAction(false,nil,@"用户取消");
    }
    [self.navigationController popViewControllerAnimated:true];
}

# pragma mark - webViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activity startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
    [_activity stopAnimating];
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *url = [NSString stringWithFormat:@"%@",[request.URL absoluteString]];
    if ([url rangeOfString:@"code="].location!=NSNotFound){
        NSMutableString *str = [url mutableCopy];
        NSRange range        = [str rangeOfString:@"code="];
        NSString *code       = [str substringFromIndex:range.location+range.length];
        [_activity stopAnimating];
        [self performSelectorOnMainThread:@selector(doOauth:) withObject:code waitUntilDone:true];
        return NO;
    }
    return YES;
    
}
-(void)doOauth:(NSString*)code{
 
    [_hudView show:true];
    CRWeekRef(self);
    NSDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:CRString(@"%@",AppKey_Sina),@"client_id",AppSecret_Sina,@"client_secret",@"authorization_code",@"grant_type",AppURI_Sina,@"redirect_uri",code,@"code",nil];
    [MSGRequestManager MKPost:SinaOAuthURL params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [_hudView hide:true];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        /*
         "access_token" = "2.00ErawUDOppu3Cffb3298138mIX2ZB";
         "expires_in" = 653032;
         "remind_in" = 653032;
         uid = 3205653274;
         */
        if (CRJSONIsDictionary(result)) {
            NSString *access_token = [Utility dictionaryValue:result forKey:@"access_token"];
            CRUserSetObj(access_token,CRString(@"%@_sina_token",kCurUserName));
            NSString *uid = [Utility dictionaryNullValue:result forKey:@"uid"];
            NSString *tokenUrl = [NSString stringWithFormat:@"%@",SinaUserInfo];
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:access_token,@"access_token",uid,@"uid", nil];
            [MSGRequestManager Get:tokenUrl params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [LocalManager storeObject:data forKey:@"sina_user_info"];
                if (_completeAction) {
                    _completeAction(true,result,nil);
                }
                [__self.navigationController popViewControllerAnimated:true];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                _completeAction(false,nil,@"授权失败");
                [CustomToast showMessageOnWindow:@"授权失败"];
            }];
           
        }else{
            _completeAction(false,nil,@"授权失败");
            [CustomToast showMessageOnWindow:@"授权失败"];
        }

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [_hudView hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
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
