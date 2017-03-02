//
//  OauthManager.m
//  msgcopy
//
//  Created by Gavin on 15/7/16.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "OauthManager.h"

@implementation OauthManager

# pragma mark - LoginActions

+(void)loginSinaPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed{
    
    NSDictionary *params = @{
                             @"uid":openid
                             };
    [MSGRequestManager MKPost:kAPILoginSina params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [[UserDataManager sharedManager] userInfoSuccess:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
            CRLog(@"Third login user : \n%@",data);
            CRUserSetBOOL(true, kLoginKey);
            [LocalManager storeObject:data forKey:@"login_user_count"];
            
            [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                success(msg,code,data,requestURL);
            }];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            failed(msg,code,data,requestURL);
        }];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];

}
+(void)loginQQPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed{
    NSDictionary *params = @{
                             @"openid":openid
                             };
    [MSGRequestManager MKPost:kAPILoginQQ params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [[UserDataManager sharedManager] userInfoSuccess:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
            CRLog(@"Third login user : \n%@",data);
            CRUserSetBOOL(true, kLoginKey);
            [LocalManager storeObject:data forKey:@"login_user_count"];
            
            [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                success(msg,code,data,requestURL);
            }];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            failed(msg,code,data,requestURL);
        }];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];

}
+(void)loginWxPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed{
    
    //NSString*appid = (NSString*)kCurAppID;
    NSDictionary *params = @{
                             @"wx_openid":openid,
                             };
    NSLog(@"params==%@",params);
    [MSGRequestManager MKPost:kAPILoginWeixin params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [[UserDataManager sharedManager] userInfoSuccess:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
            CRLog(@"Third login user : \n%@",data);
            CRUserSetBOOL(true, kLoginKey);
            [LocalManager storeObject:data forKey:@"login_user_count"];
            
            [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                success(msg,code,data,requestURL);
            }];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
            failed(msg,code,data,requestURL);
            
        }];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];

}

# pragma mark - register actions

+(void)registerThirdPlt:(NSString*)type params:(NSDictionary*)params openID:(NSString*)openID success:(requestComplete)success failed:(requestComplete)failed
{
//    [MSGRequestManager Post:kAPIThirdRegister params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//        UserEntity *user = [UserEntity buildInstanceByJson:data];
//        NSDictionary *params = @{
//                                 @"username":user.userName,
//                                 @"password":user.passWord
//                                 };
        [[UserDataManager sharedManager] doLogin:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            if ([type isEqualToString:@"qq"]) {
                [self bindQQPlt:openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [OauthManager doUserAction:params[@"username"]];
                    [OauthManager updateUserInfo:type];
                    success(nil,code,data,nil);
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    failed(msg,code,data,nil);
                }];
                
            }else if([type isEqualToString:@"sina"]){
               [self bindSinaPlt:openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                   [OauthManager doUserAction:params[@"username"]];
                   [OauthManager updateUserInfo:type];
                   success(nil,code,data,nil);
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    failed(msg,code,data,nil);
                }];
                
            }else if([type isEqualToString:@"weixin"]){
                [self bindWxPlt:openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [OauthManager doUserAction:params[@"username"]];
                    [OauthManager updateUserInfo:type];
                    success(nil,code,data,nil);
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    failed(msg,code,data,nil);
                }];
            }
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                failed(msg,code,data,requestURL);
        }];
        
//    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//        failed(msg,code,data,requestURL);
//    }];
    
}
+(void)doUserAction:(NSString*)username{
    
    [ScoreUserActionManager doUserAction:USER_REGISTER_ACTION success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSLog(@"注册送积分");

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSLog(@"注册送积分失败");
    }];

}
+(void)updateUserInfo:(NSString*)type{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([type isEqualToString:@"sina"]) {
            [UserEntity updateUserInfoWithWeiboInfo:^{
                
            }];
        }else if([type isEqualToString:@"qq"]){
            [UserEntity updateUserInfoWithQQInfo:^{
                
            }];
        }else if([type isEqualToString:@"weixin"]){
            [UserEntity updateUserInfoWithWxInfo:^{
                
            }];
        }
    });

}
# pragma mark - BindActions

+(void)bindSinaPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed{
    
    NSDictionary *params = @{
                             @"uid":openid
                             };
    [MSGRequestManager MKPost:kAPIBindSina params:params success:^(NSString *msg,NSInteger code, id data, NSString *requestURL) {
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg,NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
    
}

+(void)bindWxPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed
{
    NSDictionary *params = @{@"wx_openid":openid,                             @"app":@(kCurAppID)
};
    [MSGRequestManager MKPost:kAPIBindWeixin params:params success:^(NSString *msg,NSInteger code, id data, NSString *requestURL) {
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg,NSInteger code ,id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
}

+(void)bindQQPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed{
    
    NSDictionary *params = @{
                             @"openid":openid
                             };
    [MSGRequestManager MKPost:kAPIBindQQ params:params success:^(NSString *msg,NSInteger code, id data, NSString *requestURL) {
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code,id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
    
}

+(void)deBindWxPlt:(NSString*)appid success:(requestComplete)success failed:(requestComplete)failed
{
    [MSGRequestManager MKDelete:kAPIDeBindWeixin(appid) params:nil success:^(NSString *msg,NSInteger code, id data, NSString *requestURL) {
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg,NSInteger code,id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
}
+(void)deBindQQPlt:(NSString*)appid success:(requestComplete)success failed:(requestComplete)failed
{
    [MSGRequestManager MKDelete:kAPIDeBindQQ(appid) params:nil success:^(NSString *msg,NSInteger code, id data, NSString *requestURL) {
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code,id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
}
+(void)deBindSinaPlt:(NSString*)appid success:(requestComplete)success failed:(requestComplete)failed
{
    [MSGRequestManager MKDelete:kAPIDeBindSina(appid) params:nil success:^(NSString *msg, NSInteger code,id data, NSString *requestURL) {
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code,id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
}

@end
