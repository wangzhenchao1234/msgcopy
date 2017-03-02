//
//  KKDiyGridMultyItemView.h
//  Kaoke
//
//  Created by Gavin on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DiyMultyGridEntiy;
@class DiyPageEntity;
@interface KKDiyGridMultyItemView : UIView

@property(nonatomic,retain)UIView *contentView;
@property(nonatomic,retain)UIImageView *backGroundImageView;
@property(nonatomic,copy)NSDictionary *grid_position;

-(void)buildByData:(DiyMultyGridEntiy*)data page:(DiyPageEntity *)page action:(onClick)action;

@end
