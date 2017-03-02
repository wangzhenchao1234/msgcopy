//
//  ZakerPicCell.m
//  msgcopy
//
//  Created by Gavin on 15/5/5.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ZakerPicCell.h"

@implementation ZakerPicCell
-(void)awakeFromNib
{
     [super awakeFromNib];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_click"]];
//    _thumbnailView.frame = CGRectMake(0, 0, AppWindow.width,App3xScale(360));
    UIImage *strechImage = [[UIImage imageNamed:@"zaker_shadow"] stretchableImageWithLeftCapWidth:2 topCapHeight:1];
    _shadowView.image = strechImage;
    _shadowView.height = App3xScale(90);
    _titleView.height = App3xScale(90);
    _titleView.font = MSGYHFont(15);
}
@end
