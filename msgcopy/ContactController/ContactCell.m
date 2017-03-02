//
//  ContactCell.m
//  msgcopy
//
//  Created by Gavin on 15/7/25.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ContactCell.h"

@implementation ContactCell

- (void)awakeFromNib {
    // Initialization code
    _headView.layer.cornerRadius = 20;
    _headView.clipsToBounds = true;
    _nickView.font = MSGFont(14);
    _phoneView.font = MSGFont(12);
    _nickView.textColor = CellTitleColr;
    _phoneView.textColor = [UIColor colorFromHexRGB:@"aaaaaa"];
    self.separatorInset = UIEdgeInsetsMake(0, 44, 0, 0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
