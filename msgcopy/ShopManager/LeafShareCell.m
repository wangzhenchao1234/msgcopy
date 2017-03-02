//
//  LeafShareCell.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/11.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "LeafShareCell.h"

@implementation LeafShareCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _dotView.cornerRadius = 7.5;
    _dotView.clipsToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
