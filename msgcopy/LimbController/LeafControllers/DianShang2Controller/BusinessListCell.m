//
//  BusinessListCell.m
//  msgcopy
//
//  Created by Gavin on 15/4/16.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "BusinessListCell.h"
#import "UICustomLineLabel.h"

#define WHScale 70/93

#define WWScale 31/100
#define Margin 10


@implementation BusinessListCell


- (void)awakeFromNib {
    // Initialization code
     [super awakeFromNib];
    _thumbnailView.x = 10;
    _thumbnailView.y = 10;
    _thumbnailView.width = (AppWindow.width - 20)*WWScale;
    _thumbnailView.height = _thumbnailView.width * WHScale;
    
    NSString *fontName = FontName;
    CGFloat titleHeight = CRFontRowHeight(fontName, App3xfont(13), 2);

    
    _titleView.x = _thumbnailView.x + _thumbnailView.width + 8;
    _titleView.y = 10;
    _titleView.height = titleHeight+5;
    _titleView.font = MSGYHFont(13);
    
    CGFloat otherHeight = CRFontRowHeight(fontName, App3xfont(11), 1);

    _prePriceView.x = _titleView.x;
    _prePriceView.height = otherHeight+5;
    _prePriceView.y = _thumbnailView.y + _thumbnailView.height - _prePriceView.height;
    _prePriceView.font = MSGYHFont(11);
    
    _priceView.x = _titleView.x;
    _priceView.height = titleHeight/2.0f+5;
    _priceView.y = _prePriceView.y - 5 - _priceView.height;
    _priceView.font = MSGYHFont(13);

    _prePriceView.lineColor = [UIColor colorFromHexRGB:@"b4b5b5"];
    _prePriceView.lineType = LineTypeMiddle;

    
}

+(CGFloat)getCellHeight{
    
    CGFloat width = (AppWindow.width - 20)*WWScale;
    CGFloat height = width * WHScale;
    return height + 20;
    
}
-(void)buildWithData:(PubEntity*)pub
{
    
//    NSLog(@"^^^^^^^^^^^^^ 类型：%@ - 现价：%@ - 原价：%@",pub.article.ctype.systitle,pub.article.descr,pub.article.source);
    
    
    _LikeLabel.text = [NSString stringWithFormat:@"%d",pub.article.like];
    
    _PLlabel.text = [NSString stringWithFormat:@"%d",pub.article.comment_count];
    
    //
    
    _titleView.text = pub.article.title;
    _priceView.text = @"";
    
    
    
    //&&[pub.article.content rangeOfString:@"form_id"].location!= NSNotFound
     if ([pub.article.ctype.systitle isEqualToString:@"dianshang"]) {
    
    if ([pub.article.descr length]>0) {
        _priceView.text = CRString(@"￥%@元",pub.article.descr);
    }
    _prePriceView.text = @"";
    if ([pub.article.source length]>0) {
        _prePriceView.text = CRString(@"原价:%@元",pub.article.source);
    }
         
         NSLog(@"");
         
     }else{
         _priceView.text = @"";
         _prePriceView.text = @"";
     }
    
//    if ([pub.article.ctype.systitle isEqualToString:@"huipai"]||[pub.article.ctype.systitle isEqualToString:@"biaodan"]||[pub.article.ctype.systitle isEqualToString:@"zhuanti"]) {
//        
//    }
    
    
    NSString *fontName = FontName;
    CGFloat descrHeight = CRFontRowHeight(fontName, App3xfont(13), 2);
    _titleView.x = _thumbnailView.x + _thumbnailView.width + 8;
    _titleView.width = AppWindow.width - Margin*2 - 8 - _thumbnailView.width;
    CGFloat maxHeight = ceil(descrHeight)+5;
    NSDictionary *attr = @{NSFontAttributeName:MSGYHFont(13)};
    CGSize titleSize = [pub.article.title boundingRectWithSize:CGSizeMake(_titleView.width,maxHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
    _titleView.height = titleSize.height;
    if (!pub.article.source) {
        _prePriceView.hidden = true;
        _priceView.y = _thumbnailView.height + _thumbnailView.y - _priceView.height;
    }else{
        _prePriceView.hidden = false;
        _prePriceView.y = _thumbnailView.height + _thumbnailView.y - _prePriceView.height;
        _priceView.y = _prePriceView.y - 5 - _priceView.height;
    }

    [_thumbnailView sd_setImageWithURL:CRURL(pub.article.thumbnail.turl) placeholderImage:ProductPlaceImage];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
