//
//  VirtualPayController.h
//  Kaoke
//
//  Created by wngzc on 15/4/28.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VirtualPayController : UIViewController

@end

typedef NS_ENUM(NSUInteger,VirtualType){
    
    VirtualTypeRechAliPay,
    VirtualTypeReachUnionPay,
    VirtualTypeRechOffLine,
    VirtualTypeRechWeiXin,
    VirtualTypeRechDianQuan,
    VirtualTypePayOnLine,
    VirtualTypePayOffLine,
    VirtualTypePayDianQuan,
    VirtualTypeRefund
    
};


@interface VirtualPayEntity : NSObject
/*
 descr = "\U5566\U5566\U5566\U5566\U5566";
 paymoney = 30;
 time = "2015-04-20T16:14:56";
 type = xianshang;
 user =     {
 "_state" = "<django.db.models.base.ModelState object at 0x3c86890>";
 "app_id" = 34;
 id = 13;
 username = 1234;
 };
 */
@property(nonatomic,retain)UIView *titleView;
@property(nonatomic,copy)NSString *descr;
@property(nonatomic,assign)CGFloat paymoney;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,assign)VirtualType type;
+(instancetype)buildWithJson:(NSDictionary*)json;
@end