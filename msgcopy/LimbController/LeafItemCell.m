//
//  LeafItemCell.m
//  msgcopy
//
//  Created by Gavin on 15/4/16.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "LeafItemCell.h"

#define Margin 10

@implementation LeafItemCell
-(void)awakeFromNib
{
    _titleView.font = MSGYHFont(13);
}
-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _titleView.transform = CGAffineTransformMakeScale(LeafMenuScale, LeafMenuScale);
        UIColor *defaultColor = [UIColor colorFromHexRGB:LeafDefaultColor];
        if (kCurApp.menuBar.backgroundColor) {
            defaultColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
        }
        self.titleView.textColor = defaultColor;
    }else{
        _titleView.transform = CGAffineTransformMakeScale(1, 1);
        self.titleView.textColor = [UIColor colorFromHexRGB:LeafDefaultColor];
    }
}
+(CGFloat)getWidth:(NSString*)title
{
    NSDictionary *attr = @{
                           NSFontAttributeName:MSGYHFont(17)
                           };
    CGFloat width = [title boundingRectWithSize:CGSizeMake(AppWindow.width,100) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size.width;
    return width + 2*Margin;
}
@end
