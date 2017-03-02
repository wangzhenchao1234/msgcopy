//
//  KKdiyItemView.h
//  Kaoke
//
//  Created by Gavin on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiyBannerEntity;
@class DiyPageEntity;

@interface KKdiyBannerView : UIView

@property(nonatomic,retain)UIView *contentView;
@property(nonatomic,retain)UIScrollView *mainScrollView;
@property(nonatomic,retain)UIView *titleView;
@property(nonatomic,retain)UILabel *titleLable;
@property(nonatomic,retain)UIPageControl *pageControl;
@property (nonatomic)  UIEdgeInsets contentEdgeInsets;
-(void)stopAnimation;
-(void)startAnimation;
-(void)pauseAnimation;
-(void)buildByData:(DiyBannerEntity*)data page:(DiyPageEntity*)page action:(onClick)action;
@end
