//
//  TabBarMoreCell.m
//  msgcopy
//
//  Created by wngzc on 15/4/21.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "TabBarMoreCell.h"
#define CellSize (AppWindow.width/3.0f) - 4.0f

@implementation TabBarMoreCell
-(void)awakeFromNib
{
    self.width = CellSize;
    self.height = CellSize;
    _titleView.font = MSGYHFont(12);
    _titleView.textColor = [UIColor colorFromHexRGB:@"757575"];
    
}
@end
