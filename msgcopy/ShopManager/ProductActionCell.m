//
//  ProductActionCell.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/17.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "ProductActionCell.h"

@implementation ProductActionCell

- (void)awakeFromNib {
    // Initialization code
    _actionButton.layer.cornerRadius = 7;
    [_actionButton setBackgroundColor:[UIColor whiteColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
