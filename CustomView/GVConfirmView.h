//
//  GVConfirmView.h
//  msgcopy
//
//  Created by wngzc on 15/4/7.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GVConfirmView : NSObject
+(instancetype)defaultView;
+(void)showConfirm:(NSString*)title inView:(UIView*)view confirmButton:(NSString*)confirmTitle action:(void(^)(void))confirmAction otherTitle:(NSString*)otherTitle action:(void(^)(void))otherAction cancelTitle:(NSString*)cancelTitle action:(void(^)(void))cancelAction;
+(void)showConfirm:(NSString*)title inView:(UIView*)view confirmButton:(NSString*)confirmTitle action:(void(^)(void))confirmAction cancelTitle:(NSString*)cancelTitle action:(void(^)(void))cancelAction;
@end
