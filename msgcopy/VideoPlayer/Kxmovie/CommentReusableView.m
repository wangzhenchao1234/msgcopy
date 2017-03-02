//
//  CommentReusableView.m
//  msgcopy
//
//  Created by Gavin on 15/7/30.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "CommentReusableView.h"

@implementation CommentReusableView

- (void)awakeFromNib {
    // Initialization code
    _lineLeftInset = 10;
    _lineRightInset = 0;
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorFromHexRGB:@"9f9fa0"].CGColor);
    CGContextStrokeRect(context, CGRectMake(_lineLeftInset,-1/ScreenScale, rect.size.width - _lineLeftInset - _lineRightInset, 1/ScreenScale));
}

- (IBAction)doComment:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(addComment)]) {
        [_delegate addComment];
    }
}

@end
