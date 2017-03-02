//
//  WeiChatOauth.m
//  msgcopy
//
//  Created by wngzc on 15/7/16.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "WeiChatOauth.h"
#import "AppDelegate.h"
#import "WXApi.h"

@implementation WeiChatOauth
#pragma mark - 微信登录

+(void)doWeixinLogin:(void(^)(BOOL result, id data))complete shouldRegister:(void(^)(NSString*openID))registerBlock
{
    if (![WXApi isWXAppInstalled]) {
        complete(false,@"检测到您尚未安装微信，请安装后重试");
        return;
    }else{
    [WeiChatOauth sendAuthRequest:^(id data) {
        NSLog(@"8888888888888888888 -- %@",data);
        [WeiChatOauth getAccess_tokenWithCode:data complete:^(BOOL result, id data) {
            NSString *openID =data;
            [OauthManager loginWxPlt:openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                complete(true,openID);
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                if (code == 400) {
                    
                    if (registerBlock) {
                        registerBlock(openID);
                    }else{
                        complete(false,@"授权失败");
                    }
                    
                }else{
                    complete(false,@"授权失败");
                }
            }];
        }];
    } error:^(id data) {
        complete(false,data);
    }];
    
}
}
+(void)doBindWeiChat:(void(^)(BOOL result, id data))complete;
{
    if (![WXApi isWXAppInstalled]) {
        complete(false,@"检测到您尚未安装微信，请安装后重试");
        return;
    }
    [WeiChatOauth sendAuthRequest:^(id data) {
        NSLog(@"data   ---------------------------- %@",data);
        
        [WeiChatOauth getAccess_tokenWithCode:data complete:^(BOOL result, id data) {
            NSString *openID =data;
           [OauthManager bindWxPlt:openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
               complete(true,openID);
           } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
               complete(false,msg);
           }];
        }];
    } error:^(id data) {
        complete(false,data);
    }];
}
+(void)doDeBindWeiChat:(NSString*)openID complete:(void (^)(BOOL, id))complete
{
    [OauthManager deBindWxPlt:openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        complete(true,@"解绑成功");
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        complete(false,msg);
    }];
}
+(void)sendAuthRequest:(void(^)(id data))authCallback error:(void(^)(id data))error
{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.weichatAuthCallBack = authCallback;
    delegate.weichatAuthErrorCallBack = error;
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"weichatOauth";
    [WXApi sendReq:req];
}

+(void)getAccess_tokenWithCode:(NSString*)code complete:(void(^)(BOOL result, id data))complete
{
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WXAppID,WXAppSecret,code];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                
               
//                 {
//                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
//                 "expires_in" = 7200;
//                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
//                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
//                 scope = "snsapi_userinfo,snsapi_base";
//                 }
                
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *openID = [Utility dictionaryValue:dic forKey:@"openid"];
                NSString *token = [Utility dictionaryValue:dic forKey:@"access_token"];
                if (openID&&token) {
                    [WeiChatOauth getUserInfo:openID accessToken:token complete:complete];
                }else{
                    complete(false,@"授权失败");
                }
            }
        });
    });
}
/**
 *  获取微信用户信息
 */
+(void)getUserInfo:(NSString*)openID accessToken:(NSString *)token complete:(void(^)(BOOL result ,id data))complete
{
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",token,openID];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSError *error = nil;
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:&error];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
                CRUserSetObj(openID,@"weixin_openid");
                CRUserSetObj(data,@"weichat_user_info");
                complete(true,openID);
            }else{
                complete(false,@"授权失败");
            }
        });
        
    });
}

@end
