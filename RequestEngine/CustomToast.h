//
//  CustomToast.h
//  toast
//
//  Created by xiaogu on 14-2-7.
//  Copyright (c) 2014年 BeijingMsgcopyTecnology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomToast : UILabel
+(void)showMessage:(NSString *)message in:(UIView*)view;
+(void)showMessageOnWindow:(NSString *)message;
+(void)showMessageOnWindowThreeSeconds:(NSString *)message;
@end
