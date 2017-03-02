//
//  QQOauth.m
//  msgcopy
//
//  Created by wngzc on 15/7/16.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "QQOauth.h"
#import <TencentOpenAPI/TencentOAuth.h>

typedef NS_ENUM(NSInteger, QQOauthType) {
    
    QQOauthTypeLogin,
    QQOauthTypeBind
    
};

@interface QQOauth()
{
    TencentOAuth *_oauth;
    QQOauthType _oauthType;
}
@property(nonatomic,copy)void(^oauthCallBack)(BOOL reult,id data);
@property(nonatomic,copy)void(^registerCallBack)(NSString*openID);

@end

static QQOauth *manager = nil;

@implementation QQOauth

+(instancetype)sharedQQOauth
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[QQOauth alloc] init];
    });
    return manager;
}
#pragma --mark QQ登陆

- (void)doQQLoginOauth:(void(^)(BOOL reult,id data))complete shouldRegister:(void(^)(NSString*openID))registerBlock{
    self.oauthCallBack = complete;
    self.registerCallBack = registerBlock;
    _oauthType = QQOauthTypeLogin;
    [self startOauth];
}
- (void)doQQBindOauth:(void(^)(BOOL reult,id data))complete
{
    self.oauthCallBack = complete;
    _oauthType = QQOauthTypeBind;
    [self startOauth];
}
-(void)startOauth
{
    if (!_oauth) {
        _oauth = [[TencentOAuth alloc] initWithAppId:QQAPP_ID andDelegate:(id<TencentSessionDelegate>)self];
    }
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_ALBUM,
                            kOPEN_PERMISSION_ADD_IDOL,
                            kOPEN_PERMISSION_ADD_ONE_BLOG,
                            kOPEN_PERMISSION_ADD_PIC_T,
                            kOPEN_PERMISSION_ADD_SHARE,
                            kOPEN_PERMISSION_ADD_TOPIC,
                            kOPEN_PERMISSION_CHECK_PAGE_FANS,
                            kOPEN_PERMISSION_DEL_IDOL,
                            kOPEN_PERMISSION_DEL_T,
                            kOPEN_PERMISSION_GET_FANSLIST,
                            kOPEN_PERMISSION_GET_IDOLLIST,
                            kOPEN_PERMISSION_GET_INFO,
                            kOPEN_PERMISSION_GET_OTHER_INFO,
                            kOPEN_PERMISSION_GET_REPOST_LIST,
                            kOPEN_PERMISSION_LIST_ALBUM,
                            kOPEN_PERMISSION_UPLOAD_PIC,
                            kOPEN_PERMISSION_GET_VIP_INFO,
                            kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                            kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                            kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                            nil];
    [_oauth authorize:permissions inSafari:true];
}
-(void)tencentDidLogin{
    
    [_oauth getUserInfo];
    
}

-(void)tencentDidNotNetWork{
    
    self.oauthCallBack(false,@"请检查当前网络");

}

- (void)tencentDidNotLogin:(BOOL)cancelled{
    
    self.oauthCallBack(false,@"授权失败");
    
}

-(void)getUserInfoResponse:(APIResponse *)response{
    
    if (response.retCode != 0) {
        [CustomToast showMessageOnWindow:response.errorMsg];
        return;
    }
    CRUserSetObj([response.message dataUsingEncoding:NSUTF8StringEncoding], @"qq_user_info");
    if (_oauthType == QQOauthTypeLogin) {
        CRWeekRef(self);
        [OauthManager loginQQPlt:_oauth.openId success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            __self.oauthCallBack(true,_oauth.openId);
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            if (code == 400) {
                if (_registerCallBack) {
                    _registerCallBack(_oauth.openId);
                }else{
                    __self.oauthCallBack(false,msg);
                }
            }else{
                __self.oauthCallBack(false,msg);
            }
        }];

    }else if(_oauthType == QQOauthTypeBind){
        CRWeekRef(self);
        [OauthManager bindQQPlt:_oauth.openId success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            __self.oauthCallBack(true,_oauth.openId);
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            __self.oauthCallBack(false,msg);
        }];
    }
}

@end
