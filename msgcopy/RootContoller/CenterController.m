//
//  CenterController.m
//  msgcopy
//
//  Created by wngzc on 15/4/10.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "CenterController.h"
#import "MSGTabBarItem.h"
#import "FilterController.h"
#import "MContentController.h"
#import "XMTabBarController.h"

@interface CenterController ()<UINavigationBarDelegate>
{
    UIImageView *_rootTitleView;
    BOOL isRight; //将要打开的是不是右栏
    UILabel *news;//新消息红点
}
@end

@implementation CenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AppDataManager refreshData:^(BOOL result) {
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessages:) name:kMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessages:) name:kChatMessageNotification object:nil];
    [self setNavBarItems];
    [self checkPermission];
    // Do any additional setup after loading the view.
}
-(BOOL)checkPermission{
    
    CRWeekRef(self);
    if (![PermissonManager sharedManager].loginValid) {
        if (LoginState) {
            [GVConfirmView showConfirm:@"对不起，您无权限使用客户端" inView:AppWindow confirmButton:@"马上申请" action:^{
                [MCenterManager sendApplyToadmin:@"权限申请" content:@"该用户向您申请登录权限!" success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [CustomToast showMessageOnWindow:@"已向管理员发送申请"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [__self exite];
                    });
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [CustomToast showMessageOnWindow:@"发送失败"];
                    [__self exite];
                }];

            } otherTitle:@"切换账号" action:^{
                LoginController *loginVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LoginController"];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [CRRootNavigation() presentViewController:nav animated:true completion:nil];
                
            } cancelTitle:@"关闭" action:^{
                [GVConfirmView showConfirm:@"您是要？" inView:AppWindow confirmButton:@"注销" action:^{
                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                    [AppWindow addSubview:hud];
                    hud.removeFromSuperViewOnHide = true;
                    [hud show:true];
                    NSDictionary *keychainUser = [UserDataManager keychainUser];
                    NSLog(@"注销时的用户信息 ---- %@",keychainUser);
                    [[UserDataManager sharedManager] doLogin:keychainUser success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                            [hud hide:true];
                            CRBackgroundGCD(^{
                                [[XmppListenerManager sharedManager] disconnect];
                            });
                            [__self checkPermission];
                        }];
                        
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        [CustomToast showMessageOnWindow:msg];
                    }];

                } cancelTitle:@"退出" action:^{
                    
                    [__self exite];
                    
                }];

            }];
            
        }else{
            
            [GVConfirmView showConfirm:@"对不起，您无权限使用客户端" inView:AppWindow confirmButton:@"登录" action:^{
                LoginController *loginVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LoginController"];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [CRRootNavigation() presentViewController:nav animated:true completion:nil];
                
            } cancelTitle:@"退出" action:^{
                [__self exite];
            }];
        }
        return false;
    }
    return true;
}
#pragma mark - 强制退出客户端
/**
 *  强制退出客户端
 */
-(void)exite{
    
    self.view.window.transform = CGAffineTransformMakeScale(1,1);
    [UIView animateWithDuration:.5 animations:^{
        self.view.window.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            exit(0);
        }
    }];
    
}

-(void)pushCheck
{
    BOOL isPubNotify = CRUserBOOL(@"pub_notification");
    BOOL isMessageNotify = CRUserBOOL(@"message_notification");
    BOOL isChatNotify = CRUserBOOL(@"chat_notification");
    if (isPubNotify) {
        CRUserSetBOOL(false,@"pub_notification");
        NSInteger pid = CRUserInteger(@"pub_notification_id");
        if (pid) {
            [MSGTansitionManager openPubWithID:pid withParams:nil];
        }
        return;
    }else if (isMessageNotify){
        NSInteger mid = CRUserInteger(@"message_notification_id");
        MessageEntity *message = [[MCenterManager sharedManager] messageWithID:mid];
        CRUserSetBOOL(false,@"pub_notification");
        if (message) {
            CRUserSetBOOL(false,@"message_notification");
            [[MCenterManager sharedManager] readMessageWithID:mid];
            MContentController *content = [[MContentController alloc] init];
            content.message = message;
            [CRRootNavigation() pushViewController:content animated:true];
        }
        
    }else if (isChatNotify){
        
        CRUserSetBOOL(false, @"chat_notification");
        XMTabBarController *xmVC = [[XMTabBarController alloc] init];
        [CRRootNavigation() pushViewController:xmVC animated:true];
        
    }
}
-(void)filterCheck
{
    if ([FilterManager isValid]&&!CRUserBOOL(kFilterInit)) {
        [self filterClick:nil];
    }else{
        [self pushCheck];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateMessages:nil];
    [self refreshFilterButton];
    self.leftBarItems = [NSMutableArray new];
    if (kCurApp.sideBar.kind == SidBarKindLeft) {
        [self.leftBarItems addObject:_leftBarButtonItem];
    }
    if ([FilterManager isValid]&&kCurApp.sideBar.kind != SidBarKindLeft) {
        [self.leftBarItems addObject:_filterButtonItem];
    }
    self.navigationItem.leftBarButtonItems = _leftBarItems;

    if (LoginState&&kCurUser.head50) {
        [_rightMenuButton setImageWithURL:CRURL(kCurUser.head50) forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ic_right_menu"]];
    }else{
        [_rightMenuButton setImage:[UIImage imageNamed:@"ic_right_menu"] forState:UIControlStateNormal];
    }
    if (_curSelectedTab < self.tabBar.items.count) {
        [self.tabBar setSelectedItem:self.tabBar.items[_curSelectedTab]];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isRight = false;
    CRWeekRef(self);
    [[UserDataManager sharedManager] userInfoSuccess:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
        CRLog(@"userinfo :\n\n %@ \n\n",data);
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
        if (code == 302 || code == 401) {
            //cookie失效或者没有权限
            /**
             * 钥匙串账号 username=%@&password=%@
             */
            NSDictionary *keychainUserInfo = [UserDataManager keychainUser];
            if (keychainUserInfo) {
                //钥匙串设备号已存在
                NSLog(@"code== 302/404时的用户信息 ---- %@",keychainUserInfo);
                [[UserDataManager sharedManager] doLogin:keychainUserInfo success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                        CRBackgroundGCD(^{
                            [[XmppListenerManager sharedManager] disconnect];
                        });
                        [__self viewWillAppear:true];
                        [__self checkPermission];
                    }];
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {

                }];
                
            }
        }
    }];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!isRight) {
        [Utility setDefaultNavigation:CRRootNavigation()];
    }
}
-(void)setNavBarItems
{
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:MSGFont(16),NSForegroundColorAttributeName:CRCOLOR_BLACK};
    
    _titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
    _titleView.clipsToBounds = true;
    _titleView.image = [UIImage imageNamed:@"ic_title"];
    _rootTitleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 18)];
    _rootTitleView.clipsToBounds = true;
    _rootTitleView.image = [UIImage imageNamed:@"ic_title"];
    
    UIButton *_left = [UIButton buttonWithType:UIButtonTypeCustom];
    [_left setImage:[UIImage imageNamed:@"ic_left_menu"] forState:UIControlStateNormal];
    _left.frame = CGRectMake(0, 0, 27, 27);
    [_left addTarget:self action:@selector(leftMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    _leftBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:_left];

    _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _filterButton.titleLabel.font = MSGFont(16);
    [_filterButton setTitle:[FilterManager curFilterName] forState:UIControlStateNormal];
    _filterButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    _filterButton.frame = CGRectMake(0, 0, 27, 27);
    [_filterButton setTitleColor:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor] forState:UIControlStateNormal];
    [_filterButton addTarget:self action:@selector(filterClick:) forControlEvents:UIControlEventTouchUpInside];
    _filterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_filterButton];
    

    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    rightView.clipsToBounds = false;
    rightView.backgroundColor = CRCOLOR_CLEAR;
    
    news = [[UILabel alloc] initWithFrame:CGRectMake(22, -10/2.0f, 10, 10)];
    news.backgroundColor = CRCOLOR_RED;
    news.clipsToBounds = true;
    news.layer.cornerRadius = 5;
    
    _rightMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightMenuButton.frame = CGRectMake(0, 0, 27, 27);
    _rightMenuButton.layer.cornerRadius = 27/2.0f;
    _rightMenuButton.clipsToBounds = true;
    [_rightMenuButton setImage:[UIImage imageNamed:@"ic_right_menu"] forState:UIControlStateNormal];
    [_rightBarButtonItem setImageInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [_rightMenuButton addTarget:self action:@selector(showRight:) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:_rightMenuButton];
    [rightView addSubview:news];
    news.hidden = true;
    
    _rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItems = @[_rightBarButtonItem];
    self.navigationItem.titleView = _titleView;
    self.g_sliderViewController.navigationItem.titleView = _rootTitleView;
}

/**
 *  显示logo
 */
-(void)showTitleView
{
    self.navigationItem.titleView = _titleView;
    self.g_sliderViewController.navigationItem.titleView = _rootTitleView;
    
}
/**
 *  隐藏logo
 */
-(void)hiddenTitleView
{
    self.navigationItem.titleView = nil;
    self.g_sliderViewController.navigationItem.titleView = nil;
}
/**
 *  显示标题
 *
 *  @param title 标题
 */
-(void)setTitle:(NSString *)title
{
    [self hiddenTitleView];
    self.navigationItem.title = title;
    self.g_sliderViewController.navigationItem.title = title;
}

/**
 *  configfilterView
 */
-(void)configfilterView
{
    _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _filterButton.frame = CGRectMake(0,44, 60, 27);
    _filterButton.titleLabel.font = MSGYHFont(14);
}
/**
 *  refreshFilterButton
 */
-(void)refreshFilterButton
{
    if (!_filterButton) {
        return;
    }
    [_filterButton setTitle:[FilterManager curFilterName] forState:UIControlStateNormal];
    [_filterButton sizeToFit];
    _filterButton.width += 15;
}

- (void)setViewControllers:(NSArray *)viewControllers tabBarItems:(NSArray*)tabBarItems
{
    if (self.viewControllers && self.viewControllers.count) {
        for (UIViewController *viewController in self.viewControllers) {
            [viewController willMoveToParentViewController:nil];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
    }
    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        self.viewControllers = [viewControllers copy];
        for (UIViewController *viewController in viewControllers) {
            [viewController rdv_setTabBarController:self];
        }
        [[self tabBar] setItems:tabBarItems];
    } else {
        for (UIViewController *viewController in self.viewControllers) {
            [viewController rdv_setTabBarController:nil];
        }
        self.viewControllers = nil;
    }
}

-(BOOL)tabBar:(RDVTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index
{
    return true;
}

- (void)tabBar:(RDVTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index {
    //如果是切换tabbaritem 必须保证viewcontroller的个数大于index
    MSGTabBarItem *item = self.tabBar.items[index];
    if (item.linkType == TabBarLinkTypeLimb || item.linkType == TabBarLinkTypeHome||item.linkType == TabBarLinkTypeMore) {
        self.curSelectedTab = index;
    }
    if (item.linkType!=TabBarLinkTypeLimb) {
        self.navigationItem.rightBarButtonItems = @[_rightBarButtonItem];
    }
    item.action(item.data);
}
/**
 *  点击显示左栏
 *
 *  @param sender 按钮
 */
-(void)leftMenuClick:(id)sender
{
    [self.navigationController.g_sliderViewController showLeftWithAnimation:true complete:nil];
}
/**
 *  点击显示右栏
 *
 *  @param sender 按钮
 */

-(void)showRight:(id)sender{
    
    UIViewController *rightVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"RightController"];
    [Utility setTransparentNavigation:CRRootNavigation() navBarTransparent:TransParentNavBg];
    isRight = true;
    [CRRootNavigation() pushViewController:rightVC animated:true];
    
}
/**
 *  点击显示右栏
 *
 *  @param sender 按钮
 */
-(void)filterClick:(id)sender
{
    FilterController *filter = [Utility controllerInStoryboard:@"Main" withIdentifier:@"FilterController"];
    WebAppEntity *app = CRWebAppTitle(@"globalfilter");
    filter.title = app.title;
    filter.conditions = [FilterManager filterData];
    if (sender!=nil) {
    [CRRootNavigation() pushViewController:filter animated:true];
   
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMessageNotification object:nil];
}
# pragma mark - 新消息
/**
 *  消息中心消息
 *
 *  @param sender
 */
-(void)updateMessages:(id)sender{
    
    NSInteger unreadMesCount = [[[MCenterManager sharedManager] unReadMessages] count];
    NSLog(@" ************ unreadMesCount - %d",unreadMesCount);
    NSInteger unreadGroupChatMesCount = [[ContentManager sharedManager] getUserUnreadCountType:@"groupchat"];
    NSInteger unreadChatMesCount = [[ContentManager sharedManager] getUserUnreadCountType:@"chat"];
    NSInteger unreadCount = unreadMesCount+ unreadGroupChatMesCount+unreadChatMesCount;
    if (unreadCount>0) {
        news.hidden = false;
    }else{
        news.hidden = true;
    }
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
