//
//  HomeController.m
//  msgcopy
//
//  Created by wngzc on 15/4/18.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "HomeController.h"
#import "StandStyleController.h"
#import "MordernStyleController.h"
#import "WebAppController.h"
#import "DiyPageController.h"


@interface HomeController ()

@end

@implementation HomeController
/**
 *  首页
 *
 *  @return 首页
 */
+(UIViewController*)homeController
{
    HomeConfigEntity *home = kCurApp.home;
    AppHomeKind kind = home.kind;
    UIViewController *homeVC = nil;
    switch (kind) {
        case AppHomeKindNormal:
            homeVC = [HomeController loadNormalHome];
            break;
        case AppHomeKindWin8:
            homeVC = [HomeController loadWin8Home];
            break;
        case AppHomeKindDiyPage:
            homeVC = [HomeController loadDiyPageHome];
            break;
        case AppHomeKindWebApp:
           homeVC = [HomeController loadWebAppHome];
            break;
        default:
            homeVC = [UIViewController new];
            break;
    }
    return homeVC;
}
/**
 *  基础首页
 *
 *  @return 基础首页
 */
+(UIViewController*)loadNormalHome
{
    StandStyleController *home = [Utility controllerInStoryboard:@"Main" withIdentifier:@"StandStyleController"];
    return home;
}
/**
 *  win8首页
 *
 *  @return win8页面
 */
+(UIViewController*)loadWin8Home
{
    MordernStyleController *home = [Utility controllerInStoryboard:@"Main" withIdentifier:@"MordernStyleController"];
    return home;
}
/**
 *  自定义页面首页
 *
 *  @return 自定义页面首页
 */
+(UIViewController*)loadDiyPageHome
{
    DiyPageController *home = [Utility controllerInStoryboard:@"Main" withIdentifier:@"DiyPageController"];
    home.pageID = kCurApp.home.addr;
    return home;
}
/**
 *  webApp首页
 *
 *  @return webApp首页
 */
+(UIViewController*)loadWebAppHome
{
    WebAppController *home = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    home.appid = kCurApp.home.addr;
    return home;
    
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
