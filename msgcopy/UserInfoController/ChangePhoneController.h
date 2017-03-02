//
//  ChangePhoneController.h
//  msgcopy
//
//  Created by Gavin on 15/8/3.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserTableViewController.h"

typedef NS_OPTIONS(NSUInteger, PhoneActionType){
    
    PHONE_ACTION_TYPE_VERYFY = 1 << 0,
    PHONE_ACTION_TYPE_MODIFY = 1 << 1
    
};

@interface ChangePhoneController : UserTableViewController
@property (nonatomic,assign) PhoneActionType actionType;
@end
