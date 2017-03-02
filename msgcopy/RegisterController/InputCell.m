//
//  InputCell.m
//  msgcopy
//
//  Created by wngzc on 15/5/20.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "InputCell.h"

@implementation InputCell

- (void)awakeFromNib {
    // Initialization code
}
-(void)setLineLeftInset:(CGFloat)lineLeftInset
{
    [super setLineLeftInset:lineLeftInset];
}
-(void)setLineRightInset:(CGFloat)lineRightInset
{
    [super setLineRightInset:lineRightInset];
}
-(void)setPlaceholder:(NSString*)placeholder
{
    [UIColor colorWithWhite:1.000 alpha:1.000];
    _textInputView.placeholder = placeholder;
}
-(NSString*)value
{
    return _textInputView.text;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
