//
//  ProductTitleCell.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/6.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import "ProductTitleCell.h"

@implementation ProductTitleCell

- (void)awakeFromNib {
    // Initialization code
    _titleView.delegate = self;
    self.lineLeftInset = 15;
    self.lineRightInset = 15;
}
-(void)setTitleData:(NSMutableDictionary *)titleData{
    _titleData = titleData;
    _titleView.text = [_titleData valueForKey:@"title"];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [_titleData setObject:textField.text forKey:@"title"];
    return true;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
