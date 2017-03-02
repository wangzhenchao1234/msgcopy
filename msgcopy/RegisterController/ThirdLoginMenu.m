//
//  ThirdLoginMenu.m
//  msgcopy
//
//  Created by wngzc on 15/5/21.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ThirdLoginMenu.h"
#import "ThirdIconCell.h"
#import "QQOauth.h"
#import "SinaOauthController.h"
#import "WeiChatOauth.h"
#import "RegisterController.h"
#import "OauthManager.h"
#import "JudgeIsLoginOrRegisterViewController.h"
#define CellSize 40

@implementation ThirdLoginMenu

-(void)awakeFromNib
{
    _hudView = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    _hudView.removeFromSuperViewOnHide = false;
    [_hudView hide:true];
    [AppWindow addSubview:_hudView];
    [_collectionView registerClass:[ThirdIconCell class] forCellWithReuseIdentifier:@"ThirdIconCell"];
}
-(void)reloadData{
    [self loadDataSource];
}

//获取视图的视图控制器
- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;  
}  

-(void)loadDataSource{
    
    _datas = [NSMutableArray new];
    if (_sina) {
        [_datas addObject:_sina];
    }
    if (_qq) {
        [_datas addObject:_qq];
    }
    if (_wechat) {
        [_datas addObject:_wechat];
    }
    [_collectionView reloadData];
    
}
#pragma mark -- collectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _datas.count;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return (collectionView.width - _datas.count *CellSize)/(_datas.count+1);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CellSize, CellSize);
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ThirdIconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThirdIconCell" forIndexPath:indexPath];
    UIImage *icon = _datas[indexPath.row];
    cell.icon = icon;
    return cell;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, (collectionView.width - _datas.count *CellSize)/(_datas.count+1), 0, (collectionView.width - _datas.count *CellSize)/(_datas.count+1));
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    
    UIImage *icon = _datas[indexPath.row];
    if (icon == _qq) {
        
        [self doQQLogin:nil];
        
    }else if(icon == _sina){
        
        [self doSinnaLogin:nil];
        
    }else if(icon == _wechat){
        
        [self doWeixinLogin:nil];
        
    }
    
}


#pragma mark - 微信登录

-(void)doWeixinLogin:(id)sender
{
    CRWeekRef(self);
    [_hudView show:true];
    [WeiChatOauth doWeixinLogin:^(BOOL result, id data) {
        if (result) {
            [__self handdleResult];
        }else{
            [CustomToast showMessageOnWindow:data];
        }
        [_hudView hide:true];

    } shouldRegister:^(NSString*openID){
        /**
         *  未绑定注册一个
         */
        [_hudView hide:true];

    JudgeIsLoginOrRegisterViewController *JudgeIsLoginOrRegisterVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"JudgeIsLoginOrRegisterViewController"];
    JudgeIsLoginOrRegisterVC.openID = openID;
    [CRController(self).navigationController pushViewController:JudgeIsLoginOrRegisterVC animated:true];

//            [_hudView hide:true];
//            RegisterController *registerVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"RegisterController"];
//            registerVC.registerCompleteAction = ^(NSString *username,NSString *password){
//                [OauthManager registerThirdPlt:@"weixin" params:@{@"username":username,@"password":password} openID:openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//                    [__self handdleResult];
//                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//                    [CustomToast showMessageOnWindow:data];
//                }];
//            };
//            [CRController(self).navigationController pushViewController:registerVC animated:true];
//            
       
    }];
}
#pragma --mark 新浪登陆
- (void)doSinnaLogin:(id)sender {
    CRWeekRef(self);
    [SinaOauthController doOauth:^(BOOL result, id data, NSString *msg) {
        NSLog(@"%@",data);
        if (result) {
            //sinas授权成功
            __block NSString *uid = data[@"uid"];
            __block NSString *token = data[@"access_token"];
            [_hudView show:true];
            [OauthManager loginSinaPlt:uid success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [_hudView hide:true];
                CRUserSetObj(token,CRString(@"%@_sina_token",kCurUserName));
                [__self handdleResult];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [_hudView hide:true];
                /**
                 *  未绑定注册一个
                 */
                if (code == 400) {

                    RegisterController *registerVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"RegisterController"];
                    registerVC.registerCompleteAction = ^(NSString *username,NSString *password){
                        [OauthManager registerThirdPlt:@"sina" params:@{@"username":username,@"password":password} openID:uid success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                            [__self handdleResult];

                        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
                        {
                            [CustomToast showMessageOnWindow:data];

                        }];
                    };
                    [CRController(self).navigationController pushViewController:registerVC animated:true];
                }else{
                    [CustomToast showMessageOnWindow:msg];
                }
            }];
            
        }else{
            [CustomToast showMessageOnWindow:msg];return;
        }
    } target:CRController(self)];
}

#pragma --mark QQ登陆
- (void)doQQLogin:(id)sender {
    
    CRWeekRef(self);
    [[QQOauth sharedQQOauth] doQQLoginOauth:^(BOOL reult, id data) {
        if (reult) {
            [__self handdleResult];
        }else{
            [CustomToast showMessageOnWindow:data];
        }
    } shouldRegister:^(NSString *openID) {
        /**
         *  未绑定注册一个
         */

        RegisterController *registerVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"RegisterController"];
        registerVC.registerCompleteAction = ^(NSString *username,NSString *password){
            [OauthManager registerThirdPlt:@"qq" params:@{@"username":username,@"password":password} openID:openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [__self handdleResult];
            
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
             {
                 [CustomToast showMessageOnWindow:data];
             }];
        };
        [CRController(__self).navigationController pushViewController:registerVC animated:true];
    }];
    
}
-(void)handdleResult{
    
    CRWeekRef(self);
    CRBackgroundGCD(^{
        [[XmppListenerManager sharedManager] setUser:kCurUser];
        [[HistoryContentManager sharedManager] getAllRoomsComplete:nil];
    });
    [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
        
        [CRController(__self).navigationController dismissViewControllerAnimated:true completion:^{
            GSliderViewController *slider = (GSliderViewController*)CRRootNavigation().viewControllers[0];
            UINavigationController *rootNav = (UINavigationController*)slider.centerViewController;
            CenterController *_rootCenter = (CenterController*)rootNav.viewControllers[0];
            [_rootCenter checkPermission];
        }];
        
    }];
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.000 green:0.000 blue:0.098 alpha:0.220].CGColor);
    
    CGFloat textWidth = 90;
    CGFloat y = -1/ScreenScale;
    CGFloat x1 = 36;
    CGFloat x2 = x1 + (rect.size.width - 2*x1 - textWidth)/2.0f;
    CGFloat x3 = x2 + textWidth;
    CGContextMoveToPoint(context,x1 , y);

    CGContextStrokeRect(context, CGRectMake(x1, y, x2 - x1, 1.0/ScreenScale));
    CGContextStrokeRect(context, CGRectMake(x3, y, x2 - x1, 1.0/ScreenScale));
    
    NSString *logoStr = @"第三方登录";
    
    if (!_logo) {
        _logo = [[UILabel alloc] initWithFrame:CGRectMake(x2, -9, textWidth, 18)];
        _logo.textColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.098 alpha:0.220];
        _logo.font = MSGFont(14);
        _logo.textAlignment = NSTextAlignmentCenter;
        _logo.text = logoStr;
        [self addSubview:_logo];
    }

}


@end
