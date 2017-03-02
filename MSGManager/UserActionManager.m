//
//  UserActionManager.m
//  msgcopy
//
//  Created by Gavin on 15/8/19.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "UserActionManager.h"

@implementation UserActionManager

+(void)applicationRecordPubRead:(PubEntity*)pub
{
    NSDictionary *params = @{@"publication":CRString(@"%d",pub.pid)};
    [MSGRequestManager MKPost:kAPIPubClick params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        CRLog(@"浏览投稿记录");
        CRWeekRef(self);
        MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
        CRWeekRef(hud);
        [__hud hide:true];
        //            CommentEntity *comment = [CommentEntity buildInstanceByJson:data];
        //浏览成功
        [ScoreUserActionManager doUserAction:USER_UABROWSE_ACTION user:kCurUser.userName currentStatus:true success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
            //                userPoint = nil;
            if (CRWebAppTitle(@"pointmanage")) {
                //                    NSLog(@"========绑定积分");
                MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
                if (!hud) {
                    hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                    [AppWindow addSubview:hud];
                    hud.removeFromSuperViewOnHide = true;
                }
                [hud show:true];
                //                    CRWeekRef(self);
                [MSGRequestManager Get:kAPIPoint params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    
                    //                                NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!data - %@",data);
                    
                    //获取积分状态
                    //                        userPoint = data;
                    [ScoreUserActionManager getAllUserActionStatus:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        __block NSDictionary *pointPub = nil;
                        NSArray * pointsJson = data;
                        [pointsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            //                                NSLog(@"。。。。。。。。。。。。。。。。。。。。。。。%@",obj[@"content_type"]);
                            NSInteger i = 0;
                            ++i;
                            NSInteger ciShu = [pointPub[@"maxnum"] integerValue];
                            //积分启用状态
                            
                            if ([pointPub[@"openstatus"] boolValue]&&[pointPub[@"status"] boolValue]&&i<=ciShu)  {
                                pointPub = obj;
                                
                                //                                 NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!pointPub - %@",pointPub);
                                
                                *stop = true;
                            }
                        }];
                        //积分启用状态
                        if ([pointPub[@"openstatus"] boolValue]&&[pointPub[@"status"] boolValue]) {
                            
                            
                            //                                                                                NSLog(@"。。。。。。。。。积分启用状态。。。。。。。。");
                            
                            
                            NSInteger point = [pointPub[@"point"] longLongValue];
                            
                            //                                                                                NSLog(@"。。。。。。。。。%d。。。。。。。。",point);
                            
                            //                                NSString *type = pointPub[@"point_type"];
                            
                            //                                                                                NSLog(@"..............%@......",type);
                            [CustomToast showMessageOnWindow:CRString(@"您的积分增加：%d",point)];
                            //加积分不提示
                            
                        }else{
                            //积分未启用直接跳过检查
                        }
                        
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
            
            CRLog(@"浏览积分++");
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            CRLog(@"%@",msg);
            
        }];

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        CRLog(@"浏览投稿记录失败");
    }];
    
}
+(void)userRecordPubRead:(PubEntity*)pub
{
    if (!LoginState) {
        return;
    }
    NSDictionary *params = @{
                             @"pub_id":CRString(@"%d",pub.pid),
                             @"pub_title":CRString(@"%@",pub.title),
                             @"op":@"browser"
                             };
    [UserActionManager userAction:params];
}
+(void)userRecordPubArticle:(PubEntity*)pub
{
    if (!LoginState) {
        return;
    }
    NSDictionary *params = @{
                             @"pub_id":CRString(@"%d",pub.pid),
                             @"pub_title":CRString(@"%@",pub.title),
                             @"op":@"article"
                             };
    [UserActionManager userAction:params];

    
}
+(void)userPubLike:(PubEntity*)pub
{
    if (!LoginState) {
        return;
    }
    NSDictionary *params = @{
                             @"pub_id":CRString(@"%d",pub.pid),
                             @"pub_title":CRString(@"%@",pub.title),
                             @"op":@"like"
                             };
    [UserActionManager userAction:params];

}
+(void)userBrowsMap:(PubEntity*)pub
{
    if (!LoginState) {
        return;
    }
    NSDictionary *params = @{
                             @"pub_id":CRString(@"%d",pub.pid),
                             @"pub_title":CRString(@"%@",pub.title),
                             @"op":@"map"
                             };
    [UserActionManager userAction:params];

    
}
+(void)userAddComments:(PubEntity*)pub
{
    if (!LoginState) {
        return;
    }
    NSDictionary *params = @{
                             @"pub_id":CRString(@"%d",pub.pid),
                             @"pub_title":CRString(@"%@",pub.title),
                             @"op":@"browser"
                             };
    [UserActionManager userAction:params];

}
+(void)userDoShareSina:(PubEntity*)pub
{
    if (!LoginState) {
        return;
    }
    NSDictionary *params = @{
                             @"pub_id":CRString(@"%d",pub.pid),
                             @"pub_title":CRString(@"%@",pub.title),
                             @"op":@"sweibo"
                             };
    [UserActionManager userAction:params];

    
}
+(void)userDoShareWeichat:(PubEntity*)pub{
    if (!LoginState) {
        return;
    }
    NSDictionary *params = @{
                             @"pub_id":CRString(@"%d",pub.pid),
                             @"pub_title":CRString(@"%@",pub.title),
                             @"op":@"sweixin"
                             };
    [UserActionManager userAction:params];

}
+(void)userDoShareCircleFriends:(PubEntity*)pub{
    if (!LoginState) {
        return;
    }
    NSDictionary *params = @{
                             @"pub_id":CRString(@"%d",pub.pid),
                             @"pub_title":CRString(@"%@",pub.title),
                             @"op":@"sfriends"
                             };
    [UserActionManager userAction:params];

}

+(void)userAction:(NSDictionary*)params
{
    [MSGRequestManager MKPost:kAPIUserAction params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        CRLog(@"用户行为记录：%@",params[@"op"]);
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        CRLog(@"用户行为记录失败:%@",params[@"op"]);
    }];
}

@end
