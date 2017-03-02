//
//  VerifyEmailController.h
//  msgcopy
//
//  Created by wngzc on 15/5/22.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "UserTableViewController.h"

@interface VerifyEmailController : UserTableViewController
@property(nonatomic,copy)NSString *email;
@property(nonatomic,assign)BOOL canEdite;
@property(nonatomic,assign)BOOL isThirdLogin;
@property(nonatomic,copy)NSString*thirdLoginPassword;
@property(nonatomic,copy)NSString*openID;
@end
