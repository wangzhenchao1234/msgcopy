//
//  MsgHandlerController.m
//  msgcopy
//
//  Created by Gavin on 15/7/10.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MsgOpenHandler.h"
#import "MsgContentController.h"
#import "KxMovieViewController.h"
#import "BroserController.h"
#import "MsgPhotoBrowser.h"
#import "KxMenu.h"
#import "CommentsController.h"
#import "EditMsgController.h"

@interface MsgOpenHandler ()
@property(nonatomic,retain) MBProgressHUD *hudView;
@property(nonatomic,assign) BOOL isInited;
@property(nonatomic,retain)UIBarButtonItem *editeItem;
@property(nonatomic,retain)NSArray *kxmenus;
@property(nonatomic,retain) PubEntity *pub; //投稿

@end

@implementation MsgOpenHandler

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
+(void)openWithMsgID:(NSInteger)msgID placeholderView:(UIView*)placeholder
{
    if (msgID == 0) {
        [CustomToast showMessageOnWindow:@"访问的内容不存在"];
        return;
    }
    MsgOpenHandler *msgControl = [Utility controllerInStoryboard:@"Main" withIdentifier:@"MsgOpenHandler"];
    msgControl.msgid = msgID;
    [CRRootNavigation() pushViewController:msgControl animated:true];
}

+(void)openWithMsg:(ArticleEntity*)msg placeholderView:(UIView*)placeholder
{
    [MsgOpenHandler showMsg:msg];
}
-(void)viewDidAppear:(BOOL)animated
{
    if (!_isInited) {
        _isInited = true;
        if (!_msg&&_msgid!=0) {
            [self getMsg];
            return;
        }
    }
    
    [CRRootNavigation() popViewControllerAnimated:true];
}
/**
 *  取得收藏信息
 */
-(void)getMsg
{
    if (!_hudView) {
        _hudView = [[MBProgressHUD alloc] initWithView:self.view];
        _hudView.removeFromSuperViewOnHide = false;
        [self.view addSubview:_hudView];
    }
    [_hudView show:true];
    [MSGRequestManager Get:kAPIMSG(_msgid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [_hudView hide:true];
        _msg = [ArticleEntity buildInstanceByJson:data];
//        NSLog(@"解析文章数据中的缩略图---%@",_msg.thumbnail);
        
        [self showMsg:_msg];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [_hudView hide:true];
        [CustomToast showMessageOnWindow:msg];
        [CRRootNavigation() popViewControllerAnimated:true];
    }];
    
}
-(void)showWebModal:(ArticleEntity*)msg
{
    MsgContentController *msgCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"MsgContentController"];
    msgCon.msg = msg;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:msgCon];
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    self.navigationItem.rightBarButtonItem = msgCon.navigationItem.rightBarButtonItem;
    self.navigationItem.leftBarButtonItem = msgCon.navigationItem.rightBarButtonItem;
    self.navigationItem.title = msgCon.navigationItem.title;
    
    UIButton *_editeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editeButton.frame = CGRectMake(0, 0, 27, 27);
    [_editeButton setImage:[UIImage imageNamed:@"ic_drop"] forState:UIControlStateNormal];
    [_editeButton addTarget:self action:@selector(showEditeMenu:) forControlEvents:UIControlEventTouchUpInside];
    _editeItem = [[UIBarButtonItem alloc] initWithCustomView:_editeButton];
    self.navigationItem.rightBarButtonItem = _editeItem;
    
    UserEntity * userEntity = [UserDataManager sharedManager].loginUser;
     KxMenuItem *_commentMenu = [KxMenuItem menuItem:@"评论" image:[UIImage imageNamed:@"bt_comment"] target:self action:@selector(commentClicked)];
    
    //如果是本用户发布的投稿，则可以编辑
    if ([_msg.master.userName isEqualToString:userEntity.userName]) {
       KxMenuItem *_editeMenu = [KxMenuItem menuItem:@"编辑" image:[UIImage imageNamed:@"msg_group_edite"] target:self action:@selector(editeClicked)];
          _kxmenus = @[_editeMenu,_commentMenu];
    }else{
            _kxmenus = @[_commentMenu];
    
    }
   
    
    [Utility setTransparentNavigation:nav navBarTransparent:TransParentNavBg];
}

#pragma mark - 编辑

-(void)editeClicked{
    if (_msg) {
        
        EditMsgController *editMsg = [Utility controllerInStoryboard:@"Main" withIdentifier:@"EditMsgController"];
        editMsg.article = _msg;
//        NSLog(@"跳到编辑页面时 ---- %@",_msg.images);
        [self.navigationController pushViewController:editMsg animated:true];
    }
    
    

}

#pragma mark - 评论列表
-(void)commentClicked{
    if (_msg) {
        CommentsController *comment = [Utility controllerInStoryboard:@"Main" withIdentifier:@"CommentsController"];
        comment.article = _msg;
        [self.navigationController pushViewController:comment animated:true];
    }


}


# pragma mark - 显示菜单

-(void)showEditeMenu:(id)sender{
    //do something
    UIButton *button = sender;
    CGRect from = [self.navigationController.navigationBar convertRect:button.frame toView:self.navigationController.view];
    [KxMenu showMenuInView:self.navigationController.view fromRect:from menuItems:_kxmenus];
}


/**
 *  打开投稿
 */

-(void)showMsg:(ArticleEntity*)msg
{
    if(_msg.msgCtype == MSGCtypeYouhuiquan){
        [self showYouhuiquan:msg];
    }else if(_msg.msgCtype == MSGCtypeChoujiang){
        [self showChoujiang:msg];
    }else if(_msg.msgCtype == MSGCtypeBiaodan){
        [self showBiaodan:msg];
    }else if(_msg.msgCtype == MSGCtypeShipin){
        [self showShipin:msg];
    }else if(_msg.msgCtype == MSGCtypeTuji){
        [self showTuji:msg];
    }else if(_msg.msgCtype == MSGCtypeLianjie){
        [self showLianjie:msg];
    }else{
        [self showWebModal:msg];
    }
}

/**
 * 优惠券投稿
 */
-(void)showYouhuiquan:(ArticleEntity*)msg{
    
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    WebAppEntity *app = CRWebAppTitle(@"coupon");
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":msg.content?msg.content:@"{}"};
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
-(void)showChoujiang:(ArticleEntity*)msg{
    
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    WebAppEntity *app = CRWebAppTitle(@"lottery");
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":msg.content?msg.content:@"{}"};
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
-(void)showBiaodan:(ArticleEntity*)msg{
    
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    WebAppEntity *app = CRWebAppTitle(@"form");
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":msg.content?msg.content:@"{}"};
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
-(void)showShipin:(ArticleEntity*)article{
    
    NSArray *videos = article.videos;
    PubEntity *pub = [[PubEntity alloc] init];
    pub.title = article.title;
    pub.article = article;
    if ([videos count]>0) {
        KxMovieViewController *movieVC = [KxMovieViewController movieViewControllerWithPublication:pub parameters:nil];
        [self addChildViewController:movieVC];
        [self.view addSubview:movieVC.view];
        self.navigationItem.rightBarButtonItem = movieVC.navigationItem.rightBarButtonItem;
        self.navigationItem.leftBarButtonItem = movieVC.navigationItem.rightBarButtonItem;
        self.navigationItem.title = movieVC.navigationItem.title;
    }
}
/**
 * 图集投稿
 */
-(void)showTuji:(ArticleEntity*)article{
    
    NSArray *photos = article.imageSet.images;
    if (photos.count>0) {
        MsgPhotoBrowser *browser = [[MsgPhotoBrowser alloc] initWithMsg:article];
        browser.displayActionButton = true;
        browser.enableSwipeToDismiss = false;
        browser.msg = article;
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:browser];
//        nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [CRRootNavigation()  pushViewController:browser animated:true];
    }else{
        [CustomToast showMessageOnWindow:@"您访问的内容不存在"];
    }
}
/**
 * 链接投稿
 */
-(void)showLianjie:(ArticleEntity*)article{
    
    NSArray *urls = article.links;
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
+(void)showMsg:(ArticleEntity*)article
{
    ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
//    
    if(article.msgCtype == MSGCtypeYouhuiquan){
        [MsgOpenHandler showYouhuiquan:article];
    }else if(article.msgCtype == MSGCtypeChoujiang){
        [MsgOpenHandler showChoujiang:article];
    }else if(article.msgCtype == MSGCtypeBiaodan){
        [MsgOpenHandler showBiaodan:article];
    }else if(article.msgCtype == MSGCtypeShipin){
        [MsgOpenHandler showShipin:article];
    }else if(article.msgCtype == MSGCtypeTuji){
        [MsgOpenHandler showTuji:article];
    }else if(article.msgCtype == MSGCtypeLianjie){
        [MsgOpenHandler showLianjie:article];
    }else{
        [MsgOpenHandler showWebModal:article];
    }
    ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
}
/**
 * 优惠券投稿
 */
+(void)showYouhuiquan:(ArticleEntity*)msg{
    
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    WebAppEntity *app = CRWebAppTitle(@"coupon");
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":msg.content?msg.content:@"{}"};
    [CRRootNavigation() pushViewController:webAppCon animated:true];
    
}
/**
 * 抽奖投稿
 */
+(void)showChoujiang:(ArticleEntity*)msg{
    
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    WebAppEntity *app = CRWebAppTitle(@"lottery");
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":msg.content?msg.content:@"{}"};
    [CRRootNavigation() pushViewController:webAppCon animated:true];
}
/**
 * 表单投稿
 */
+(void)showBiaodan:(ArticleEntity*)msg{
    
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    WebAppEntity *app = CRWebAppTitle(@"form");
    webAppCon.appid = app.aid;
    webAppCon.params = @{@"init_data":msg.content?msg.content:@"{}"};
    [CRRootNavigation() pushViewController:webAppCon animated:true];
    
}
/**
 * 视频投稿
 */
+(void)showShipin:(ArticleEntity*)article{
    
    NSArray *videos = article.videos;
    if ([videos count]>0) {
        KxMovieViewController *movieVC = [KxMovieViewController movieViewControllerWithMsg:article parameters:nil];
        [CRRootNavigation() pushViewController:movieVC animated:true];
    }
}
/**
 * 图集投稿
 */
+(void)showTuji:(ArticleEntity*)article{
    
    NSArray *photos = article.imageSet.images;
    if (photos.count>0) {
        
        MsgPhotoBrowser *browser = [[MsgPhotoBrowser alloc] initWithMsg:article];
        browser.displayActionButton = true;
        browser.msg = article;
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
+(void)showLianjie:(ArticleEntity*)article{
    
    NSArray *urls = article.links;
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
+(void)showWebModal:(ArticleEntity*)article{
    
    MsgContentController *msgCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"MsgContentController"];
    msgCon.msg = article;
    [CRRootNavigation() pushViewController:msgCon animated:true];
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
