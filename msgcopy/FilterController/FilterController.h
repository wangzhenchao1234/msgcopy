//
//  FilterController.h
//  msgcopy
//
//  Created by wngzc on 15/7/14.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterController : UITableViewController
@property(nonatomic,retain)NSArray *conditions;
@property(nonatomic,assign)BOOL isRoot;

@end
