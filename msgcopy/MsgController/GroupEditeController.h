//
//  GroupEditeController.h
//  msgcopy
//
//  Created by wngzc on 15/7/10.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupEditeController : UITableViewController
@property(nonatomic,retain)NSMutableArray *groupDicts;
-(void)finishedAddGroup:(ArticleGroupEntity*)group;
@end
