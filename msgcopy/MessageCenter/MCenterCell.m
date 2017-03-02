//
//  MCenterCell.m
//  msgcopy
//
//  Created by wngzc on 15/7/13.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MCenterCell.h"
#define NS_CALENDAR_UNIT NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekday|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond

@implementation MCenterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _iconView.layer.cornerRadius = 22;
    _iconView.layer.borderWidth = 2;
    _iconView.clipsToBounds = true;
    _iconView.textColor =  [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
    _titleView.textColor =  [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
    style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    style.alignment = NSTextAlignmentCenter;
    myCal  = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    parser = [[SBJsonParser alloc] init];
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
}

-(void)buildWithData:(MessageEntity*)data
{
    unsigned units = NS_CALENDAR_UNIT;
    NSDateComponents *comp1 = [myCal components:units fromDate:data.cTime];
    NSInteger week = [comp1 weekday];
    NSArray *weeks = @[@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
    NSMutableAttributedString *weekStr = [[NSMutableAttributedString alloc] init];
    NSInteger weekNum = week;
    if (weekNum == 0) {
        weekNum = 7;
    }else{
        weekNum = week - 1;
    }
    if (!data.isRead) {
        
        numAttr = @{NSFontAttributeName:MSGFont(12),NSForegroundColorAttributeName:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor],NSParagraphStyleAttributeName:style};
        textAttr = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor],NSParagraphStyleAttributeName:style};
        _iconView.layer.borderColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor].CGColor;
        _titleView.textColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
        _descrView.textColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];

        
    }else{
        
        numAttr = @{NSFontAttributeName:MSGFont(12),NSForegroundColorAttributeName:[UIColor colorFromHexRGB:@"aaaaaa"],NSParagraphStyleAttributeName:style};
        textAttr = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor colorFromHexRGB:@"aaaaaa"],NSParagraphStyleAttributeName:style};
        _iconView.layer.borderColor = [UIColor colorFromHexRGB:@"aaaaaa"].CGColor;
        _titleView.textColor = [UIColor colorFromHexRGB:@"aaaaaa"];
        _descrView.textColor = [UIColor colorFromHexRGB:@"aaaaaa"];


    }
    
    NSAttributedString *num = [[NSAttributedString alloc] initWithString:CRString(@"%d\n",weekNum) attributes:numAttr];
    NSAttributedString *ws = [[NSAttributedString alloc] initWithString:weeks[week-1] attributes:textAttr];
    
    [weekStr appendAttributedString:num];
    [weekStr appendAttributedString:ws];
    
    _iconView.attributedText = weekStr;
    [_iconView setNeedsDisplay];
    
    _titleView.text = data.title;
    _timeView.text = [formatter stringFromDate:data.cTime];
    NSDictionary *content = [parser objectWithString:data.content];
    if (content) {
        _descrView.text = [Utility dictionaryValue:content forKey:@"content"];
    }else{
        _descrView.text = data.content;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
