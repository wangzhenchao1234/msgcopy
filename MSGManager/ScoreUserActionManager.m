//
//  ScoreUserActionManager.m
//  Kaoke
//
//  Created by wngzc on 15/3/23.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "ScoreUserActionManager.h"
#import "SBJson.h"

@implementation ScoreUserActionManager

+(void)doUserAction:(NSString*)type success:(requestComplete)success failed:(requestComplete)failed
{
    if (!CRWebAppTitle(@"pointmanage")&&![type isEqualToString:USER_SIGNIN_ACTION]) {
        failed(@"未绑定积分功能",0,nil,nil);
        return;
    }
    [ScoreUserActionManager doUserAction:type user:kCurUser.userName success:success failed:failed];
}
+(void)doUserAction:(NSString*)type user:(NSString*)username success:(requestComplete)success failed:(requestComplete)failed
{
    if (!CRWebAppTitle(@"pointmanage")&&![type isEqualToString:USER_SIGNIN_ACTION]) {
        failed(@"未绑定积分功能",0,nil,nil);
        return;
    }
    NSDictionary *params = @{
                             @"app":CRString(@"%d",kCurAppID),
                             @"username":username,
                             @"content_type":type
                             };
    [MSGRequestManager MKPost:kAPIScoreUserAction params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
}
+(void)doUserAction:(NSString*)type user:(NSString*)username currentStatus:(BOOL)status success:(requestComplete)success failed:(requestComplete)failed
{
    if ((!!CRWebAppTitle(@"pointmanage")&&![type isEqualToString:USER_PUB_ACTION])&&(!!CRWebAppTitle(@"pointmanage")&&![type isEqualToString:USER_COMMENT_ACTION])&&(!!CRWebAppTitle(@"pointmanage")&&![type isEqualToString:USER_REGISTER_ACTION])&&(!!CRWebAppTitle(@"pointmanage")&&![type isEqualToString:USER_UABROWSE_ACTION]) ) {
        //        NSLog(@"!+++++++++++++++++++++%@",type);
        
        failed(@"未绑定积分功能",0,nil,nil);
        return;

    }
    if (status) {
        [ScoreUserActionManager getAllUserActionStatus:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            NSArray * pointsJson = data;
            __block NSDictionary *pointData = nil;
            [pointsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj[@"content_type"] isEqualToString:type]) {
                    pointData = obj;
                    *stop = true;
                }
            }];
            if (pointData&&[pointData[@"status"]  boolValue]&&[pointData[@"openstatus"] boolValue]) {
                [ScoreUserActionManager doUserAction:type user:username success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    success(msg,code,data,requestURL);
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    failed(msg,code,data,requestURL);
                }];
            }

        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
        {
            failed(msg,code,data,requestURL);
        }];
        
    }else{
        [ScoreUserActionManager doUserAction:type success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            success(msg,code,data,requestURL);

        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
         {
             failed(msg,code,data,requestURL);
        }];
    }
}

+(void)getAllUserActionStatus:(requestComplete)success failed:(requestComplete)failed{
    
    [MSGRequestManager Get:kAPIUserActionStatus params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [LocalManager storeObject:data forKey:@"pointmanager_json"];
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
}


@end
