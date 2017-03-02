//
//  PhoneRegisterController.h
//  msgcopy
//
//  Created by wngzc on 15/5/22.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "UserTableViewController.h"

@interface PhoneRegisterController : UserTableViewController
@property(nonatomic,retain)NSDictionary *registerParams;
@property(nonatomic,copy)void(^registerCompleteAction)(NSString *username,NSString *password);
@property(nonatomic,copy)NSString*openID;
@property(nonatomic,assign)BOOL isThildLogin;
@end
