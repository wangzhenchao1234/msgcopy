//
//  GridPhotoCell.m
//  msgcopy
//
//  Created by wngzc on 15/4/29.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "GridPhotoCell.h"

@implementation GridPhotoCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    _titleView.font = MSGYHFont(15);
    _descrView.font = MSGYHFont(12);
    
    UIImage *strechImage = [[UIImage imageNamed:@"ic_imgset_likecount"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 20, 2, 10) resizingMode:UIImageResizingModeStretch];
    [_likeCount setBackgroundImage:strechImage forState:UIControlStateNormal];
//    _likeCount.hidden = true;
}
-(void)updateLikeCount:(NSInteger)count
{
    NSString *countStr = CRString(@"%d",count);
    if (count > 99) {
        countStr = @"99+";
    }
    CGSize size = [countStr sizeWithAttributes:@{NSFontAttributeName:MSGFont(12)}];
    _likeCountWidthConstraint.constant = 22 + size.width + 5;
    [_likeCount setTitle:countStr forState:UIControlStateNormal];
    
}
@end
