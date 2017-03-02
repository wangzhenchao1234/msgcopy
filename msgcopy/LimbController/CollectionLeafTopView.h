//
//  CollectionLeafTopView.h
//  msgcopy
//
//  Created by wngzc on 15/7/31.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeafTopView;
@interface CollectionLeafTopView : UICollectionReusableView
@property(nonatomic,retain)LeafTopView *topView;
@property(nonatomic,retain)LeafEntity *leaf;
-(void)startAnimation;
-(void)stopAnimation;
@end
