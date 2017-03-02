//
//  UserDataManager.h
//  msgcopy
//
//  Created by Gavin on 15/4/8.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserEntity;

typedef void(^intilizedUserDataComplete)(BOOL result);
@interface UserDataManager : NSObject
@property(nonatomic,retain)UserEntity *loginUser;
/**
 *  keychain账号信息
 */
+(instancetype)sharedManager;
/**
 *  初始化用户相关数据
 */
+(void)intilizedUserDataForTarget:(UIViewController*)target progress:(void(^)(CGFloat progress))progress complete:(intilizedUserDataComplete)complete;
/**
 *  登录
 */
-(void)doLogin:(NSDictionary*)userInfo success:(requestComplete)success failed:(requestComplete)failed;
/**
 *  获取用户信息
 */
-(void)userInfoSuccess:(requestComplete)success failed:(requestComplete)failed;
+(NSDictionary*)keychainUser;
@end
