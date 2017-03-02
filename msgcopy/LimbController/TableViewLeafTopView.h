//
//  TableViewLeafTopView.h
//  msgcopy
//
//  Created by wngzc on 15/7/31.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeafTopView;
@interface TableViewLeafTopView : UIView
@property(nonatomic,retain)LeafTopView *topView;
-(void)startAnimation;
-(void)stopAnimation;
-(instancetype)initWithFrame:(CGRect)frame leaf:(LeafEntity*)leaf;
@end
