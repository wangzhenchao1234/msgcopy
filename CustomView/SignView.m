//
//  SignView.m
//  Kaoke
//
//  Created by Gavin on 15/3/24.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "SignView.h"
#import "ScoreUserActionManager.h"

@interface SignView()
@property(nonatomic,retain) NSDictionary *pointPub;
@property(nonatomic,assign) long long perPoint;
@property(nonatomic,strong) UIView *backGroundView;
@property(nonatomic,strong) UIButton *signButton;
@property(nonatomic,strong) UIView *actionView;
@property(nonatomic,assign) BOOL hasSigned;
@property(nonatomic,retain) UILabel *alertLabel;
@property(nonatomic,retain) UILabel *pointLabel;
@property(nonatomic,retain) UIButton *closeButton;
@property(nonatomic,retain) NSDateFormatter *fomatter;
@end

@implementation SignView

+(instancetype)sharedView{
    
    static SignView *signView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        signView = [[SignView alloc] init];
        
    });
    return signView;
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _fomatter = [[NSDateFormatter alloc] init];
        _fomatter.dateFormat = @"yyyyMMdd";
        _backGroundView = [[UIView alloc] initWithFrame:AppWindow.bounds];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.880];
        
        _actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
        _actionView.backgroundColor = [UIColor clearColor];
        
        _signButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _signButton.frame = CGRectMake(0, 0, 120, 120);
        
        [_signButton addTarget:self action:@selector(doSign:) forControlEvents:UIControlEventTouchUpInside];
        
        [_actionView addSubview:_signButton];
        _signButton.center = CGPointMake(_actionView.width/2.0f, _actionView.height/2.0f + 20);
        
        _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
        _alertLabel.backgroundColor = [UIColor clearColor];
        _alertLabel.textColor = [UIColor redColor];
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.font = [UIFont systemFontOfSize:16];
        _alertLabel.text = @"签到送积分";
        [_actionView addSubview:_alertLabel];
        _alertLabel.center = CGPointMake(_actionView.width/2.0f, _signButton.y - 20);
        _alertLabel.hidden = true;
        [_backGroundView addSubview:_actionView];
        _actionView.center = CGPointMake(_backGroundView.width/2.0f, _backGroundView.height/2.0f - 20);
        
        [self addSubview:_backGroundView];
        self.backgroundColor = [UIColor clearColor];
        self.frame = _backGroundView.bounds;
        _backGroundView.alpha = 0;
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(0, 0, 44, 44);
        _closeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [_closeButton setImage:[UIImage imageNamed:@"ic_close_white"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(doClose:) forControlEvents:UIControlEventTouchUpInside];
        [_backGroundView addSubview:_closeButton];
        _closeButton.center = CGPointMake(_backGroundView.width - _closeButton.width/2.0f, _closeButton.width/2.0f);
        
        _pointLabel = [[UILabel alloc] init];
        _pointLabel.textColor = [UIColor redColor];
        _pointLabel.font = [UIFont systemFontOfSize:18];
        _pointLabel.height = 30;
        _pointLabel.textAlignment = NSTextAlignmentCenter;
        _pointLabel.backgroundColor = [UIColor clearColor];
        [_actionView addSubview:_pointLabel];

        _pointLabel.frame = _alertLabel.frame;
        
    }
    return self;
}

+(void)show
{
    SignView *view = [SignView sharedView];
    [AppWindow addSubview:view];
    [UIApplication sharedApplication].statusBarHidden = true;
    NSString *dateStr = [view.fomatter stringFromDate:[NSDate date]];
    BOOL hasSinged = CRUserBOOL(CRString(@"%@_%@",kCurUser.userName,dateStr));
    
    //已签到
    if (hasSinged) {
        view.signButton.userInteractionEnabled = false;
        view.alertLabel.hidden = true;
        view.pointLabel.hidden = true;
        [view.signButton setImage:[UIImage imageNamed:@"ic_signined"] forState:UIControlStateNormal];
        [UIView animateWithDuration:.35 animations:^{
            view.backGroundView.alpha = 1;
        }];
        return;
    }
    view.signButton.userInteractionEnabled = true;
    [view.signButton setImage:[UIImage imageNamed:@"ic_signin"] forState:UIControlStateNormal];
    
    [ScoreUserActionManager doUserAction:USER_SIGNIN_ACTION user:kCurUser.userName currentStatus:true success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
        //        _userPoint = nil;
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
                
                //                                NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!data - %@",data);
                
                //获取积分状态
                //                userPoint = data;
                [ScoreUserActionManager getAllUserActionStatus:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    __block NSDictionary *pointPub = nil;
                    NSArray * pointsJson = data;
                    [pointsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj[@"content_type"] isEqualToString:USER_SIGNIN_ACTION]) {
                            pointPub = obj;
                            
                            //                                 NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!pointPub - %@",pointPub);
                            
                            *stop = true;
                        }
                    }];
                    //积分启用状态
                    if ([pointPub[@"openstatus"] boolValue]&&[pointPub[@"status"] boolValue]) {
                        
                        
                        NSLog(@"。。。。。。。。。积分启用状态。。。。。。。。");
                        
                        
                        NSInteger point = [pointPub[@"point"] longLongValue];
                        
                        NSLog(@"。。。。。。。。。%d。。。。。。。。",point);
                        
                        NSString *type = pointPub[@"point_type"];
                        
                        NSLog(@"..............%@......",type);
                        [CustomToast showMessageOnWindow:CRString(@"您的积分增加：%d",point)];
                        //加积分不提示
                        
                    }else{
                        //积分未启用直接跳过检查
                    }
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    [GVConfirmView showConfirm:@"系统出错，无法继续操作" inView:AppWindow confirmButton:@"确定" action:^{
                        //                        [__self.navigationController popViewControllerAnimated:true];
                    }cancelTitle:nil action:nil];
                    
                }];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                [GVConfirmView showConfirm:@"系统出错，无法继续操作" inView:AppWindow confirmButton:@"确定" action:^{
                    //                    [__self.navigationController popViewControllerAnimated:true];
                }cancelTitle:nil action:nil];
            }];
        }
        
        CRLog(@"签到积分++");
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        CRLog(@"%@",msg);
        
    }];

    
//    //未绑定积分不用走积分接口
//    if (!CRWebAppTitle(@"pointmanage")) {
//        view.perPoint = 0;
//        view.alertLabel.hidden = true;
//        [UIView animateWithDuration:.35 animations:^{
//            view.backGroundView.alpha = 1;
//        }];
//        return;
//    }
    
    //未签到并且绑定积分app
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    [AppWindow addSubview:hud];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
    
    [ScoreUserActionManager getAllUserActionStatus:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        NSArray * pointsJson = data;
        [pointsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj[@"content_type"] isEqualToString:USER_SIGNIN_ACTION]) {
                view.pointPub = obj;
                *stop = true;
            }
        }];
        
        //积分开关开启
        if (view.pointPub&&[view.pointPub[@"openstatus"] boolValue]&&[view.pointPub[@"status"] boolValue])
        {
            view.perPoint = [view.pointPub[@"point"] longLongValue];
            if (view.perPoint>0) {
                view.alertLabel.hidden = false;
            }else{
                view.alertLabel.hidden = true;
            }
        }
        
        //动画
        [UIView animateWithDuration:.35 animations:^{
            view.backGroundView.alpha = 1;
        }];

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
   
}
/**
 *  隐藏
 */
+(void)disMiss
{
    SignView *view = [SignView sharedView];
    [UIApplication sharedApplication].statusBarHidden = false;
    [UIView animateWithDuration:.35 animations:^{
        view.backGroundView.alpha = 0;
    } completion:^(BOOL finished) {
        view.pointLabel.hidden = true;
        view.alertLabel.hidden = true;
        [view removeFromSuperview];
    }];
}
/**
 * 关闭按钮
 */
-(void)doClose:(UIButton*)sender
{
    [SignView disMiss];
}
/**
 *  签到
 *
 *  @param sender button
 */
-(void)doSign:(id)sender
{
    
    if (!self.pointPub||![self.pointPub[@"status"] boolValue]||![self.pointPub[@"openstatus"] boolValue]) {
        [self siginState];
        return;
    }
    
    [ScoreUserActionManager doUserAction:USER_SIGNIN_ACTION success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        _pointLabel.frame = _alertLabel.frame;
        if (self.perPoint>0) {
            _pointLabel.text = CRString(@"+%lld",_perPoint);
            _pointLabel.hidden = false;
        }
        [self siginState];
        //消失动画
        [UIView animateWithDuration:.75 animations:^{
            _pointLabel.y -= 10;
        } completion:^(BOOL finished) {
            [SignView disMiss];
        }];

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if ([msg containsString:@"1次赠送次数已用完!"]) {
            [self siginState];
            return;
        }
        [CustomToast showMessageOnWindow:msg];
    }];
    
}
-(void)siginState{
    _alertLabel.hidden = true;
    NSString *dateStr = [_fomatter stringFromDate:[NSDate date]];
    CRUserSetBOOL(true, CRString(@"%@_%@",kCurUser.userName,dateStr));
    _signButton.userInteractionEnabled = false;
    [_signButton setImage:[UIImage imageNamed:@"ic_signined"] forState:UIControlStateNormal];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
