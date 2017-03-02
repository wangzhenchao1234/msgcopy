//
//  MsgCell.m
//  msgcopy
//
//  Created by Gavin on 15/7/7.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MsgCell.h"


@implementation MsgCell

- (void)awakeFromNib {
    // Initialization code
}
-(void)buildWithData:(ArticleEntity*)data
{
    _cellContentView.title = data.title;
    _cellContentView.descr = data.descr;
    _cellContentView.commentCount = CRString(@"评论%d",data.comment_count);
    CGFloat disdance = [LocationManager disdanceToLocation:data.location type:LocationTypeBaidu];
    if (disdance>1000) {
        _cellContentView.distance = CRString(@"%fkm",disdance/1000);
    }else{
        _cellContentView.distance = CRString(@"%fm",disdance);
    }
    [self.cellContentView setNeedsDisplay];
}

+(CGFloat)cellHeight{
    
    CGFloat titleHeight = CRFontRowHeight(DrawFontName, App3xfont(14), 1);
    CGFloat maxHeight = CRFontRowHeight(DrawFontName, App3xfont(13), 2);
    CGFloat locationHeight = CRFontRowHeight(DrawFontName, App3xfont(12), 1);
    return 10 +titleHeight + maxHeight + locationHeight;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
