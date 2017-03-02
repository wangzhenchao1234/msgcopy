//
//  GroupEditeController.h
//  msgcopy
//
//  Created by Gavin on 15/7/10.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactGroupEditeController : UITableViewController
@property(nonatomic,retain)NSMutableArray *groups;
-(void)finishedAddGroup:(ContactGroupEntity*)group;
@end
