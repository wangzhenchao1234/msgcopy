//
//  ActionFooterView.m
//  msgcopy
//
//  Created by wngzc on 15/5/20.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ActionFooterView.h"

@interface ActionFooterView()

@property (weak, nonatomic) IBOutlet UIButton *actionView;

@end

@implementation ActionFooterView
-(void)awakeFromNib
{
    self.width = AppWindow.width;
    self.height = 55;
    _actionView.layer.cornerRadius = 5;
    _actionView.backgroundColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
}
-(void)setTitle:(NSString *)title state:(UIControlState)state{
    [_actionView setTitle:title forState:state];
}
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event
{
    [_actionView addTarget:target action:action forControlEvents:event];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
