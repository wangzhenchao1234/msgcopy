//
//  SinaOauthController.h
//  msgcopy
//
//  Created by Gavin on 15/7/16.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SinaOauthController : UIViewController
@property(nonatomic, copy)void(^completeAction)(BOOL result,id data, NSString *msg);
+(void)doOauth:(void(^)(BOOL result,id data, NSString *msg))complte target:(id)target;
@end
