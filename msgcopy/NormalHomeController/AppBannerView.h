//
//  AppBannerView.h
//  Kaoke
//
//  Created by xiaogu on 14-9-9.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppBannerEntity;

@interface AppBannerView : UIView<UIScrollViewDelegate>

@property (nonatomic,retain) UIScrollView *mainScrollView;
@property (nonatomic,retain) UIPageControl *pageControl;
@property (nonatomic,retain) UILabel *title;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) UIView *titleBg;
@property (nonatomic,retain) AppBannerEntity *banner;
+(AppBannerView*)buildInatanceByBanner:(AppBannerEntity*)banner target:(id)target frame:(CGRect)frame;
-(void)startAnimation;
-(void)stopAnimation;
@end
@interface TopImageView : UIView
@property (nonatomic,retain) UIImageView *image;

@end