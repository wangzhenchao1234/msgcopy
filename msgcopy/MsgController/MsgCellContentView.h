//
//  MsgCellContentView.h
//  msgcopy
//
//  Created by wngzc on 15/7/8.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgCellContentView : UIView
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *thumnail;
@property(nonatomic,copy)NSString *descr;
@property(nonatomic,copy)NSString *commentCount;
@property(nonatomic,copy)NSString *distance;
@property(nonatomic,retain)NSDictionary *titleAttr;
@property(nonatomic,retain)NSDictionary *descrAttr;
@property(nonatomic,retain)NSDictionary *disAttr;
@property(nonatomic,retain)NSDictionary *cmtAttr;

@end
