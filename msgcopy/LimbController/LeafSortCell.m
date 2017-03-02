//
//  LeafSortCell.m
//  msgcopy
//
//  Created by Gavin on 15/7/29.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "LeafSortCell.h"

@implementation LeafSortCell

- (void)awakeFromNib {
    // Initialization code
     [super awakeFromNib];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = true;
    self.layer.borderColor = CRCOLOR_CLEAR.CGColor;
    self.layer.borderWidth = 1;
}
-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = [UIColor colorFromHexRGB:@"bababa"];
    }else{
        self.backgroundColor = [UIColor colorFromHexRGB:@"EEEFEF"];
    }
}
@end
