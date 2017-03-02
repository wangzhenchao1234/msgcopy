//
//  AppDelegate.h
//  msgcopy
//
//  Created by Gavin on 15/4/3.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,copy) void(^weichatPayCallBack)(BOOL result);
@property (nonatomic,copy) void(^weichatAuthCallBack)(id data);
@property (nonatomic,copy) void(^weichatAuthErrorCallBack)(id data);

@end

