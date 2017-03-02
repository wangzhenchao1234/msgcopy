//
//  AppDelegate.m
//  msgcopy
//
//  Created by wngzc on 15/4/3.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "DataVerifier.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "NdUncaughtExceptionHandler.h"

@interface AppDelegate ()<WXApiDelegate>


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    float sysVersion=[[UIDevice currentDevice]systemVersion].floatValue;
    if (sysVersion>=8.0) {
        UIUserNotificationType type=UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        
    }
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [NdUncaughtExceptionHandler setDefaultHandler];
    [self registWeixin];
    [Utility setAppBackButtonImage:BlackBackImage color:CRCOLOR_BLACK];
    
    
    if (launchOptions) {
        NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        UILocalNotification* localNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (pushNotificationKey) {
            //            NSString *pid = [pushNotificationKey valueForKey:@"pub"];
            //            [self performSelectorInBackground:@selector(getRomotePub:) withObject:pid];
            //            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        }
        if (localNotificationKey) {
            NSDictionary *userinfo = localNotificationKey.userInfo;
            NSString *pid = [userinfo objectForKey:@"notify_pub"];
            BOOL isChat = [[userinfo valueForKey:@"ischat"] boolValue];
            NSString *mid = [userinfo objectForKey:@"notify_message"];
            if (pid) {
                CRUserSetBOOL(true, @"pub_notification");
                CRUserSetInteger([pid integerValue], @"pub_notification_id");
            }else if(isChat){
                CRUserSetBOOL(true, @"chat_notification");
            }else if(mid){
                CRUserSetBOOL(true, @"message_notification");
                CRUserSetInteger([mid integerValue], @"message_notification_id");
            }
            [[UIApplication sharedApplication] cancelLocalNotification:localNotificationKey];
        }
    }
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
    return YES;
}
/**
 *  注册微信
 */
-(void)registWeixin{
    
    if (![WXAppID isEqualToString:@"null"]) {
        [WXApi registerApp:WXAppID withDescription:CRAppDisplayName];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //此项修改为了保证程序进入后台能够接收消息
    NSLog(@"------%d",[MCenterManager sharedManager].isOnService);
    if (![MCenterManager sharedManager].isOnService) {
        [[MCenterManager sharedManager] startService];
    }//此项修改为了保证程序进入后台发送本地通知
    if (![LocalNotificationManager sharedManager].isOnService) {
        [[LocalNotificationManager sharedManager] startService];
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([MCenterManager sharedManager].isOnService) {
        [[MCenterManager sharedManager] stopService];
    }
    if ([LocalNotificationManager sharedManager].isOnService) {
        [[LocalNotificationManager sharedManager] stopService];
    }
    
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    GSliderViewController *slider = (GSliderViewController*)CRRootNavigation().viewControllers[0];
    if ([slider isKindOfClass:[GSliderViewController class]]) {
        UINavigationController *rootNav = (UINavigationController*)slider.centerViewController;
        CenterController *_rootCenter = (CenterController*)rootNav.viewControllers[0];
        if ([_rootCenter isKindOfClass:[CenterController class]]) {
            [_rootCenter pushCheck];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[XmppListenerManager sharedManager] disconnect];
    
}

/**
 *  三方应用调用客户端
 *
 *  @param application app
 *  @param url         url协议
 *
 *  @return 处理URL状态
 */
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL *)url{
    
    return [WXApi handleOpenURL:url delegate:self];
    
}
//授权后回调 WXApiDelegate
-(void)onResp:(BaseReq *)resp
{
    /*
         ErrCode ERR_OK = 0(用户同意)
         ERR_AUTH_DENIED = -4（用户拒绝授权）
         ERR_USER_CANCEL = -2（用户取消）
         code    用户换取access_token的code，仅在ErrCode为0时有效
         state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
         lang    微信客户端当前语言
         country 微信用户当前国家信息
     */
    if ([resp isKindOfClass:NSClassFromString(@"SendAuthResp")]) {
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode == 0) {
            NSString *code = aresp.code;
            _weichatAuthCallBack(code);
        }else{
            if (aresp.errCode == -4) {
                _weichatAuthErrorCallBack(@"用户拒绝授权");
                
            }else if(aresp.errCode == -2){
                _weichatAuthErrorCallBack(@"用户取消");
                
            }else{
                _weichatAuthErrorCallBack(@"授权失败");
            }
        }
    }else if([resp isKindOfClass:NSClassFromString(@"PayResp")]){
        PayResp *resq = (PayResp*)resp;
        if (resq.errCode == 0) {
           // _weichatPayCallBack(true);
        }else{
            //_weichatPayCallBack(false);
        }
    }
}

/**
 *  三方应用调用客户端
 *
 *  @param application       app
 *  @param url               url
 *  @param sourceApplication 传递参数
 *  @param annotation        application
 *
 */
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSString *appScheme  = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
    if ([[url absoluteString] rangeOfString:appScheme].location!=NSNotFound) {
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            
        }];
        return YES;
    }
    if ([[url absoluteString] rangeOfString:@"tencent"].location != NSNotFound) {
        
        [TencentOAuth HandleOpenURL:url];
        return YES;
        
    }
    return [WXApi handleOpenURL:url delegate:self];
}

/**
 *  后台进程
 *
 *  @param application       app
 *  @param completionHandler completionHandler
 */
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [[LocalNotificationManager sharedManager] updateNotifications:nil];
    [[MCenterManager sharedManager] updateMessages:nil];
}


/**
 *  屏幕旋转
 *
 *  @param application app
 *  @param window      window
 *
 */
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//    if ([CRRootNavigation().topViewController isKindOfClass:NSClassFromString(@"KxMovieViewController")]) {
//        KxMovieViewController *movie = (KxMovieViewController*)CRRootNavigation().topViewController;
//        if ([movie fullscreen])
//            return UIInterfaceOrientationMaskAll;
//    }else if([window.rootViewController isKindOfClass:[MovieController class]]){
//        return UIInterfaceOrientationMaskAll;
//    }
//    return UIInterfaceOrientationMaskPortrait;
//}
@end
