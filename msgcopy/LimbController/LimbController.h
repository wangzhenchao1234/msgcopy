//
//  LimbController.h
//  msgcopy
//
//  Created by wngzc on 15/4/14.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LimbEntity;

@interface LimbController : UIViewController

@property (nonatomic,retain)LimbEntity *limb;
-(void)reloadDataWithLimb:(LimbEntity*)limb;
-(void)reloadDataWithLimbID:(NSInteger)lid;
-(void)reloadDataWithLeafID:(NSInteger)leafID;
@end
