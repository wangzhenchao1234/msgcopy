//
//  VideoInfoCell.m
//  msgcopy
//
//  Created by wngzc on 15/5/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "VideoInfoCell.h"

@implementation VideoInfoCell
-(void)awakeFromNib
{
     [super awakeFromNib];
    self.lineLeftInset = 10;
    self.lineRightInset = 0;
}
- (IBAction)like:(id)sender {
    if([_delegate respondsToSelector:@selector(doLike:)])
        [_delegate doLike:sender];
}
- (IBAction)article:(id)sender {
    if([_delegate respondsToSelector:@selector(doArticle:)])
        [_delegate doArticle:sender];
}

@end
