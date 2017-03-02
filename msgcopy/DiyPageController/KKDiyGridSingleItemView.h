//
//  KKDiyGridSingleItemView.h
//  Kaoke
//
//  Created by Gavin on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DiyPageEntity;
@class DiySingleGridEntity;

#import "FingerWaveView.h"
@interface KKDiyGridSingleItemView : UIView
@property(nonatomic,retain)UIView *contentView;
@property(nonatomic,retain)UIImageView *iconView;
@property(nonatomic,retain)UIImageView *backgroundImageView;
@property(nonatomic,retain)UILabel *titleLable;
@property(nonatomic,copy)NSDictionary *grid_position;
@property (nonatomic)  UIEdgeInsets contentEdgeInsets;;
-(void)buildByData:(DiySingleGridEntity*)data page:(DiyPageEntity*)page action:(onClick)action;
@end
