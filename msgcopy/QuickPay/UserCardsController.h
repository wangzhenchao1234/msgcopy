//
//  UserCardsController.h
//  msgcopy
//
//  Created by Gavin on 15/9/16.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCardsController : UITableViewController
@property(nonatomic,copy)NSString *orderNo;
@property(nonatomic,copy)NSString *money;
@property(nonatomic,copy)void(^payCallBack)(BOOL result);
@end

@interface BankCardEntity : NSObject

@property(nonatomic,copy)NSString *username;
@property(nonatomic,copy)NSString *authtoken;
@property(nonatomic,copy)NSString *mobile;
@property(nonatomic,copy)NSString *certNo;
@property(nonatomic,copy)NSString *certType;
@property(nonatomic,copy)NSString *accountName;
@property(nonatomic,copy)NSString *bankId;
@property(nonatomic,copy)NSString *bankAccountNo;
@property(nonatomic,assign)NSInteger bid;

+(instancetype)buildByJson:(NSDictionary*)json;

@end