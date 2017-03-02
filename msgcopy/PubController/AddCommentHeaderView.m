//
//  AddCommentHeaderView.m
//  msgcopy
//
//  Created by wngzc on 15/7/1.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "AddCommentHeaderView.h"

@implementation AddCommentHeaderView

-(void)awakeFromNib
{
    _lineLeftInset = 10;
    _lineRightInset = 10;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
 CGContextFillRect(context, rect);
 
 //下分割线
 CGContextSetStrokeColorWithColor(context, [UIColor colorFromHexRGB:@"9f9fa0"].CGColor);
 CGContextStrokeRect(context, CGRectMake(_lineLeftInset, rect.size.height, rect.size.width - _lineLeftInset - _lineRightInset, 1/ScreenScale));
 }


@end
