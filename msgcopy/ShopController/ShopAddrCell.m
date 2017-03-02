//
//  ShopAddrCell.m
//  msgcopy
//
//  Created by Gavin on 15/4/20.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ShopAddrCell.h"

@implementation ShopAddrCell

- (void)awakeFromNib {
     [super awakeFromNib];
    // Initialization code
    _topLineHeightConstraint.constant = 1.0f/ScreenScale;
    _bottomLineHeightConstraint.constant = 1.0f/ScreenScale;
    _addrView.font = MSGFont(14);

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
