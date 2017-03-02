//
//  EmailVerifyCell.m
//  msgcopy
//
//  Created by Gavin on 15/9/15.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "EmailVerifyCell.h"

@implementation EmailVerifyCell

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
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
    _inputView.placeholder = placeholder;
}
-(NSString*)value
{
    return _inputView.text;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _verifyButoon.normalFontColor = [UIColor colorFromHexRGB:@"1D7CC1"];
    _verifyButoon.changeFontColor = [UIColor colorWithRed:0 green:0 blue:.098 alpha:.22];
}

- (IBAction)getVerifyCode:(id)sender {
    
    MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
    [AppWindow addSubview:hud];
    [MSGRequestManager MKPost:_codeAPI params:_params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        _verifyButoon.enabled = NO;
        //button type要 设置成custom 否则会闪动
        [_verifyButoon startWithSecond:60];
        [_verifyButoon didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
            NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
            return title;
        }];
        [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
            countDownButton.enabled = YES;
            return @"重新获取";
            
        }];
        [CustomToast showMessageOnWindow:@"验证码已发送"];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
