//
//  ThirdIconCell.m
//  msgcopy
//
//  Created by wngzc on 15/5/21.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ThirdIconCell.h"

@implementation ThirdIconCell
- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CRCOLOR_CLEAR;
    }
    return self;
}
-(void)setIcon:(UIImage *)icon
{
    _icon = icon;
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    [_icon drawInRect:rect];
}
@end
