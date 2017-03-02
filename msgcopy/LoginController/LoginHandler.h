//
//  LoginHandler.h
//  msgcopy
//
//  Created by wngzc on 15/7/7.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginHandler : NSObject
+(void)showLoginControllerFromController:(UIViewController*)fromController complete:(void(^)(BOOL loginState))complete;
@end
