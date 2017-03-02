//
//  MsgThumbnailCell.m
//  msgcopy
//
//  Created by Gavin on 15/7/7.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MsgThumbnailCell.h"

@implementation MsgThumbnailCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(void)buildWithData:(ArticleEntity*)data
{
    self.cellContentView.thumnail = data.thumbnail.turl;
    [super buildWithData:data];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
