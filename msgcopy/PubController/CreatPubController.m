//
//  CreatPubController.m
//  msgcopy
//
//  Created by wngzc on 15/8/10.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "CreatPubController.h"
static NSString *REDUCE = @"reduce";
static NSString *ADD = @"add";


@interface CreatPubController ()
{
    __block NSDictionary   *userPoint;
}
@end

@implementation CreatPubController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getPointInfo];
}

-(void)getPointInfo{
    userPoint = nil;
    if (CRWebAppTitle(@"pointmanage")) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
        if (!hud) {
            hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
            [AppWindow addSubview:hud];
            hud.removeFromSuperViewOnHide = true;
        }
        [hud show:true];
        CRWeekRef(self);
        [MSGRequestManager Get:kAPIPoint params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
//            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!data - %@",data);
            
            //获取投稿积分状态
            userPoint = data;
            [ScoreUserActionManager getAllUserActionStatus:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                __block NSDictionary *pointPub = nil;
                NSArray * pointsJson = data;
                [pointsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj[@"content_type"] isEqualToString:USER_PUB_ACTION]) {
                        pointPub = obj;
                        
//                        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!pointPub - %@",pointPub);
                        
                        *stop = true;
                    }
                }];
                //积分启用状态
                NSInteger i = 0;
                ++i;
                NSInteger ciShu = [pointPub[@"maxnum"] integerValue];
                //积分启用状态
                if ([pointPub[@"openstatus"] boolValue]&&[pointPub[@"status"] boolValue]&&i<=ciShu) {
                    
                    
//                    NSLog(@"。。。。。。。。。积分启用状态。。。。。。。。");
                    
                    
                    NSInteger point = [pointPub[@"point"] longLongValue];
                    
//                    NSLog(@"。。。。。。。。。%d。。。。。。。。",point);
                    
                    NSString *type = pointPub[@"point_type"];
                    
//                    NSLog(@"..............%@......",type);
                    
                    //加积分不提示
                    if ([type isEqualToString:REDUCE]) {
                        long long uPoint = [userPoint[@"point"] longLongValue];
                        if (point > uPoint) {
                            //积分不足不能继续操作
                            [GVConfirmView showConfirm:@"您的积分不足无法投稿！" inView:AppWindow confirmButton:@"确定" action:^{
                                [__self.navigationController popViewControllerAnimated:true];
                            }cancelTitle:nil action:nil];

                        }
                    }
                    
//                    //加积分不提示
//                    if ([type isEqualToString:ADD]) {
//                    long long uPoint = [userPoint[@"point"] longLongValue];
//                        uPoint += point;
//                    
//                    }
                    
                    
                    
                    
                }else{
                    //积分未启用直接跳过检查
                }
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                [GVConfirmView showConfirm:@"系统出错，无法继续操作" inView:AppWindow confirmButton:@"确定" action:^{
                    [__self.navigationController popViewControllerAnimated:true];
                }cancelTitle:nil action:nil];

            }];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            [GVConfirmView showConfirm:@"系统出错，无法继续操作" inView:AppWindow confirmButton:@"确定" action:^{
                [__self.navigationController popViewControllerAnimated:true];
            }cancelTitle:nil action:nil];
        }];
    }
}


-(void)uploadFinished:(ArticleEntity*)msg{
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
    CRWeekRef(hud);
    [MSGRequestManager Get:kAPIMSG(msg.mid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__hud hide:true];
        ArticleEntity *article = [ArticleEntity buildInstanceByJson:data];
        //投稿成功
        if (_createFinished) {
            if (userPoint) {
                _createFinished(true,@{@"article":article,@"point":userPoint});
            }else{
                _createFinished(true,@{@"article":article});
            }
        }
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__hud hide:true];
        if (_createFinished) {
            _createFinished(false,msg);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
