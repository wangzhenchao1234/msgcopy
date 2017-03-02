//
//  ProductTextView.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/9.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "ProductTextView.h"

@implementation ProductTextView
-(void)awakeFromNib
{
    _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.width-10, self.height)];
    _placeholder.textColor = [UIColor colorFromHexRGB:@"9f9fa0"];
    _placeholder.font = self.font;
    _placeholder.backgroundColor = CRCOLOR_CLEAR;
    _placeholder.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_placeholder];
    self.delegate = self;
}
-(void)textViewDidChange:(UITextView *)textView
{
    _placeholder.hidden = [self.text length]>0;
    if ([_productDelegate respondsToSelector:@selector(textViewDidChange:)]) {
        [_productDelegate textViewDidChange:self];
    }
}
-(void)textViewDidChangeSelection:(UITextView *)textView
{
    _placeholder.hidden = [self.text length]>0;
    if ([_productDelegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [_productDelegate textViewDidChange:self];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([_productDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
        return  [_productDelegate textView:self shouldChangeTextInRange:range replacementText:text];
    }
    return true;
}
-(void)setPlaceholderStr:(NSString *)placeholderStr
{
    _placeholderStr = placeholderStr;
    _placeholder.text = placeholderStr;
}
-(id)initWithFrame:(CGRect)frame
{
   self = [super initWithFrame:frame];
    if (self) {
        _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.width-10, self.height)];
        _placeholder.textColor = [UIColor colorFromHexRGB:@"9f9fa0"];
        _placeholder.font = self.font;
        _placeholder.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _placeholder.hidden = false;
        [self addSubview:_placeholder];

    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _placeholder = [[UILabel alloc] init];
        _placeholder.textColor = [UIColor colorFromHexRGB:@"9f9fa0"];
        _placeholder.font = self.font;
        _placeholder.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_placeholder];

    }
    return self;
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _placeholder.frame = CGRectMake(5, 0, frame.size.width-10, frame.size.height);
}

@end
