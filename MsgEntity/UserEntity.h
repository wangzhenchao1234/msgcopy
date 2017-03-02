//
//  UserEntity.h
//  msgcopy
//
//  Created by Gavin on 15/4/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserEntity : NSObject
@property (nonatomic,assign) NSInteger uid;
@property (nonatomic,assign) NSInteger headId;
@property (nonatomic,copy) NSString  *confirmPass;
@property (nonatomic,copy) NSString  * userName;
@property (nonatomic,copy) NSString  * firstName;
@property (nonatomic,copy) NSString  * lastName;
@property (nonatomic,copy) NSString  * passWord;
@property (nonatomic,copy) NSString  * cookie;
@property (nonatomic,copy) NSString  * city;
@property (nonatomic,copy) NSString  * mood;
@property (nonatomic,copy) NSString  * company;
@property (nonatomic,copy) NSString  * head100;
@property (nonatomic,copy) NSString  * head50;
@property (nonatomic,copy) NSString  * head320;
@property (nonatomic,copy) NSString  * birthday;
@property (nonatomic,copy) NSString  * prov;
@property (nonatomic,copy) NSString  * email;
@property (nonatomic,copy) NSString  * sina_uid;
@property (nonatomic,copy) NSString  * wx_openid;
@property (nonatomic,copy) NSString  * qq_openid;
@property (nonatomic,copy) NSString  * qrpath;

@property (nonatomic,assign)BOOL gender;

+(UserEntity*)buildInstanceByJson:(NSDictionary*)json;
+(instancetype)buildInstanceByMasterJson:(NSDictionary*)json;
-(UserEntity*)init:(NSString*)name Pw:(NSString*)pw firstName:(NSString *)firstName headImage:(NSString*)headImage mood:(NSString *)mood;
-(UserEntity*)init:(NSString*)name Pw:(NSString*)pw;
-(UserEntity*)initWithUser:(NSString*)user First:(NSString*)first Last:(NSString*)last;
-(void)buildProfileByJson:(NSDictionary*)json;
-(void) changeAttr:(NSString*)attr value:(NSString*)value success:(requestComplete)success failed:(requestComplete)failed;
-(void)changeUserName:(NSString *)userName andNewPass:(NSString *)newPW success:(requestComplete)success failed:(requestComplete)failed;
/**
 *  微信数据更新
 */
+(void)updateUserInfoWithWxInfo:(void(^)(void))complete;
/**
 *  qq数据更新
 */
+(void)updateUserInfoWithQQInfo:(void(^)(void))complete;
/**
 *  QQ更新个信息
 */
+(void)updateUserInfoWithWeiboInfo:(void(^)(void))complete;
@end
