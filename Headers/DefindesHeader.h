//
//  DefindesHeader.h
//  msgcopy
//
//  Created by wngzc on 15/4/7.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#ifndef msgcopy_DefindesHeader_h
#define msgcopy_DefindesHeader_h


#define MCTimeInterVal 40
#define PSTimeInterVal 40
#define MSTimeInterVal 40


#define FontScale (ScreenScale>=3?2.1:ScreenScale)

#define App3xfont(s) (FontScale/2)*s

#define FontName @"Heiti SC"

//#define MSGYHFont(s) [UIFont fontWithName:FontName size:floor(App3xfont(s))]
#define MSGYHFont(s) [UIFont fontWithName:@"Heiti SC" size:floor(App3xfont(s))]

//#define MSGFont(s) [UIFont fontWithName:FontName size:s]
#define MSGFont(s) [UIFont fontWithName:@"Heiti SC" size:s]
#define MSGHTFont(s) [UIFont fontWithName:@"Heiti SC" size:s]

#define CellTitleColr [UIColor colorFromHexRGB:@"4d4d4d"]

#define TransParentNavBg [UIImage imageNamed:@"bg_nav_transparent"]
#define LeafDefaultColor @"000000"
#define SliderWidth (AppWindow.width*2/3.0f)

#define ProductPlaceImage nil
#define NewsPlaceImage nil
#define PhotoPlaceImage nil

//cookie 键
#define kIDKey @"id"
#define kUserNameKey @"username"
#define kLoginUserKey @"login_user"
#define kUserDefaultsCookie @"kUserDefaultsCookie"
#define kAppInfo @"app_info"
#define kAllLimbs @"app_limbs"
#define kAppDiyFunBar @"app_diyfunc_bar"

#define kWebAppInfo @"app_webapp"
#define kThirdShare @"app_third_share"
#define kOldPermissionKey @"app_oldpermission"
#define kNewPermissionKey @"app_newpermission"
#define kAppBanner @"app_banner"
#define kAppFilter @"app_filter"
#define kAppRegType @"app_regtype"
#define kLoginKey @"isLogin"
#define kUserInfoKey @"login_user_count"
#define kFilterInit @"filter_init"

#define kAppInit @"appdata_inited"
#define kUserInit @"userdata_inited"

#define DrawFontName  FontName
#define DrawPan 10


#define UserPlaceImage [UIImage imageNamed:@"default_head"]

#define IconPlaceImage nil

#define TabPlaceImage nil

#define ImagePlaceImage nil
#define VideoPlaceImage nil
#define AudioPlaceImage nil

#define ThumbnailPlaceImage nil

#define DefaultFontName FontName

#define effectUserImage [UserPlaceImage applyTintEffectWithColor:[UIColor colorWithWhite:0.00 alpha:0.05]]

#define NAV_H 64.0f

#define STATUS_H 20.0f
#define Tab_Scale ([UIScreen mainScreen].scale>2?1.2:[UIScreen mainScreen].scale/2)

#define TAB_H  49


#define LeafMenuScale 1.30f

#define DefaultInset 8
#define DefaultPan 10
#define DefaultPlc 5


#define SQR(clumns) [UIScreen mainScreen].bounds.size.width/clumns

#define BlackBackImage [UIImage imageNamed:@"ic_back"]
#define WhiteBackImage [UIImage imageNamed:@"ic_back_white"]

typedef void(^onClick)(id data);


//客户端第一次启动键
#define kAppFirstOpen CRString(@"first_open_%@",CRAppBuild)

//登录用户键
#define kCurUser   [UserDataManager sharedManager].loginUser
#define kCurUserName [UserDataManager sharedManager].loginUser.userName
#define LoginState    CRUserBOOL(kLoginKey)

//当前app键
#define kCurAppInfo [LocalManager objectForKey:kAppInfo]
#define kCurApp [AppDataManager sharedManager].curApp
#define kCurAppID [AppDataManager sharedManager].curApp.aid
#define kCurThirdShare  CRUserObj(kThirdShare)

//webapps
#define kAllWebApps [AppDataManager sharedManager].webApps
#define kDiyfuncbar [AppDataManager sharedManager].curApp.menuBar

//registertype
#define kRegisterType [AppDataManager sharedManager].registerType

//保存渠道号
#define KsaveChannelID @"KsaveChannelID"
//轮播图
#define kCurAppBanner [LocalManager objectForKey:kAppBanner]
//全局过滤数据
#define kCurAppFilter [LocalManager objectForKey:kAppFilter]
//注册类型
//自定义功能兰
#define kCurCustomBarItems [PermissonManager sharedManager].customTabBarItems
#define kCurSidBarKind kCurApp.sideBar.kind


#define kMessageNotification @"MessageNotification"
#define kChatMessageNotification @"ChatMessageNotification"
#define kPubeNotification @"PubNotification"
#define kXMPPConnectStateChanged @"XMPPConnectStateChanged"
#define KheadImageComed @"headImageComed"


static NSString *BaseAppNameChatRoom = @"chatroom";
static NSString *BaseAppNameGroupChat = @"groupchat";
static NSString *BaseAppNameService = @"customerservice";
static NSString *BaseAppNameSignin = @"signin";
static NSString *BaseAppNameVirtualPay = @"virtualpay";


typedef NS_ENUM(NSUInteger, SOMessageType){
    SOMessageTypeText = 0,
    SOMessageTypePhoto,
    SOMessageTypeVideo,
    SOMessageTypeAudio,
    SOMessageTypeOther
} ;


#define NOTIFICATION_INTERNET_STATUS @"NOTIFICATION_INTERNET_STATUS"
#define NOTIFICATION_CHAT_REFRESH @"NOTIFICATION_CHAT_REFRESH"
#define NOTIFICATION_CHAT_NEW @"NOTIFICATION_CHAT_NEW"
#define NOTIFICATION_CHAT_SUCCESS @"NOTIFICATION_CHAT_SUCCESS"
#define NOTIFICATION_CHAT_FAILED @"NOTIFICATION_CHAT_FAILED"
#define NOTIFICATION_CHAT_SUCCESS @"NOTIFICATION_CHAT_SUCCESS"




#endif
