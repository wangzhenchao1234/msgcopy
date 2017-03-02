//
//  ContactHeaderCell.m
//  msgcopy
//
//  Created by Gavin on 15/7/27.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ContactHeaderCell.h"

@implementation ContactHeaderCell

- (void)awakeFromNib {
    // Initialization code
    _nickView.font = MSGFont(14);
    _nickView.textColor = CellTitleColr;
    _nickView.x = 62;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
