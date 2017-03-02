//
//  UserDataManager.m
//  msgcopy
//
//  Created by wngzc on 15/4/8.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "UserDataManager.h"
#import "SSKeychain.h"


@interface UserDataManager()
@property(nonatomic,weak)UIViewController *targetViewController;
@property(nonatomic,copy)void(^callBack)(BOOL result);
@property(nonatomic,copy)void(^progressBlock)(CGFloat progress);

@end

@implementation UserDataManager
CRManager(UserDataManager);
#pragma mark - 初始化用户数据
/**
 * 初始化用户数据
 */
+(void)intilizedUserDataForTarget:(UIViewController *)target progress:(void(^)(CGFloat progress))progress complete:(intilizedUserDataComplete)complete
{
    [UserDataManager sharedManager].callBack = complete;
    [UserDataManager sharedManager].progressBlock = progress;
//    UserDataManager *manager = [UserDataManager sharedManager];
//    if (CRUserBOOL(kUserInit)) {
//  
//        NSDictionary *userInfo = [LocalManager objectForKey:kUserInfoKey];
//        if (userInfo) {
//            //已经初始化直接
//            if (CRUserObj(kUserDefaultsCookie)) {
//                NSString *userInfoURL = kAPIUserInfo;
//                [GCookieManager setCookie:userInfoURL];
//            }
//            manager.loginUser = [[UserEntity alloc] init];
//            [manager.loginUser buildProfileByJson:userInfo];
//            [[UserDataManager sharedManager] checkUpdate];
//            manager.progressBlock(0.3);
//            return;
//        }
//        
//    }
    //初始化用户数据
    [UserDataManager sharedManager].targetViewController = target;
    [[UserDataManager sharedManager] start];
}
#pragma mark - 登录
/**
 *  登录
 */
-(void)start{
    
    if (CRUserObj(kUserDefaultsCookie)) {
        NSString *userInfoURL = kAPIUserInfo;
        [GCookieManager setCookie:userInfoURL];
    }
    /**
     *  检查cookie是否有效
     *
     *  @param msg        错误信息
     *  @param data       报文数据
     *  @param requestURL 请求地址
     *
     */
    CRWeekRef(self);
    [MSGRequestManager Get:kAPILogin params:nil success:^(NSString *msg,NSInteger code, id data, NSString *requestURL) {
        //返回用户信息证明cookie有效，获取个人信息
        __self.progressBlock(0.1);
        [__self userInfoSuccess:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            __self.progressBlock(0.2);
            NSDictionary *loginUser = data;
            if (!_loginUser) {
                _loginUser = [[UserEntity alloc] init];
                NSDictionary *countInfo = [LocalManager objectForKey:kUserInfoKey];
                NSString *username = countInfo[@"username"];
                NSString *password = countInfo[@"password"];
                _loginUser.userName = username;
                _loginUser.passWord = password;
                if ([username rangeOfString:@"kaoke"].location == NSNotFound) {
                    CRUserSetBOOL(true, kLoginKey);
                }else{
                    CRUserSetBOOL(false, kLoginKey);
                }
            }
            [_loginUser buildProfileByJson:data];
            CRUserSetBOOL(true, kUserInit);
            //保存登录用户信息
            [LocalManager storeObject:loginUser forKey:kLoginUserKey];
            //检查更新
            [__self checkUpdate];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__self startFailed:msg];
        }];
        
    } failed:^(NSString *msg,NSInteger code, id data, NSString *requestURL) {
        
        CRUserSetBOOL(false, kLoginKey);
        if (code == 302 || code == 401) {
            //cookie失效或者没有权限
            /**
             * 钥匙串账号 username=%@&password=%@
             */
            NSDictionary *keychainUserInfo = [UserDataManager keychainUser];
            if (keychainUserInfo) {
                //钥匙串设备号已存在
                [__self doLogin:keychainUserInfo success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    //获取用户信息
                    [__self userInfoSuccess:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        NSDictionary *loginUser = data;
                        CRUserSetBOOL(true, kUserInit);
                        //保存登录用户信息
                        [LocalManager storeObject:loginUser forKey:kLoginUserKey];
                        //检查更新
                        [__self checkUpdate];
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [__self startFailed:msg];
                    }];
                    
                }failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    if (code == 400) {
                        [UserDataManager deleteKeychainUser:keychainUserInfo[@"username"] password:keychainUserInfo[@"password"]];
                        [__self startFailed:msg];
                        return;
                    }
                    [__self startFailed:msg];
                }];

            }else{
                //钥匙串设备号不存在，注册一个
                [__self autoRegisterCountSuccess:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    //保存用户信息到钥匙串
                    [UserDataManager storeKeychainUser:data[@"username"] password:@"1234"];
                    //登录
                    //自动生成UUID
                    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
                    NSString *strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
                    //对UUID进行16位MD5编码
                    NSString *MD5deviceId = [NSString getmd5_16WithString:strUUID];
                    NSDictionary *userInfo= @{
                                              @"username":data[@"username"],
                                              @"password":@"1234",
                                              @"imei":MD5deviceId
                                              };
                    [__self doLogin:userInfo success:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
                     {
                         //获取用户信息
                         [__self userInfoSuccess:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                             NSDictionary *loginUser = data;
                             //保存登录用户信息
                             [LocalManager storeObject:loginUser forKey:kLoginUserKey];
                             //检查更新
                             [__self checkUpdate];
                         } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                             [__self startFailed:msg];
                         }];
                         
                     } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                         [__self startFailed:msg];
                     }];
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [__self startFailed:msg];
                }];
            }
            
        }else{
            //发生错误退出
            if ([MSGRequestManager isNetworkEnabled]) {
                //网络正常
                [__self startFailed:msg];
            }else if(CRUserBOOL(kUserInit)){
                UserDataManager *manager = [UserDataManager sharedManager];
                NSDictionary *userInfo = [LocalManager objectForKey:kUserInfoKey];
                if (userInfo) {
                    //已经初始化直接
                    if (CRUserObj(kUserDefaultsCookie)) {
                        NSString *userInfoURL = kAPIUserInfo;
                        [GCookieManager setCookie:userInfoURL];
                    }
                    manager.loginUser = [[UserEntity alloc] init];
                    [manager.loginUser buildProfileByJson:userInfo];
                    [[UserDataManager sharedManager] checkUpdate];
                   manager.progressBlock(0.3);
                }else{
                    //用户数据不存在
                    [__self startFailed:msg];
                }
            }else{
                //未初始化
                [__self startFailed:msg];
            }
        }
    }];
    
}
#pragma mark - 登录
/**
 *  登录
 */
-(void)doLogin:(NSDictionary*)userInfo success:(requestComplete)success failed:(requestComplete)failed{
    /**
     *  登录
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL 接口url
     *
     */
    CRWeekRef(self);
    [MSGRequestManager Post:kAPILogin params:userInfo success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        _loginUser = [UserEntity buildInstanceByJson:data];
        [LocalManager storeObject:userInfo forKey:kUserInfoKey];
        [__self userInfoSuccess:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            if ([_loginUser.userName rangeOfString:@"kaoke"].location == NSNotFound) {
                CRUserSetBOOL(true, kLoginKey);
                [ScoreUserActionManager doUserAction:USER_REGISTER_ACTION user:_loginUser.userName currentStatus:true success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    
                    //                userPoint = nil;
                    if (CRWebAppTitle(@"pointmanage")) {
                        MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
                        if (!hud) {
                            hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                            [AppWindow addSubview:hud];
                            hud.removeFromSuperViewOnHide = true;
                        }
                        [hud show:true];
                        //                    CRWeekRef(self);
                        [MSGRequestManager Get:kAPIPoint params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                            
                            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!data - %@",data);
                            
                            //获取积分状态
                            //                        userPoint = data;
                            [ScoreUserActionManager getAllUserActionStatus:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                [hud hide:true];
                                __block NSDictionary *pointPub = nil;
                                NSArray * pointsJson = data;
                                [pointsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                    if ([obj[@"content_type"] isEqualToString:USER_REGISTER_ACTION]) {
                                        pointPub = obj;
                                        
                                        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!pointPub - %@",pointPub);
                                        *stop = true;
                                        NSInteger i = 0;
                                        ++i;
                                        NSInteger ciShu = [pointPub[@"maxnum"] integerValue];
                                        //积分启用状态
                                        if ([pointPub[@"openstatus"] boolValue]&&[pointPub[@"status"] boolValue]&&i<=ciShu) {
                                            
                                            
                                            NSLog(@"。。。。。。。。。积分启用状态。。。。。。。。");
                                            
                                            
                                            NSInteger point = [pointPub[@"point"] longLongValue];
                                            
                                            //                                        NSLog(@"。。。。。。。。。%d。。。。。。。。",point);
                                            
                                            NSString *type = pointPub[@"point_type"];
                                            
                                            NSLog(@"..............%@......",type);
                                            //                                        [CustomToast showMessageOnWindow:CRString(@"注册成功！您的积分增加：%d",point)];
                                            
                                            
                                        }else{
                                            //积分未启用直接跳过检查
                                        }
                                    }
                                }];
                                
                                
                            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                [hud hide:true];
                                [GVConfirmView showConfirm:@"系统出错，无法继续操作" inView:AppWindow confirmButton:@"确定" action:^{
                                    //                                [__self.navigationController popViewControllerAnimated:true];
                                }cancelTitle:nil action:nil];
                                
                            }];
                            
                        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                            [hud hide:true];
                            [GVConfirmView showConfirm:@"系统出错，无法继续操作" inView:AppWindow confirmButton:@"确定" action:^{
                                //                            [__self.navigationController popViewControllerAnimated:true];
                            }cancelTitle:nil action:nil];
                        }];
                    }
                    
                    CRLog(@"注册积分++");
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    CRLog(@"%@",msg);
                    
                }];
            }else{
                CRUserSetBOOL(false, kLoginKey);
            }
            success(msg,code,data,requestURL);
        
            
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            failed(msg,code,data,requestURL);
        }];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
    
}
#pragma mark - 注册
/**
 *  注册
 */
-(void)autoRegisterCountSuccess:(requestComplete)success failed:(requestComplete)failed{
    
    //自动生成UUID
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
    //对UUID进行16位MD5编码
    NSString *MD5deviceId = [NSString getmd5_16WithString:strUUID];
    CRLog(@"UUID == %@",MD5deviceId);
    NSDictionary *params = @{
                             @"type":@"auto",
                             @"reg_ver":@"1",
                             @"device":MD5deviceId
                             };
    /**
     *  自动注册
     *
     *  @param msg        错误信息
     *  @param code       错误码
     *  @param data       报文数据
     *  @param requestURL 接口url
     *
     */
    [MSGRequestManager Post:kAPIAutoRegister params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [_loginUser buildProfileByJson:data];
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        //发生错误退出
        success(msg,code,data,requestURL);
    }];
}
#pragma mark - 用户信息
/**
 *  用户信息
 */
-(void)userInfoSuccess:(requestComplete)success failed:(requestComplete)failed
{
    /**
     *  用户信息
     *
     *  @param msg        错误信息
     *  @param code       错误码
     *  @param data       报文数据
     *  @param requestURL 接口url
     *
     */
    [MSGRequestManager Get:kAPIUserInfo params:nil success:^(NSString *msg, NSInteger code,id data, NSString *requestURL) {
        [LocalManager storeObject:data forKey:kUserInfoKey];
        [_loginUser buildProfileByJson:data];
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code,id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
    
}

/**
 *  keychain账号信息
 */
+(NSDictionary*)keychainUser {
    
    //自动生成UUID
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString *strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
    //对UUID进行16位MD5编码
    NSString *MD5deviceId = [NSString getmd5_16WithString:strUUID];
    
    //取出钥匙串内存储的账号信息
    NSArray *accounts = [SSKeychain accountsForService:[NSString stringWithFormat:@"kaoke%@",URL_DOMAIN] ];
    //用户名
    NSString *username = [[accounts lastObject] valueForKey:@"acct"];
    if (username) {
        //密码
        NSString *password = [SSKeychain passwordForService:[NSString stringWithFormat:@"kaoke%@",URL_DOMAIN]  account:username];
        if (password) {
            return @{@"username":username,@"password":password,@"imei":MD5deviceId};
        }
    }
    return nil;
}

/**
 *  保存账号信息到keychain
 *
 *  @param username 用户名
 *  @param password 密码
 */
+(void)storeKeychainUser:(NSString*)username password:(NSString*)password
{
    [SSKeychain setPassword:password forService:[NSString stringWithFormat:@"kaoke%@",URL_DOMAIN] account:username];
}
+(void)deleteKeychainUser:(NSString*)username password:(NSString*)password
{
    [SSKeychain deletePasswordForService:[NSString stringWithFormat:@"kaoke%@",URL_DOMAIN] account:username];
}
#pragma mark - 检查更新
/**
 *  检查更新
 */
-(void)checkUpdate
{
    /**
     *  更新请求
     *
     *  @param msg        错误信息
     *  @param data       报文内容 json
     *  @param requestURL 请求接口url
     *
     */
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIUpdate params:nil success:^(NSString *msg,NSInteger code, id data, NSString *requestURL) {
        __self.progressBlock(0.3);
        
        //初始化成功
        CRUserSetBOOL(true, kUserInit);
        
        if (CRUserBOOL(kAppFirstOpen)) {
            //第一次启动记录下载行为
            [__self sendDownloadAction:@"1" success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                
            }];
        }

        
        NSDictionary* update = data;
        NSComparisonResult result = NSOrderedSame;
        NSMutableString *originVersion = update[@"version"];
        /**
         *  以点分割版本号
         */
        NSArray *orVersionCM = [originVersion componentsSeparatedByString:@"."];//线上版本
        NSMutableString *localVersion = CRAppVersionShort;
        NSArray *lcVersionCM = [localVersion componentsSeparatedByString:@"."];//线下版本
        for (int i = 0 ; i <[lcVersionCM count] ; i++) {
            if ([orVersionCM[i] integerValue] > [lcVersionCM[i] integerValue] ) {
                result = NSOrderedDescending;//线上版本高
                break;
            }else if ([orVersionCM[i] integerValue] < [lcVersionCM[i] integerValue]){
                break;
            }
        }
        
        if(result == NSOrderedDescending)
        {
            CRWeekRef(self);
            //线上版本高提示升级
            if ([update[@"forced"] boolValue]) {
                //强制升级
                [GVConfirmView showConfirm:CRString(@"检测到新版本V%@是否升级",originVersion) inView:AppWindow confirmButton:@"是" action:^{
                    //确认升级
                    CRLog(@"确认升级");
                    [__self sendDownloadAction:@"2" success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        //goto下载
#ifdef DEBUG
                        _callBack(true);
#else
                        [Utility gotoURL:update[@"url"]];
                        [__self exite];
#endif

                      
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
#ifdef DEBUG
                        _callBack(true);
#else
                        _callBack(false);
#endif
                    }];
                } cancelTitle:@"否" action:^{
                    //不升级退出
                    [__self exite];
                    CRLog(@"不升级退出");
                }];
                return;
            }
            //非强制升级
            [GVConfirmView showConfirm:CRString(@"检测到新版本V%@是否升级",originVersion) inView:AppWindow confirmButton:@"是" action:^{
                //确认升级
                CRLog(@"确认升级");
                [__self sendDownloadAction:@"2" success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    //goto下载
                    [Utility gotoURL:update[@"url"]];
                    [__self exite];
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
#ifdef DEBUG
                    _callBack(true);
#else
                    _callBack(false);
#endif
                }];
                
            } cancelTitle:@"否" action:^{
                //不强制升级进入下一步
                if (_callBack) {
                    _callBack(true);
                }
                CRLog(@"不强制升级进入下一步");
            }];
            
        }else{
            //线下版本不高继续下一步
            if (_callBack) {
                _callBack(true);
            }
        }
        
    } failed:^(NSString *msg, NSInteger code,id data, NSString *requestURL) {
        //检查失败
        CRLog(@"检查升级失败");
        //初始化成功
        CRUserSetBOOL(true, kUserInit);
        if (_callBack) {
            _callBack(true);
        }
    }];

}
#pragma mark - 出现错误退出
/**
 * 出现错误退出
 */
-(void)startFailed:(NSString*)msg{
    //发生错误退出
    _callBack(false);
//    [GVAlertView showAlert:nil message:msg confirmButton:@"确定" action:^{
//        CRLog(@"确认退出");
//
//    } cancelTitle:nil action:nil];
    
}

#pragma mark - 强制退出客户端
/**
 *  强制退出客户端
 */
-(void)exite{
    
    _targetViewController.view.window.transform = CGAffineTransformMakeScale(1,1);
    [UIView animateWithDuration:.5 animations:^{
        _targetViewController.view.window.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            exit(0);
        }
    }];
    
}

#pragma mark - 升级记录事件
/**
 *  升级记录事件
 *
 *  @param type 记录类型 "1" 首次安装 "2" 升级安装
 */
-(void)sendDownloadAction:(NSString *)type success:(requestComplete)success failed:(requestComplete)failed{
    
    NSString *os_version = [UIDevice currentDevice].systemVersion;
    NSString *os_model = [UIDevice currentDevice].model;
    NSString *version = CRAppVersionShort;
    NSDictionary *params = @{
                             @"os_version":os_version,
                             @"os_model":os_model,
                             @"type":type,
                             @"version":version
                             };
    [MSGRequestManager MKPost:kAPIDownloadAction params:params success:^(NSString *msg,NSInteger code, id data, NSString *requestURL) {
        success(msg,code,data,requestURL);
        CRLog(@"升级记录行为成功");
    } failed:^(NSString *msg, NSInteger code,id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
        CRLog(@"升级记录行为失败");
    }];
    
}

@end
