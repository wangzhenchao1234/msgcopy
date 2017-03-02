//
//  BandCardController.h
//  msgcopy
//
//  Created by wngzc on 15/9/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BandCardController : UITableViewController
@property(nonatomic,copy)void(^bindCallBack)(BOOL result);
@end
