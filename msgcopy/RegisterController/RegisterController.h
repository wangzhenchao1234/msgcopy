//
//  RegisterController.h
//  msgcopy
//
//  Created by Gavin on 15/5/20.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "UserTableViewController.h"

@interface RegisterController : UserTableViewController
@property(nonatomic,copy)void(^registerCompleteAction)(NSString *username,NSString *password);
@end
