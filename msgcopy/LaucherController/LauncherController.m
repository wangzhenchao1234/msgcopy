
//
//  LauncherController.m
//  msgcopy
//
//  Created by Gavin on 15/4/7.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//
/**
 *  初始化数据界面
 */
#define iconImage @"http://www.easyicon.net/api/resize_png_new.php?id=1186628&size=128"


#import "LauncherController.h"
#import "AppDelegate.h"
#import "LimbController.h"
#import "CenterController.h"
#import "DiyPageController.h"
#import "WebAppController.h"
#import "PubController.h"
#import "ShopStoreListController.h"
#import "WaterView.h"
#import "UserHelperController.h"
#import "MSGTabBarItem.h"

@interface LauncherController ()<UIActionSheetDelegate,WaterViewDelegate>
@property(nonatomic,retain)WaterView *waterView;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,assign)BOOL isAlert;
@end

@implementation LauncherController
- (void)viewDidLoad {
    
    [super viewDidLoad];
    _index=0;
    _isAlert=YES;
    [self configWaterView];
    [self loadRequest];
    // Do any additional setup after loading the view.
}
/**
 *  加载view
 */
-(void)configWaterView
{
    UIImage *image = [UIImage imageNamed:@"icon"];
    _waterView = [[WaterView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _waterView.delegate = self;
    _waterView.currentWaterColor = CRCOLOR_WHITE;

    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    logo.layer.cornerRadius = 10;
    logo.clipsToBounds = true;
    _waterView.layer.borderWidth = 0;
    logo.image = image;
    [self.view addSubview:logo];
    
    logo.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame)-40);
    _waterView.center = logo.center;
    [self.view addSubview:_waterView];
    [_waterView startAnimation];
    [_waterView setProgress:0];
    
}

#pragma mark -开始请求 初始化开始
/**
 * 开始请求 初始化开始
 */
-(void)loadRequest
{   AFNetworkReachabilityManager *reachabilityManager =[AFNetworkReachabilityManager sharedManager];
     [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            //网络无连接的提示
        [CustomToast showMessageOnWindow:@"网络请求失败"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_isAlert) {
                [self await:@"是否继续网络请求"];
   
                }
            });

        }else{
            _isAlert=NO;
            CRWeekRef(self);
            [UserDataManager intilizedUserDataForTarget:self progress:^(CGFloat progress){
                [__self performSelectorOnMainThread:@selector(updateProgress:) withObject:@(progress) waitUntilDone:true];
            } complete:^(BOOL result) {
                if (result) {
                    [AppDataManager intilizedAppDataForTarget:self progress:^(CGFloat progress){
                        [__self performSelectorOnMainThread:@selector(updateProgress:) withObject:@(progress) waitUntilDone:true];
                    }complete:^(BOOL result) {
                        if (result) {
                            //初始化成功
                        }else{
                            [self startFailed:@"初始化失败"];
                        }
                    }];
                    
                }else{
                    //初始化失败
                    [self startFailed:@"初始化失败"];
                }
            }];
        
        }
    }];
  
    
}
//当无网络时,进行等待或者退出
-(void)await:(NSString*)msg{
    NSLog(@"-----------------------%@",msg);
    //发生错误退出
    CRWeekRef(self);
    [GVAlertView showAlert:nil message:msg confirmButton:@"确定" action:^{
        
        CRLog(@"确认退出");
    } cancelTitle:@"取消" action:^{
        [__self exite];

    
    }];
    
}


-(void)updateProgress:(NSNumber*)progress{
    [_waterView setProgress:[progress floatValue]];
}
-(void)finishedLoading
{
    if (LoginState) {
        //xmpp登录
        CRBackgroundGCD(^{
            [[XmppListenerManager sharedManager] setUser:kCurUser];
            [[HistoryContentManager sharedManager] getAllRoomsComplete:nil];
        });
    }
    MCenterManager *manager = [MCenterManager sharedManager];
    [manager updateMessages:nil];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive && !manager.isOnService) {
        [[MCenterManager sharedManager] startService];
    }
    BOOL hasUserHelper =  false;
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/welcome.bundle/"];
    NSArray *imageNames = CRFilesForType(path, @"png");
    if (imageNames.count>0) {
        hasUserHelper = true;
    }
    if (!CRUserBOOL(kAppFirstOpen)) {
        CRUserSetBOOL(true, kAppFirstOpen);
        if (hasUserHelper) {
            [self showWelcome];
        }else{
            if ([AppDataManager sharedManager].splashBanner.items.count>0) {
                UIViewController *banner = [Utility controllerInStoryboard:@"Main" withIdentifier:@"AppBannerController"];
                MSGNavigationController *nav = [[MSGNavigationController alloc] initWithRootViewController:banner];
                nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [[(AppDelegate*)[UIApplication sharedApplication].delegate window] setRootViewController:nav];
                return;
            }else{
                [LauncherController showHomePageController];
                return;
            }
        }
    }else{
        if ([AppDataManager sharedManager].splashBanner.items.count>0)
        {
            UIViewController *banner = [Utility controllerInStoryboard:@"Main" withIdentifier:@"AppBannerController"];
            MSGNavigationController *nav = [[MSGNavigationController alloc] initWithRootViewController:banner];
            nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [[(AppDelegate*)[UIApplication sharedApplication].delegate window] setRootViewController:nav];
            return;
        }
        [LauncherController showHomePageController];
    }
}

-(void)showWelcome{
    
    //第一次启动欢迎页
    UserHelperController *helper = [[UserHelperController alloc] initWithHome:true];
    MSGNavigationController *nav = [[MSGNavigationController alloc] initWithRootViewController:helper];
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[(AppDelegate*)[UIApplication sharedApplication].delegate window] setRootViewController:nav];

}

/**
 *  显示首页
 */
+(void)showHomePageController
{
    
    GSliderViewController *slider = [[GSliderViewController alloc] init];
    CenterController *_rootCenter = [Utility controllerInStoryboard:@"Main" withIdentifier:@"CenterController"];
    /**
     *  判断左栏是否显示
     *
     *  @param kCurSidBarKind 客户端功能栏状态
     *
     *  @return
     */
    UIViewController *left = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LeftController"];
    slider.slidType = GSliderTypeSlidAndScale;
    slider.maxLeftPan = SliderWidth;
    slider.leftViewController = left;

    if (kCurSidBarKind == SidBarKindLeft) {
        [slider enableTapGestrue];
        [slider enablePanGestrue];
    }else{
        /**
         *  无左栏禁用手势
         */
        [slider disablePanGestrue];
        [slider disableTapGestrue];
    }
    UINavigationController *_rootNav = [[UINavigationController alloc] initWithRootViewController:_rootCenter];
    NSArray *viewControllers = [AppDataManager intilizedViewControllers];
    NSArray *tabItems = [AppDataManager intilizedTabBarItems:_rootCenter];
    [_rootCenter setViewControllers:viewControllers tabBarItems:tabItems];
    __block MSGTabBarItem *homeItem = nil;
    [tabItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MSGTabBarItem *item = obj;
        if (item.isHome&&kCurApp.home.kind != AppHomeKindLimb) {
            homeItem = item;
            *stop = true;
        }
    }];
    if (homeItem) {
        [homeItem setSelected:true];
        if (homeItem.action) {
            homeItem.action(kCurApp.home);
        }
    }else if(kCurApp.home.kind == AppHomeKindLimb&&CRArrayObject(tabItems, 0)){
        homeItem = CRArrayObject(tabItems, 0);
        if (homeItem.action) {
            homeItem.action(homeItem.data);
        }
    }
    slider.centerViewController = _rootNav;
    MSGNavigationController *nav = [[MSGNavigationController alloc] initWithRootViewController:slider];

    /**
     *  重新设置主视图控制器
     */
    if (kCurSidBarKind == SidBarKindLeft||kCurSidBarKind == SidBarKindNone) {
        [_rootCenter setTabBarHidden:true];
    }else{
        [_rootCenter setTabBarHidden:false];
    }
    [[(AppDelegate*)[UIApplication sharedApplication].delegate window] setRootViewController:nav];
    [slider viewDidAppear:true];
    [_rootCenter filterCheck];
    
    /*
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nav animated:true completion:^{
        [[(AppDelegate*)[UIApplication sharedApplication].delegate window] setRootViewController:nav];
        [slider viewDidAppear:true];
    }];
     */
    
}

/**
 *  初始化tabbarControllers
 *
 *  @return viewcontrollers
 */

#pragma mark - 出现错误退出
/**
 * 出现错误退出
 */
-(void)startFailed:(NSString*)msg{
    NSLog(@"-----------------------%@",msg);
    //发生错误退出
    CRWeekRef(self);
    [GVAlertView showAlert:nil message:msg confirmButton:@"确定" action:^{
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//            [self loadRequest];
//
//        });
        [__self exite];

        CRLog(@"确认退出");
    } cancelTitle:nil action:nil];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(BOOL)shouldAutorotate{
    return false;
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
