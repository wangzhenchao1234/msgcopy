//
//  ShareCollectionCell.m
//  msgcopy
//
//  Created by Gavin on 15/6/25.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ShareCollectionCell.h"

#define CellSize  floor((AppWindow.width-100)/4.0f)

#define IconSize  (CellSize/2.0f)

#define TitleFont  MSGYHFont(12)


@implementation ShareCollectionCell
-(void)awakeFromNib
{
    self.size = CGSizeMake(CellSize, CellSize);
    CGFloat height = IconSize + 20;
    CGFloat icon_y = (self.height - height)/2.0f;
    CGFloat icon_x = (self.width - IconSize)/2.0f;
    CGFloat title_y = icon_y + IconSize;
    
    _iconView.frame = CGRectMake(icon_x, icon_y, IconSize, IconSize);
    _titleView.frame = CGRectMake(5, title_y, self.width - 10, 20);
    
}
-(void)setHighlighted:(BOOL)highlighted{
    [_iconView setHighlighted:highlighted];
    if (highlighted) {
        _titleView.textColor = [UIColor colorFromHexRGB:@"bababa"];
    }else{
        _titleView.textColor = [UIColor colorFromHexRGB:@"393939"];
    }
}
@end
