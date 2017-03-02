//
//  LoginHandler.m
//  msgcopy
//
//  Created by Gavin on 15/7/7.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "LoginHandler.h"

@implementation LoginHandler

+(void)showLoginControllerFromController:(UIViewController *)fromController complete:(void(^)(BOOL loginState))complete
{
    [GVAlertView showAlert:nil message:@"此功能需要登录,是否登录？" confirmButton:@"登录" action:^{
        LoginController *loginVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LoginController"];
        loginVC.loginCallBack = complete;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [fromController presentViewController:nav animated:true completion:nil];
        
    } cancelTitle:@"以后再说" action:^{
        NSLog(@"取消登录");
    }];
}
@end
