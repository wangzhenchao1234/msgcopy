//
//  LoginController.h
//  msgcopy
//
//  Created by wngzc on 15/5/20.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "UserTableViewController.h"

@interface LoginController : UserTableViewController
@property(nonatomic,copy)NSString*openID;
@property(nonatomic,copy)void(^loginCallBack)(BOOL loginSate);
@end
