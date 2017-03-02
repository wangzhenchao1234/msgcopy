//
//  ResetUserController.h
//  msgcopy
//
//  Created by wngzc on 15/8/3.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "UserTableViewController.h"

typedef NS_ENUM(NSInteger, ThirdDebindType) {
    
    ThirdDebindTypeQQ,
    ThirdDebindTypeWX,
    ThirdDebindTypeSina

};

@interface ResetUserController : UserTableViewController
@property(nonatomic,assign)ThirdDebindType debindType;

@property(nonatomic,copy)void(^debindCompleteAction)(BOOL result,id data);
+(void)showWithDebind:(ThirdDebindType)type target:(UIViewController*)target complete:(void(^)(BOOL result,id data))complete;
@end
