//
//  JudgeIsLoginOrRegisterViewController.h
//  msgcopy
//
//  Created by sh on 2016/12/5.
//  Copyright © 2016年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JudgeIsLoginOrRegisterViewController : UIViewController
@property(nonatomic,copy)NSString*openID;
@property(nonatomic,copy)void(^loginCallBack)(BOOL loginSate);
@property(nonatomic,copy)void(^registerCompleteAction)(NSString *username,NSString *password);
@end
