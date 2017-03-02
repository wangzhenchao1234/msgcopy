//
//  MsgGroupCell.m
//  msgcopy
//
//  Created by wngzc on 15/7/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MsgGroupCell.h"

@implementation MsgGroupCell

- (void)awakeFromNib {
    // Initialization code
    self.lineLeftInset = 15;
    self.lineRightInset = 15;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
