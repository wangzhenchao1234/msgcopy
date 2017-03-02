//
//  VirtualPayCell.m
//  Kaoke
//
//  Created by wngzc on 15/4/28.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "VirtualPayCell.h"
#import "VirtualPayController.h"

@implementation VirtualPayCell

- (void)awakeFromNib {
    // Initialization code
    _moneyView.center = CGPointMake(AppWindow.width/2.0f, 22);
    _selectedFlag.frame = CGRectMake(0, 0, 5, 44);
    _titleView.width = 105;
    _moneyView.width = 100;
    _descrView.width = AppWindow.width - _moneyView.x - _moneyView.width - 10;
    _descrView.x = _moneyView.x + _moneyView.width;
}
-(void)buildWithData:(VirtualPayEntity*)data
{
    
    NSString *title = nil;
    NSMutableString *money = [NSMutableString new];
    if (data.type == VirtualTypeRechOffLine) {
        title = @"线下充值";
        self.moneyView.textColor = [UIColor colorFromHexRGB:@"669900"];
        [money appendString:@"+"];
    }else if (data.type == VirtualTypeRechAliPay) {
        title = @"支付宝充值";
        self.moneyView.textColor = [UIColor colorFromHexRGB:@"669900"];
        [money appendString:@"+"];
    }else if (data.type == VirtualTypeReachUnionPay) {
        title = @"银联充值";
        self.moneyView.textColor = [UIColor colorFromHexRGB:@"669900"];
        [money appendString:@"+"];
    }else if (data.type == VirtualTypeRechWeiXin) {
        title = @"微信充值";
        self.moneyView.textColor = [UIColor colorFromHexRGB:@"669900"];
        [money appendString:@"+"];
    }else if (data.type == VirtualTypePayOffLine) {
        title = @"线下消费";
        self.moneyView.textColor = [UIColor colorFromHexRGB:@"ff4444"];
        [money appendString:@"-"];
    }else if (data.type == VirtualTypePayOnLine) {
        title = @"线上消费";
        self.moneyView.textColor = [UIColor colorFromHexRGB:@"ff4444"];
        [money appendString:@"-"];
    }else if(data.type == VirtualTypeRechDianQuan){
        title = @"点券充值";
        self.moneyView.textColor = [UIColor colorFromHexRGB:@"669900"];
        [money appendString:@"+"];
    }else if(data.type == VirtualTypePayDianQuan){
        title = @"线下消费";
        [money appendString:@"-"];
        self.moneyView.textColor = [UIColor colorFromHexRGB:@"ff4444"];
    }else if(data.type == VirtualTypeRefund){
        title = @"退    款";
        [money appendString:@"+"];
        self.moneyView.textColor = [UIColor colorFromHexRGB:@"669900"];
    }

    [money appendString:CRString(@"%.2f",data.paymoney)];
    _titleView.text = title;
    _moneyView.text = money;
    NSArray *times = [data.time componentsSeparatedByString:@"T"];
    if (times.count > 1) {
        _descrView.text = times[0];
    }else{
        _descrView.text = @"";
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        _selectedFlag.hidden = false;
        _selectedFlag.backgroundColor = [UIColor colorFromHexRGB:@"e95412"];
    }else{
        _selectedFlag.hidden = true;
    }
    // Configure the view for the selected state
}

@end
