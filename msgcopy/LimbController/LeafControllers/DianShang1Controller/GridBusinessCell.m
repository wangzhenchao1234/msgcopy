//
//  GridBusinessCell.m
//  msgcopy
//
//  Created by wngzc on 15/4/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "GridBusinessCell.h"
#import "UICustomLineLabel.h"
#import <CoreText/CoreText.h>
#define Margin 8
#define CellWidth  ((AppWindow.width - 30)/2.0f)

@implementation GridBusinessCell
-(void)awakeFromNib
{
     [super awakeFromNib];
    _productImageView.frame = CGRectMake(0, 0,CellWidth ,CellWidth-Margin);
    _productImageView.layer.cornerRadius = 2.5;
    _productImageView.clipsToBounds = true;
    
    _descrView.y = _productImageView.y + _productImageView.height;
    
    _descrView.font = MSGYHFont(14);
    _priceView.font = MSGYHFont(14);
    _prePrice.font = MSGYHFont(11);
    
    NSString *fontName = FontName;
    CGFloat descrHeight = CRFontRowHeight(fontName, App3xfont(14), 2);
    
    _descrView.x = Margin;
    _descrView.width = CellWidth - Margin*2;
    _descrView.height = ceil(descrHeight)+5;

    _priceView.y = _descrView.y + _descrView.height ;
    _priceView.x = Margin;
    _priceView.width = CellWidth/2.0f;
    
    _prePrice.x =  CellWidth/2.0f;
    _prePrice.height = 13;
    _prePrice.y = _priceView.y + _priceView.height - _prePrice.height;
    _prePrice.width = CellWidth/2.0f;
    
    self.layer.cornerRadius = 2.5;
    self.clipsToBounds = true;
    self.layer.borderColor = [UIColor colorFromHexRGB:@"baaaaa"].CGColor;
    self.layer.borderWidth = 1;
    
    _prePrice.lineColor = [UIColor colorFromHexRGB:@"b4b5b5"];
    _prePrice.lineType = LineTypeMiddle;
    
}
-(void)buildWithData:(PubEntity*)pub
{
    _LikeLabel.text = [NSString stringWithFormat:@"%d",pub.article.like];

    _PLlabel.text = [NSString stringWithFormat:@"%d",pub.article.comment_count];
    [_productImageView sd_setImageWithURL:CRURL(pub.article.thumbnail.turl) placeholderImage:ProductPlaceImage];
    _descrView.text = pub.article.title;
    _priceView.text = @"";
    if ([pub.article.descr length]>0) {
        _priceView.text = CRString(@"￥%@元",pub.article.descr);
    }
    _prePrice.text = @"";
    if ([pub.article.source length]>0) {
        _prePrice.text = CRString(@"原价:%@元",pub.article.source);
    }
    
    if (![pub.article.ctype.systitle isEqualToString:@"dianshang"]&&[pub.article.content rangeOfString:@"form_id"].location!= NSNotFound) {
        _priceView.text = CRString(@"%@",pub.article.descr);
        _prePrice.text = CRString(@"原价:%@元",pub.article.source);
    }

    if (pub.article.source&&pub.article.source.length>0) {
        _prePrice.hidden = false;
        _priceView.width = CellWidth / 2.0f - Margin*2;
    }else{
        _priceView.width = CellWidth - Margin*2;
        _prePrice.hidden = true;
    }
}
+(CGFloat)getHeigh:(PubEntity*)pub
{
    NSString *fontName = FontName;
    CGFloat descrHeight =  CRFontRowHeight(fontName, App3xfont(14), 2);
    return CellWidth + 5 + descrHeight + Margin + 5 + descrHeight/2.0f + Margin;
}
@end
