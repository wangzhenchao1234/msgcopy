//
//  TableViewLeafTopView.m
//  msgcopy
//
//  Created by wngzc on 15/7/31.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "TableViewLeafTopView.h"
#import "LeafTopView.h"

@implementation TableViewLeafTopView
-(instancetype)initWithFrame:(CGRect)frame leaf:(LeafEntity *)leaf{
    if ([super initWithFrame:frame]) {
        self.topView = [[LeafTopView alloc] initWithFrame:frame leaf:leaf];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.topView];
    }
    return self;
}
-(void)startAnimation
{
    [_topView begainAnimation];
}
-(void)stopAnimation
{
    [_topView stopAnimation];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
