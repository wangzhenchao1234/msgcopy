//
//  MsgTableCell.m
//  msgcopy
//
//  Created by wngzc on 15/5/20.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MsgTableCell.h"

@implementation MsgTableCell

- (void)awakeFromNib {
    // Initialization code
    
     [super awakeFromNib];
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorFromHexRGB:@"9f9fa0"].CGColor);
    CGContextStrokeRect(context, CGRectMake(_lineLeftInset, rect.size.height, rect.size.width - _lineLeftInset - _lineRightInset, 1/ScreenScale));
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
