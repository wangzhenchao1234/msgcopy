//
//  PrePayController.h
//  msgcopy
//
//  Created by wngzc on 15/9/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCardsController.h"

@interface PrePayController : UITableViewController
@property(nonatomic,copy)void(^payCallBack)(BOOL result);
-(void)setOrderNo:(NSString*)orderNo bankCard:(BankCardEntity*)card;
@end
