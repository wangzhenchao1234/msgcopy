//
//  AddCommentContentCell.m
//  msgcopy
//
//  Created by wngzc on 15/7/1.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "AddCommentContentCell.h"

#define MinHeight 



@implementation AddCommentContentCell

- (void)awakeFromNib {
    // Initialization code
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    _textAttr = @{
                  NSFontAttributeName:MSGFont(15),
                  NSForegroundColorAttributeName:CRCOLOR_BLACK,
                  NSParagraphStyleAttributeName:style
                  };
    self.lineLeftInset = 10;
    self.lineRightInset = 10;
    [self.textView addObserver:self forKeyPath:NSStringFromSelector(@selector(text)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.textView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *sizeKey = NSStringFromSelector(@selector(contentSize));
    NSString *textKey = NSStringFromSelector(@selector(text));
    if ([keyPath isEqualToString:sizeKey]) {
        if ([_deletate respondsToSelector:@selector(adjustFrame:)]) {
            [_deletate adjustFrame:nil];
        }
    }else if([keyPath isEqualToString:textKey]){
 
        _placeholder.hidden = (_textView.text.length > 0);

    }
}

-(void)dealloc
{
    [self.textView removeObserver:self forKeyPath:NSStringFromSelector(@selector(text))];
    [self.textView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
