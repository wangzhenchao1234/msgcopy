//
//  KKDiyListView.h
//  Kaoke
//
//  Created by wngzc on 14/12/1.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KaokePublicationEntity;
@class DiyModule2Entity;
@class DiyPageEntity;
@class UICustomLineLabel;

@interface KKDiyModule2View : UIView
@property(nonatomic,retain)UIView *contentView;
@property(nonatomic,retain)UIImageView *thumbnail;
@property(nonatomic,retain)UILabel *titleLable;
@property(nonatomic,retain)UILabel *descr;
@property(nonatomic,retain)UILabel *price;
@property(nonatomic,retain)UICustomLineLabel *lastPrice;
@property(nonatomic,retain)UILabel *bottomLine;
@property(nonatomic,retain)PubEntity *pub;
@property (nonatomic)  UIEdgeInsets contentEdgeInsets;

-(void)buildByData:(DiyModule2Entity*)data page:(DiyPageEntity*)page action:(onClick)action;
-(void)buildByPub:(PubEntity*)data action:(onClick)action type:(NSString*)type;

@end
