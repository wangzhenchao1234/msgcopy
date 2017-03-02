//
//  CustomTabBarItem.m
//  msgcopy
//
//  Created by Gavin on 15/4/14.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "CustomTabBarItem.h"

@interface CustomTabBarItem()
{
    SEL clickAction;
    id  doTarget;
}
@property(nonatomic,retain)UIImageView *itemImageView;
@property(nonatomic,retain)UILabel *itemTitleView;
@property(nonatomic,retain)UIButton *itemClickView;

@end

@implementation CustomTabBarItem
- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _itemClickView = [UIButton buttonWithType:UIButtonTypeCustom];
        _itemClickView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        _itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 22)/2.0f, 7, 22, 22)];
        _itemTitleView = [[UILabel alloc] initWithFrame:CGRectMake(2,_itemImageView.y+_itemImageView.height+2, frame.size.width - 4, 14)];
        _itemTitleView.textAlignment = NSTextAlignmentCenter;
        
        _itemTitleView.font = MSGYHFont(11);
        
        _itemTitleView.textColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
        
        [self addSubview:_itemImageView];
        [self addSubview:_itemTitleView];
        [self addSubview:_itemClickView];
        
    }
    return self;
}
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    clickAction = action;
    doTarget = target;
    [_itemClickView addTarget:self action:@selector(click:) forControlEvents:controlEvents];
    
}
-(void)click:(UIButton*)sender{
    if (!_selected) {
        [self setSelected:true];
        CRWeekRef(doTarget);
        CRWeekRef(self);
        if ([doTarget respondsToSelector:clickAction]) {
            [__doTarget performSelector:clickAction withObject:__self];
        }
    }
}
-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected) {
        [_itemImageView sd_setImageWithURL:CRURL(_selectedImage)];
        [_itemTitleView setTextColor:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor]];
    }else{
        [_itemImageView sd_setImageWithURL:CRURL(_normalImage)];
        [_itemTitleView setTextColor:[UIColor colorFromHexRGB:LeafDefaultColor]];
    }
}
-(void)setTitle:(NSString *)title{
    _title = title;
    _itemTitleView.text = title;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
