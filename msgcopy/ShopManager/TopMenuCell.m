//
//  TopMenuCell.m
//  PSClient
//
//  Created by Hackintosh on 15/9/25.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import "TopMenuCell.h"

@implementation TopMenuCell

- (void)awakeFromNib {
    // Initialization code
    _selectView.hidden = true;

}
-(void)setSelected:(BOOL)selected
{
    _selectView.hidden = !selected;
    if (selected) {
        _titleView.textColor = [UIColor redColor];
    }else{
        _titleView.textColor = [UIColor blackColor];
    }
}
@end
