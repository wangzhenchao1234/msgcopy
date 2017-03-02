//
//  LoginMenuCell.m
//  msgcopy
//
//  Created by Gavin on 15/5/21.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "LoginMenuCell.h"

@implementation LoginMenuCell

- (void)awakeFromNib {
    
    // Initialization code
    _passButton.titleLabel.font = MSGFont(14);
    _registerButton.titleLabel.font = MSGFont(14);

    [_passButton setTitleColor:[UIColor colorWithRed:0.000 green:0.000 blue:0.098 alpha:0.220] forState:UIControlStateNormal];
    [_registerButton setTitleColor:[UIColor colorWithRed:0.000 green:0.000 blue:0.098 alpha:0.220] forState:UIControlStateNormal];
    _separatorLine.backgroundColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.098 alpha:0.220];
    _separatorLine.width = 1/ScreenScale;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)doRegister:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(doRegister:)]) {
        [_delegate doRegister:nil];
    }
    
}
- (IBAction)doGetPwd:(id)sender {

    if ([_delegate respondsToSelector:@selector(doGetPwd:)]) {
        [_delegate doGetPwd:nil];
    }

}

@end
