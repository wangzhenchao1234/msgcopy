//
//  BlankView.m
//  msgcopy
//
//  Created by Gavin on 15/8/11.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "BlankView.h"

@implementation BlankView

-(void)awakeFromNib
{
    _actionView.layer.cornerRadius = 5;
    _actionView.backgroundColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
}
+(instancetype)blanViewWith:(UIImage*)image descr:(NSString*)descr actionTitle:(NSString*)actionTitle target:(id)target selector:(SEL)selector
{
    BlankView *view = [Utility nibWithName:@"BlankView" index:0];
    view.imageView.image = image;
    view.descrView.text = descr;
    [view.actionView setTitle:actionTitle forState:UIControlStateNormal];
    [view.actionView addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    if (actionTitle == nil) {
        view.actionView.hidden = true;
    }
    return view;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
