//
//  WaterView.h
//  Water Waves
//
//  Created by wngzc on 14-5-23.
//  Copyright (c) 2014年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WaterViewDelegate <NSObject>

-(void)finishedLoading;

@end

@interface WaterView : UIView
@property(nonatomic,retain) UIColor *currentWaterColor;
@property(nonatomic,weak)id<WaterViewDelegate>delegate;
-(void)startAnimation;
-(void)stopAnimation;
-(void)setProgress:(CGFloat)progress;
@end
