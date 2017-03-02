//
//  WaterView.h
//  Water Waves
//
//  Created by Gavin on 14-5-23.
//  Copyright (c) 2014年 Gavin. All rights reserved.
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
