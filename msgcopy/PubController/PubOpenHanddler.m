//
//  PubOpenHanddler.m
//  msgcopy
//
//  Created by Gavin on 15/5/5.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "PubOpenHanddler.h"
#import "PubController.h"
#import "KxMovieViewController.h"
#import "BroserController.h"
#import "MsgPhotoBrowser.h"

@interface PubOpenHanddler()
@property(nonatomic,retain) MBProgressHUD *hudView;
@property(nonatomic,assign) BOOL isInited;
@end

@implementation PubOpenHanddler

+(void)openWithPubID:(NSInteger)pubID placeholderView:(UIView*)placeholder
{
    if (pubID == 0) {
        [CustomToast showMessageOnWindow:@"访问的内容不存在"];
        return;
    }
    PubOpenHanddler *pubControl = [Utility controllerInStoryboard:@"Main" withIdentifier:@"PubOpenHanddler"];
    pubControl.pubid = pubID;
    if (LoginState) {
        [ScoreUserActionManager doUserAction:USER_UABROWSE_ACTION user:kCurUser.userName currentStatus:true success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            NSLog(@"浏览投稿积分++");
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            NSLog(@"%@",msg);
        }];
    }
    [CRRootNavigation() pushViewController:pubControl animated:true];
}

+(void)openWithPub:(PubEntity*)pub placeholderView:(UIView*)placeholder
{
    [PubOpenHanddler showPub:pub];
    if (LoginState) {
        [ScoreUserActionManager doUserAction:USER_UABROWSE_ACTION user:kCurUser.userName currentStatus:true success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            NSLog(@"浏览投稿积分++");
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            NSLog(@"%@",msg);
        }];
    }
}
-(void)viewDidLoad
{
    [super viewDidLoad];
}
-(void)viewDidAppear:(BOOL)animated
{
    if (!_isInited) {
        _isInited = true;
        if (!_pub&&_pubid!=0) {
            [self getPub];
            //            return;
        }
    }
    
    //    [CRRootNavigation() popViewControllerAnimated:true];
}
/**
 *  取得投稿信息
 */
-(void)getPub
{
    if (!_hudView) {
        _hudView = [[MBProgressHUD alloc] initWithView:self.view];
        _hudView.removeFromSuperViewOnHide = false;
        [self.view addSubview:_hudView];
    }
    [_hudView show:true];
    [MSGRequestManager Get:kAPIPub(_pubid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [_hudView hide:true];
        _pub = [PubEntity buildInstanceByJson:data];
        [self showPub:_pub];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [_hudView hide:true];
        [CustomToast showMessageOnWindow:msg];
        [CRRootNavigation() popViewControllerAnimated:true];
    }];
    
}
-(void)showWebModal:(PubEntity*)pub
{
    PubController *pubCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"PubController"];
    pubCon.pub = pub;
    UIViewController *vc = [[UIViewController alloc] init];
    [self addChildViewController:vc];
    [self addChildViewController:pubCon];
    [self.view addSubview:vc.view];
    [self transitionFromViewController:vc toViewController:pubCon duration:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        self.navigationItem.rightBarButtonItem = pubCon.navigationItem.rightBarButtonItem;
        self.navigationItem.title = pubCon.navigationItem.title;
        self.navigationItem.titleView = pubCon.navigationItem.titleView;
    }];
}
/**
 *  打开投稿
 */

-(void)showPub:(PubEntity*)pub
{
    if(pub.article.msgCtype == MSGCtypeYouhuiquan){
        [self showYouhuiquan:pub];
    }else if(pub.article.msgCtype == MSGCtypeChoujiang){
        [self showChoujiang:pub];
    }else if(pub.article.msgCtype == MSGCtypeBiaodan){
        [self showBiaodan:pub];
    }else if(pub.article.msgCtype == MSGCtypeShipin){
        [self showShipin:pub];
    }else if(pub.article.msgCtype == MSGCtypeTuji){
        [self showTuji:pub];
    }else if(pub.article.msgCtype == MSGCtypeLianjie){
        [self showLianjie:pub];
    }else{
        [self showWebModal:pub];
    }
}

/**
 * 优惠券投稿
 */
-(void)showYouhuiquan:(PubEntity*)pub{
    WebAppEntity *app = CRWebAppTitle(@"coupon");
    if (app.isRequirelogin&&!LoginState) {
        CRWeekRef(self);
        [GVAlertView showAlert:nil message:@"此功能需要登录,是否登录？" confirmButton:@"登录" action:^{
            LoginController *loginVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LoginController"];
            loginVC.loginCallBack = ^(BOOL result){
                [__self showYouhuiquan:pub];
            };
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [CRRootNavigation() presentViewController:nav animated:true completion:nil];
            
        } cancelTitle:@"以后再说" action:^{
            [__self.navigationController popViewControllerAnimated:true];
        }];        return;
    }
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":pub.article.content?pub.article.content:@"{}"};
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webAppCon];
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    self.navigationItem.rightBarButtonItem = webAppCon.navigationItem.rightBarButtonItem;
    self.navigationItem.leftBarButtonItem = webAppCon.navigationItem.rightBarButtonItem;
    self.navigationItem.title = webAppCon.navigationItem.title;
    [Utility setTransparentNavigation:nav navBarTransparent:TransParentNavBg];
}

/**
 * 抽奖投稿
 */
-(void)showChoujiang:(PubEntity*)pub{
    WebAppEntity *app = CRWebAppTitle(@"lottery");
    if (app.isRequirelogin&&!LoginState) {
        CRWeekRef(self);
        [GVAlertView showAlert:nil message:@"此功能需要登录,是否登录？" confirmButton:@"登录" action:^{
            LoginController *loginVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LoginController"];
            loginVC.loginCallBack = ^(BOOL result){
                [__self showChoujiang:pub];
            };
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [CRRootNavigation() presentViewController:nav animated:true completion:nil];
            
        } cancelTitle:@"以后再说" action:^{
            [__self.navigationController popViewControllerAnimated:true];
        }];
        return;
    }
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":pub.article.content?pub.article.content:@"{}"};
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webAppCon];
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    self.navigationItem.rightBarButtonItem = webAppCon.navigationItem.rightBarButtonItem;
    self.navigationItem.leftBarButtonItem = webAppCon.navigationItem.rightBarButtonItem;
    self.navigationItem.title = webAppCon.navigationItem.title;
    [Utility setTransparentNavigation:nav navBarTransparent:TransParentNavBg];
}

/**
 * 表单投稿
 */
-(void)showBiaodan:(PubEntity*)pub{
    
    WebAppEntity *app = CRWebAppTitle(@"form");
    if (app.isRequirelogin&&!LoginState) {
        CRWeekRef(self);
        [GVAlertView showAlert:nil message:@"此功能需要登录,是否登录？" confirmButton:@"登录" action:^{
            LoginController *loginVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LoginController"];
            loginVC.loginCallBack = ^(BOOL result){
                [__self showBiaodan:pub];
            };
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [CRRootNavigation() presentViewController:nav animated:true completion:nil];
            
        } cancelTitle:@"以后再说" action:^{
            [__self.navigationController popViewControllerAnimated:true];
        }];
        return;
    }
    
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":pub.article.content?pub.article.content:@"{}"};
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webAppCon];
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    self.navigationItem.rightBarButtonItem = webAppCon.navigationItem.rightBarButtonItem;
    self.navigationItem.leftBarButtonItem = webAppCon.navigationItem.rightBarButtonItem;
    self.navigationItem.title = webAppCon.navigationItem.title;
    [Utility setTransparentNavigation:nav navBarTransparent:TransParentNavBg];
}
/**
 * 视频投稿
 */
-(void)showShipin:(PubEntity*)pub{
    
    NSArray *videos = pub.article.videos;
    if ([videos count]>0) {
        [self.navigationController popViewControllerAnimated:false];
        KxMovieViewController *movieVC = [KxMovieViewController movieViewControllerWithPublication:pub parameters:nil];
        //        [self addChildViewController:movieVC];
        [CRRootNavigation() pushViewController:movieVC animated:false];
        //        [self.view addSubview:movieVC.view];
        //        movieVC.view.bounds = CGRectMake(0, 0, self.view.width, self.view.height);
        //        movieVC.view.frame = CGRectMake(0, 0, self.view.width, self.view.height);
        //        self.view.bounds = CGRectMake(0, 0, self.view.width, self.view.height);
        //        movieVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        //        self.navigationItem.rightBarButtonItem = movieVC.navigationItem.rightBarButtonItem;
        //        self.navigationItem.leftBarButtonItem = movieVC.navigationItem.rightBarButtonItem;
        //        self.navigationItem.title = movieVC.navigationItem.title;
    }
}
/**
 * 图集投稿
 */
-(void)showTuji:(PubEntity*)pub{
    
    NSArray *photos = pub.article.imageSet.images;
    if (photos.count>0) {
        [self.navigationController popViewControllerAnimated:false];
        
        MsgPhotoBrowser *browser = [[MsgPhotoBrowser alloc] initWithPub:pub];
        browser.displayActionButton = true;
        browser.pub = pub;
        browser.enableSwipeToDismiss = false;
        [CRRootNavigation() pushViewController:browser animated:false];
        
        //        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:browser];
        //        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //        [CRRootNavigation() presentViewController:nav animated:YES completion:^{
        //            [CRRootNavigation() popViewControllerAnimated:false];
        //        }];
        //        UIViewController *plc = [[UIViewController alloc] init];
        //        [self addChildViewController:plc];
        //        [self.view addSubview:plc.view];
        //        [self addChildViewController:browser];
        //        [self transitionFromViewController:plc toViewController:browser duration:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        //            self.navigationItem.leftBarButtonItem = browser.navigationItem.leftBarButtonItem;
        //            self.navigationItem.title = browser.navigationItem.title;
        //            self.navigationItem.titleView = browser.navigationItem.titleView;
        //        }];
    }else{
        [CustomToast showMessageOnWindow:@"您访问的内容不存在"];
    }
}
/**
 * 链接投稿
 */
-(void)showLianjie:(PubEntity*)pub{
    
    NSArray *urls = pub.article.links;
    if (urls.count>0) {
        NSString *url = urls[0];
        [MSGTansitionManager openLink:url];
        
    }else{
        [CustomToast showMessageOnWindow:@"您访问的内容不存在"];
    }
    
}



/**
 *  打开投稿
 */
+(void)showPub:(PubEntity*)pub
{
    ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
    
    if(pub.article.msgCtype == MSGCtypeYouhuiquan){
        [PubOpenHanddler showYouhuiquan:pub];
    }else if(pub.article.msgCtype == MSGCtypeChoujiang){
        [PubOpenHanddler showChoujiang:pub];
    }else if(pub.article.msgCtype == MSGCtypeBiaodan){
        [PubOpenHanddler showBiaodan:pub];
    }else if(pub.article.msgCtype == MSGCtypeShipin){
        [PubOpenHanddler showShipin:pub];
    }else if(pub.article.msgCtype == MSGCtypeTuji){
        [PubOpenHanddler showTuji:pub];
    }else if(pub.article.msgCtype == MSGCtypeLianjie){
        [PubOpenHanddler showLianjie:pub];
    }else{
        [PubOpenHanddler showWebModal:pub];
    }
    ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
}
/**
 * 优惠券投稿
 */
+(void)showYouhuiquan:(PubEntity*)pub{
    WebAppEntity *app = CRWebAppTitle(@"coupon");
    if (app.isRequirelogin&&!LoginState) {
        [LoginHandler showLoginControllerFromController:CRRootNavigation() complete:^(BOOL loginState) {
            [PubOpenHanddler showYouhuiquan:pub];
        }];
        return;
    }
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":pub.article.content?pub.article.content:@"{}"};
    [CRRootNavigation() pushViewController:webAppCon animated:true];
    
}
/**
 * 抽奖投稿
 */
+(void)showChoujiang:(PubEntity*)pub{
    WebAppEntity *app = CRWebAppTitle(@"lottery");
    if (app.isRequirelogin&&!LoginState) {
        [LoginHandler showLoginControllerFromController:CRRootNavigation() complete:^(BOOL loginState) {
            [PubOpenHanddler showChoujiang:pub];
        }];
        return;
    }
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":pub.article.content?pub.article.content:@"{}"};
    [CRRootNavigation() pushViewController:webAppCon animated:true];
}
/**
 * 表单投稿
 */
+(void)showBiaodan:(PubEntity*)pub{
    WebAppEntity *app = CRWebAppTitle(@"form");
    if (app.isRequirelogin&&!LoginState) {
        [LoginHandler showLoginControllerFromController:CRRootNavigation() complete:^(BOOL loginState) {
            [PubOpenHanddler showBiaodan:pub];
        }];
        return;
    }
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":pub.article.content?pub.article.content:@"{}"};
    [CRRootNavigation() pushViewController:webAppCon animated:true];
    
}
/**
 * 视频投稿
 */
+(void)showShipin:(PubEntity*)pub{
    
    NSArray *videos = pub.article.videos;
    if ([videos count]>0) {
        KxMovieViewController *movieVC = [KxMovieViewController movieViewControllerWithPublication:pub parameters:nil];
        [CRRootNavigation() pushViewController:movieVC animated:true];
    }else{
        [CustomToast showMessageOnWindow:@"您访问的视频不存在"];
    }
}
/**
 * 图集投稿
 */
+(void)showTuji:(PubEntity*)pub{
    
    NSArray *photos = pub.article.imageSet.images;
    if (photos.count>0) {
        
        MsgPhotoBrowser *browser = [[MsgPhotoBrowser alloc] initWithPub:pub];
        browser.displayActionButton = true;
        browser.pub = pub;
        browser.enableSwipeToDismiss = false;
        //        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:browser];
        //        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //        [CRRootNavigation() presentViewController:nav animated:YES completion:^{
        //        }];
        [CRRootNavigation() pushViewController:browser animated:true];
        
    }else{
        [CustomToast showMessageOnWindow:@"您访问的内容不存在"];
    }
}
/**
 * 链接投稿
 */
+(void)showLianjie:(PubEntity*)pub{
    
    NSArray *urls = pub.article.links;
    if (urls.count>0) {
        NSString *url = urls[0];
        [MSGTansitionManager openLink:url];
        
    }else{
        [CustomToast showMessageOnWindow:@"您访问的内容不存在"];
    }
    
}
/**
 * 模板投稿
 */
+(void)showWebModal:(PubEntity*)pub{
    
    PubController *pubCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"PubController"];
    pubCon.pub = pub;
    [CRRootNavigation() pushViewController:pubCon animated:true];
}


@end
