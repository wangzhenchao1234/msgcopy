//
//  WalletController.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/3.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalletController : UIViewController
@property(nonatomic,retain)ShopStoreEntity *shop;
@end
typedef NS_ENUM(NSUInteger,WalletType){
    
    WalletTypeComplete,
    WalletTypeClosed

};
@interface BillingRecordEntity : NSObject
/*
 money = "0.07000000000000001";
 time = "2015-08-27T15:24:43";
 type = closed;
 */
@property(nonatomic,assign)CGFloat money;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,assign)WalletType type;
+(instancetype)buildWithJson:(NSDictionary*)json;
@end