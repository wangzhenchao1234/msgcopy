//
//  OauthManager.h
//  msgcopy
//
//  Created by wngzc on 15/7/16.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

# pragma mark - LoginActions

@interface OauthManager : NSObject

+(void)loginSinaPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed;
+(void)loginQQPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed;
+(void)loginWxPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed;
# pragma mark - register actions

+(void)registerThirdPlt:(NSString*)type params:(NSDictionary*)params openID:(NSString*)openID success:(requestComplete)success failed:(requestComplete)failed;
# pragma mark - BindActions

+(void)bindSinaPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed;
+(void)bindWxPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed;
+(void)bindQQPlt:(NSString*)openid success:(requestComplete)success failed:(requestComplete)failed;
+(void)deBindWxPlt:(NSString*)appid success:(requestComplete)success failed:(requestComplete)failed;
+(void)deBindQQPlt:(NSString*)appid success:(requestComplete)success failed:(requestComplete)failed;
+(void)deBindSinaPlt:(NSString*)appid success:(requestComplete)success failed:(requestComplete)failed;
@end
