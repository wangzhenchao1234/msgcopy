//
//  DiyListView.h
//  Kaoke
//
//  Created by wngzc on 14/12/3.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KaokeLeafEntity;
@interface KKDiyListView : UIView
+(instancetype)buildByLeaf:(LeafEntity*)leaf frame:(CGRect)frame inset:(UIEdgeInsets)inset action:(onClick)action;
@end
