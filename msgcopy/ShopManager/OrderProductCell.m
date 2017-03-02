//
//  ProductCell.m
//  PSClient
//
//  Created by Hackintosh on 15/9/28.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "OrderProductCell.h"

@implementation OrderProductCell

- (void)awakeFromNib {
    // Initialization code
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorFromHexRGB:@"9f9fa0"].CGColor);
    CGContextStrokeRect(context, CGRectMake(20, rect.size.height, rect.size.width - 0 - 20, 1/ScreenScale));
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
