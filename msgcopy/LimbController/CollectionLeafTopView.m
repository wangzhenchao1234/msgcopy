//
//  CollectionLeafTopView.m
//  msgcopy
//
//  Created by Gavin on 15/7/31.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "CollectionLeafTopView.h"
#import "LeafTopView.h"

@implementation CollectionLeafTopView
-(void)setLeaf:(LeafEntity*)leaf
{
    [_topView removeFromSuperview];
    _topView = nil;
    _topView = [[LeafTopView alloc] initWithFrame:self.frame leaf:leaf];
    _topView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_topView];
}
-(void)startAnimation
{
    [_topView begainAnimation];
}
-(void)stopAnimation
{
    [_topView stopAnimation];
}

@end
