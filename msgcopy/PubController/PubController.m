//
//  PubController.m
//  msgcopy
//
//  Created by Gavin on 15/4/14.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "PubController.h"
#import "ShareView.h"
#import "CommentsController.h"
#import "ServerListController.h"
#import "XMContntController.h"
#import "MsgInfo.h"
#import "ShopViewController.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>

#define mwStateImgs 1
#define mwStateImgset 2

@interface PubController ()<UIWebViewDelegate>
{
    NSArray *mwImages; //多图
    NSArray *mwImageSets;//图集
    NSInteger mwState;//打开图片是图集还是多图
}
@end

@implementation PubController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self intilizedDataSource];
    [self cofigWebView];
    [self configToolBarView];
    // Do any additional setup after loading the view.
}
-(void)intilizedDataSource{
    //intilizedDataSource
    mwState = mwStateImgs;
    
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    [_pub.article.images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KaokeImage class]]) {
            KaokeImage *img = obj;
            MWPhoto *photo = [[MWPhoto alloc] initWithURL:CRURL(img.ourl)];
            photo.caption = img.descr;
            [imgs addObject:photo];
        }
    }];
    mwImages = nil;
    mwImages = imgs;
    
    NSMutableArray *imgsets = [[NSMutableArray alloc] init];
    [_pub.article.imageSet.images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KaokeImage class]]) {
            KaokeImage *img = obj;
            MWPhoto *photo = [[MWPhoto alloc] initWithURL:CRURL(img.ourl)];
            photo.caption = img.descr;
            [imgsets addObject:photo];
        }
    }];
    mwImageSets = nil;
    mwImageSets = imgsets;
    
    
    
    

}
/**
 *  初始化webview
 */
-(void)cofigWebView{
    
    [self setAutomaticallyAdjustsScrollViewInsets:true];
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    _webView.dataDetectorTypes = 0;
    [self.view addSubview:_webView];
    _webView.backgroundColor = [UIColor colorFromHexRGB:@"f8f8f8"];
    self.currentFont = 16;
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_webView addSubview:_indicatorView];
    _indicatorView.center = _webView.center;
    _indicatorView.hidesWhenStopped = true;
    [_indicatorView stopAnimating];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/source.bundle",documents];
    NSFileManager *manage = [NSFileManager defaultManager];
    if (![manage fileExistsAtPath:path]) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"source" ofType:@"bundle"];
        [manage copyItemAtPath:bundlePath toPath:path error:nil];
    }
    NSString *modelName = [self webModalName:path];
    NSString *htmlPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/index.html",modelName]];
    if([[self webModalName:path] isEqualToString:@"fuwu"]){
        modelName = @"dianshang";
        htmlPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/index.html",modelName]];
    }
    if (![manage fileExistsAtPath:htmlPath]) {
        modelName = @"hunpai";
        htmlPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/index.html",modelName]];
    }
    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
    [UserActionManager applicationRecordPubRead:_pub];
    [UserActionManager userRecordPubRead:_pub];
    
}
-(NSString*)webModalName:(NSString*)htmlPath{
    NSString *modelName = _pub.article.ctype.systitle;
    return modelName;
}

/**
 *  初始化功能菜单
 */
-(void)configToolBarView
{
    if (_pub.article.msgCtype == MSGCtypeDianshang){
        [self buildTopToolbar];
        return;
    }
    _bottomToolBarView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - App3xfont(44), self.view.width, App3xfont(44))];
    _webView.height -= _bottomToolBarView.height;
    NSArray *toolbarItems = [self intilizedToolbarItems];
    _bottomToolBarView.items = toolbarItems;
    [self.view addSubview:_bottomToolBarView];
    
}
-(NSArray*)intilizedToolbarItems{
    
    NSMutableArray *toolbarItems = [NSMutableArray new];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    if (![WXAppID isEqualToString:@"null"]||[WXAppID length]>0||![AppKey_Sina isEqualToString:@"null"]||[AppKey_Sina length]>0) {
        UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [share setImage:[UIImage imageNamed:@"bt_share"] forState:UIControlStateNormal];
        [share addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:share];
        [toolbarItems addObject:shareItem];
        [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    }
    
    UIButton *like = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [like setImage:[UIImage imageNamed:@"bt_like"] forState:UIControlStateNormal];
    
    
    //点赞
    [like addTarget:self action:@selector(doLike:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *likeItem = [[UIBarButtonItem alloc] initWithCustomView:like];
    [toolbarItems addObject:likeItem];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    UIButton *article = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [article setImage:[UIImage imageNamed:@"bt_collece"] forState:UIControlStateNormal];
    [article addTarget:self action:@selector(doArticle:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *articleItem = [[UIBarButtonItem alloc] initWithCustomView:article];
    [toolbarItems addObject:articleItem];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    if (_pub.article.enableComment) {
        UIButton *comment = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [comment setImage:[UIImage imageNamed:@"bt_comment"] forState:UIControlStateNormal];
        
        
        //评论
        [comment addTarget:self action:@selector(doComment:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] initWithCustomView:comment];
        [toolbarItems addObject:commentItem];
        [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    }
    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [more setImage:[UIImage imageNamed:@"ic_more"] forState:UIControlStateNormal];
    [more addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:more];
    [toolbarItems addObject:moreItem];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    return toolbarItems;
}
/**
 *  初始化电商功能菜单
 */
-(void)buildTopToolbar{
    
    _topMenus = [NSMutableArray new];
    if (![WXAppID isEqualToString:@"null"]||[WXAppID length]>0||![AppKey_Sina isEqualToString:@"null"]||[AppKey_Sina length]>0) {
        KxMenuItem *share = [KxMenuItem menuItem:@"分享" image:[UIImage imageNamed:@"bt_share"] target:self action:@selector(doShare:)];
        [_topMenus addObject:share];
    }
    KxMenuItem *like = [KxMenuItem menuItem:@"点赞" image:[UIImage imageNamed:@"bt_like"] target:self action:@selector(doLike:)];
    [_topMenus addObject:like];

    KxMenuItem *msg = [KxMenuItem menuItem:@"收藏" image:[UIImage imageNamed:@"bt_collece"] target:self action:@selector(doArticle:)];
    [_topMenus addObject:msg];
    if (_pub.article.enableComment) {
        KxMenuItem *comment = [KxMenuItem menuItem:@"评论" image:[UIImage imageNamed:@"bt_comment"] target:self action:@selector(doComment:)];
        [_topMenus addObject:comment];
    }
    
    WebAppEntity *chat = CRWebAppTitle(@"chatroom");
    WebAppEntity *server = CRWebAppTitle(@"customerservice");
    if (chat||server) {
        KxMenuItem *server = [KxMenuItem menuItem:@"咨询" image:[UIImage imageNamed:@"ic_connnect_server"] target:self action:@selector(connectToServer:)];
        [_topMenus addObject:server];
    }
    KxMenuItem *more = [KxMenuItem menuItem:@"更多" image:[UIImage imageNamed:@"ic_more"] target:self action:@selector(showMore:)];
    [_topMenus addObject:more];
    
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
    menu.frame = CGRectMake(0, 0, 27, 27);
    menu.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [menu setImage:[UIImage imageNamed:@"ic_drop"] forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(showTopMenu:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:menu];
    self.navigationItem.rightBarButtonItem = item;
    
}

#pragma mark - webviewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [_indicatorView startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [_indicatorView stopAnimating];
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(NAV_H, 0, 0, 0);
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(NAV_H, 0, 0, 0);
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *urlString = [[request URL] absoluteString];
    NSArray *urlComps = [urlString componentsSeparatedByString:@"://"];
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
            NSLog(@"before == %@",args);

            NSMutableArray *newArgs = [NSMutableArray new];
            for (int i = 0;i<args.count; i++) {
                NSString *arg = [[args[i] stringByReplacingOccurrencesOfString:@"MSGPLUSMSG" withString:@"+"] stringByReplacingOccurrencesOfString:@"MSGXXMSG" withString:@"/"];
                //                NSLog(@"before == %@",args);
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
            NSLog(@"after == %@",newArgs);
            [self performSelectorOnMainThread:method withObject:newArgs waitUntilDone:NO];
            return NO;
        }
    }
    return YES;
    
}

/**
 *  打开顶栏菜单
 */
-(void)showTopMenu:(UIButton*)sender
{
    CGRect frame = sender.frame;
    CGRect newFrame = [self.navigationController.navigationBar convertRect:frame toView:AppWindow];
    [KxMenu showMenuInView:AppWindow fromRect:newFrame menuItems:_topMenus];
}

/**
 *  调用初始化js
 *
 *  @param
 */
-(void)loadfinished:(NSArray*)datas{
    
    NSString *jsonStr;
    NSString *from = @"";
    if ([_pub.article.source length] >0) {
        from = _pub.article.source;
    }

    jsonStr = [NSString stringWithFormat:@"insertContent(%@,1,%d,\"%@\")",_pub.article.msgJson,_currentFont,from];
    [self.webView stringByEvaluatingJavaScriptFromString:jsonStr];
    
}
/**
 *  打开用户信息页
 */

-(void)show_user_profile:(NSArray*)datas{
    
    if ([datas count]>0) {
        NSString *userName = datas[0];
        ContactEntity *contact = [[ContactEntity alloc] init];
        contact.userName = userName;
        contact.title = userName;
        ContactContentController *content = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ContactContentController"];
        content.disableEdite = true;
        content.contact = contact;
        [self.navigationController pushViewController:content animated:true];
    }else{
        [CustomToast showMessageOnWindow:@"参数错误"];
    }
}
-(void)openpub:(NSArray*)datas
{
    if (CRArrayObject(datas, 0)) {
        NSInteger pid = [datas[0] integerValue];
        [MSGTansitionManager openPubWithID:pid withParams:nil];
    }
}
/**
 *  打开链接
 *
 *  @param data
 */
-(void)openlink:(NSArray*)data{
    
    NSMutableString *strUrl = [data[0] mutableCopy];
    if ([strUrl rangeOfString:@"https%3a%2f%2f"].location!=NSNotFound) {
        NSRange range = [strUrl rangeOfString:@"https%3a%2f%2f"];
        [strUrl replaceCharactersInRange:range withString:@"https://"];
    }
    if ([strUrl rangeOfString:@"http%3a%2f%2f"].location!=NSNotFound)
    {
        NSRange range = [strUrl rangeOfString:@"http%3a%2f%2f"];
        [strUrl replaceCharactersInRange:range withString:@"http://"];
    }
    [MSGTansitionManager openLink:strUrl];
}
/**
 *  打开webapp
 *
 *  @param data
 */
-(void)openwebapp:(NSArray*)data{
    
    if (data.count>1) {
        NSString *aid = data[0];
        NSString *appDataStr = [data[1] length]>0?data[1]:@"{}";
        NSDictionary *params = @{
                                 @"init_data":appDataStr
                                 };
        WebAppEntity *app = CRWebAppID([aid integerValue]);
        if ([app.systitle isEqualToString:@"map/route"]&&_pub) {
            [UserActionManager userBrowsMap:_pub];
        }
        [MSGTansitionManager openWebappWithID:[aid integerValue] withParams:params goBack:nil callBack:nil];
    }
}
# pragma mark - 播放视频

-(void)playVideo:(NSArray*)data{
    //do something
    NSString *url = CRArrayObject(data, 0);
    KaokeVideo *video = CRArrayObject(_pub.article.videos,0);
    [MSGTansitionManager playVideo:url title:video.descr];
}
# pragma mark - 播放音频

-(void)showAudio:(NSArray*)data{
    //do something
    NSString *url = CRArrayObject(data, 0);
    [MSGTansitionManager playAudio:url];
}
# pragma mark - 显示图片

-(void)showPic:(NSArray*)data{
    
    //do something
    mwState = mwStateImgs;
    NSInteger index = [CRArrayObject(data, 0) integerValue];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:(id<MWPhotoBrowserDelegate>)self];
    browser.displayActionButton = false;
    browser.displayNavArrows = true;
    browser.displaySelectionButtons = false;
    browser.alwaysShowControls = false;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = false;
    browser.startOnGrid = false;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:index];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [CRRootNavigation() presentViewController:nc animated:true completion:^{
    }];

}
# pragma mark - 显示图集

-(void)showImgset:(NSArray*)data{
    
    //do something
    mwState = mwStateImgset;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:(id<MWPhotoBrowserDelegate>)self];
    browser.displayActionButton = false;
    browser.displayNavArrows = true;
    browser.displaySelectionButtons = false;
    browser.alwaysShowControls = false;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = false;
    browser.startOnGrid = false;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [CRRootNavigation() presentViewController:nc animated:true completion:^{
    }];
    
}

/**
 *  用户行为统计
 *
 *  @param pub
 */
-(void)action:(PubEntity*)pub{
    
//    [[MsgUserManager getInstance] userRecordActionWithPubId:pub.pid title:pub.article.title op:@"map"];
    
}
-(void)increaseFont{
    
    _currentFont +=1;
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeFontSize(%d)",_currentFont]];
    
}

-(void)decreaseFont{
    
    _currentFont -=1;
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"changeFontSize(%d)",_currentFont]];
    
}

/**
 *  显示分享菜单
 */
-(void)doShare:(id)sender
{
    ShareView *share = [ShareView sharedView];
    share.webView = self.webView;
    share.image = nil;
    [ShareView show:_pub];
}
/**
 *  点赞
 */
-(void)doLike:(id)sender
{
    //未登录
    if (!LoginState) {
        CRWeekRef(self);
        [LoginHandler showLoginControllerFromController:self complete:^(BOOL loginState) {
            if (LoginState) {
                [__self doLike:nil];
            }
        }];
        return;
    }
    if (![sender isKindOfClass:[UIButton class]]){
        [MSGRequestManager MKUpdate:kAPILike(_pub.article.mid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [CustomToast showMessageOnWindow:@"赞+1"];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [CustomToast showMessageOnWindow:msg];
        }];
        return;
    }
    [MSGRequestManager MKUpdate:kAPILike(_pub.article.mid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if (_pub) {
            [UserActionManager userPubLike:_pub];
        }
        _pub.article.like += 1;
        UIButton *_like = sender;
        CGRect frame = [_bottomToolBarView convertRect:_like.frame toView:self.view];
        
        CGPoint point = CGPointMake(CGRectGetWidth(frame)/2.0f + frame.origin.x, CGRectGetHeight(frame)/2.0f + frame.origin.y);
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        lable.center = point;
        lable.text = @"+1";
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = [UIColor blackColor];
        lable.font = MSGYHFont(14);
        [self.view addSubview:lable];
        CGAffineTransform tranform = lable.transform;
        CGAffineTransform tranformScale = CGAffineTransformScale(tranform, 2, 2);
        [UIView animateWithDuration:.75 animations:^{
            CGRect frame = lable.frame;
            frame.origin.y -= 60;
            lable.frame = frame;
            lable.alpha = 0;
            lable.transform = tranformScale;
        } completion:^(BOOL finished) {
            [lable removeFromSuperview];
        }];

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
    }];
}
/**
 * 更多
 */
-(void)showMore:(id)sender
{
    MsgInfo *info = [Utility nibWithName:@"PublicationInfo" index:0];
    [info intilizedDataBy:_pub];
    info.delegate = (id<MsgInfoDelegate>)self;
    [info show];
}
/**
 *  收藏
 */
-(void)doArticle:(id)sender{
    if (!LoginState) {
        CRWeekRef(self);
        [LoginHandler showLoginControllerFromController:self complete:^(BOOL loginState) {
            if (LoginState) {
                [__self doArticle:nil];
            }
        }];
        return;
    }

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [AppWindow addSubview:hud];
    [hud show:true];
    [MSGRequestManager Get:kAPIAllGroup params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if (CRJSONIsArray(data)) {
            NSArray *groups = data;
            if (groups.count>0) {
                ArticleGroupEntity *entity = [ArticleGroupEntity buildInstanceByJson:groups[0]];
                NSDictionary *params = @{
                                         @"title":_pub.article.title,
                                         @"group":CRString(@"%d",entity.gid)
                                         };
                [MSGRequestManager MKUpdate:kAPIPubArticle(_pub.article.mid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    if (_pub) {
                        [UserActionManager userRecordPubArticle:_pub];
                    }
                    [hud hide:true];
                    [CustomToast showMessageOnWindow:@"收藏成功"];
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    [CustomToast showMessageOnWindow:msg];
                }];
                
            }
        }
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];

}
/**
 *  评论
 */
-(void)doComment:(id)sender{
    
    if (!LoginState) {
        CRWeekRef(self);
        [LoginHandler showLoginControllerFromController:self complete:^(BOOL loginState) {
            if (LoginState) {
                [__self doComment:nil];
            }
        }];
        return;
    }
    if (_pub.article) {
        CommentsController *comment = [Utility controllerInStoryboard:@"Main" withIdentifier:@"CommentsController"];
        comment.article = _pub.article;
        [self.navigationController pushViewController:comment animated:true];
    }
}
/**
 *  关联投稿
 *
 *  @param data 参数
 */
-(void)web_get_pubrel:(NSArray*)data
{
    NSString *jsMethod = CRArrayObject(data, 0);
    CRWeekRef(self);
    if (jsMethod&&_pub) {
        [_pub getPubRel:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            NSString *json = [[[SBJsonWriter alloc] init] stringWithObject:data];
            [__self.webView stringByEvaluatingJavaScriptFromString:CRString(@"%@(%@)",jsMethod,json)];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
        }];
    }
    
}
/**
 *  获取店铺信息
 *
 *  @param datas 参数
 */
-(void)web_get_shopstore:(NSArray*)datas
{
    NSInteger sid = [CRArrayObject(datas, 0) integerValue];
    __block NSString *jsMethod = [CRArrayObject(datas, 1) copy];
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIShop(sid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSString * shopJson = [[[SBJsonWriter alloc] init] stringWithObject:data];
        [__self.webView stringByEvaluatingJavaScriptFromString:CRString(@"%@(%@)",jsMethod,shopJson)];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
    }];
}

-(void)web_open_shopstore:(NSArray*)datas{
    
    NSInteger sid = [CRArrayObject(datas, 0) integerValue];
    [_indicatorView startAnimating];
    [MSGRequestManager Get:kAPIShop(sid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [_indicatorView stopAnimating];
        ShopStoreEntity *entity = [ShopStoreEntity buildWithJson:data];
        ShopViewController *shop = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ShopViewController"];
        shop.shopData = entity;
        [CRRootNavigation() pushViewController:shop animated:true];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [_indicatorView stopAnimating];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}

/**
 *  聊天
 *
 *  @param datas
 */
-(void)openchat:(id)datas{
    [self connectToServer:nil];
}

/**
 *  联系客服
 */
-(void)connectToServer:(id)sender
{
    if (!LoginState) {
        CRWeekRef(self);
        [LoginHandler showLoginControllerFromController:self complete:^(BOOL loginState) {
            if (LoginState) {
                [__self connectToServer:nil];
            }
        }];
        return;
    }
    WebAppEntity *chatRoom = CRWebAppTitle(@"chatroom");
    WebAppEntity *chatServer = CRWebAppTitle(@"customerservice");

    if (chatRoom&&chatServer) {
        
        ServerListController *server = [[ServerListController alloc] init];
        server.master = _pub.master.userName;
        [self.navigationController pushViewController:server animated:YES];
        
    }else if(chatRoom){
        
        XMContntController *XMVC = [XMContntController messagesViewController];
        if (_pub.article.master.userName) {
            XMVC.roser = _pub.article.master.userName;
            XMVC.senderDisplayName = _pub.article.master.firstName;
            [self.navigationController pushViewController:XMVC animated:true];
        }
        
    }else if(chatServer){
        
        ServerListController *server = [[ServerListController alloc] init];
        server.master = nil;
        [self.navigationController pushViewController:server animated:YES];
    }else{
        [CustomToast showMessageOnWindow:@"该功能咱不能使用"];
    }
   
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    
    NSArray *imgs = (mwState == mwStateImgs?mwImages:mwImageSets);
    return imgs.count;
    
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSArray *imgs = (mwState == mwStateImgs?mwImages:mwImageSets);
    return CRArrayObject(imgs, index);
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    
    NSArray *imgs = (mwState == mwStateImgs?mwImages:mwImageSets);
    return CRArrayObject(imgs, index);
}

#pragma mark - 截屏
-(UIImage *)capture{
    
    CGRect originalFrame = self.webView.frame;
    CGPoint originalOffset = self.webView.scrollView.contentOffset;
    CGSize entireSize = [self.webView sizeThatFits:CGSizeZero];
    [self.webView setFrame: CGRectMake(0, 0, entireSize.width, entireSize.height)];
    
    //截图
    UIGraphicsBeginImageContext(entireSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.webView.layer renderInContext:context];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //还原大小 和偏移
    [self.webView setFrame:originalFrame];
    self.webView.scrollView.contentOffset = originalOffset;
    return screenshot;
    
}

-(UIImage*)captureView:(UIView *)theView frame:(CGRect)frame{
    
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, frame);
    UIImage *i = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return i;
    
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
