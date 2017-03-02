//
//  ScoreUserActionManager.h
//  Kaoke
//
//  Created by wngzc on 15/3/23.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *USER_REGISTER_ACTION = @"register";
static NSString *USER_UABROWSE_ACTION = @"browse";
static NSString *USER_PUB_ACTION = @"create_pub";
static NSString *USER_ARTICLE_ACTION = @"article";
static NSString *USER_SHARE_ACTION = @"share";
static NSString *USER_COMMENT_ACTION = @"comment";
static NSString *USER_SIGNIN_ACTION = @"signin";


typedef NS_ENUM(NSInteger, UserActionType) {
    
    UAREGISTER = 0,
    UABROWSE,
    UAPUB,
    UASHARE,
    UACOMMENT,
    UAARTICLE,
    UASIGN
    
};

@interface ScoreUserActionManager : NSObject

+(void)doUserAction:(NSString *)type success:(requestComplete)success failed:(requestComplete)failed;
+(void)doUserAction:(NSString*)type user:(NSString*)username success:(requestComplete)success failed:(requestComplete)failed;
+(void)doUserAction:(NSString*)type user:(NSString*)username currentStatus:(BOOL)status success:(requestComplete)success failed:(requestComplete)failed;
+(void)getAllUserActionStatus:(requestComplete)success failed:(requestComplete)failed;
@end
