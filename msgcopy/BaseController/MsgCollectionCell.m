//
//  MsgCollectionCell.m
//  msgcopy
//
//  Created by wngzc on 15/7/30.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MsgCollectionCell.h"

@implementation MsgCollectionCell
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorFromHexRGB:@"9f9fa0"].CGColor);
    CGContextStrokeRect(context, CGRectMake(_lineLeftInset, rect.size.height, rect.size.width - _lineLeftInset - _lineRightInset, 1/ScreenScale));
}

@end
