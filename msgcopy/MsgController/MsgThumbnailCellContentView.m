//
//  MsgThumbnailCellContentView.m
//  msgcopy
//
//  Created by wngzc on 15/7/8.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MsgThumbnailCellContentView.h"

#define Aption 8

@implementation MsgThumbnailCellContentView

-(void)setThumnail:(NSString *)thumnail
{
    [super setThumnail:thumnail];
    [_thumbnailView sd_setImageWithURL:CRURL(thumnail)];
}
-(void)drawRect:(CGRect)rect
{
    
    CGFloat titleHeight = CRFontRowHeight(DrawFontName, App3xfont(14), 1);
    
    [self.title drawWithRect:CGRectMake(DrawPan +  _thumbnailView.width + Aption, DrawPan, AppWindow.width - DrawPan*2 - _thumbnailView.width - Aption, titleHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:self.titleAttr context:nil];
    
    CGFloat maxHeight = CRFontRowHeight(DrawFontName, App3xfont(13), 2)+5;
    [self.descr drawWithRect:CGRectMake(DrawPan + _thumbnailView.width + Aption,5+DrawPan +  titleHeight, AppWindow.width - 2*DrawPan - _thumbnailView.width - Aption, maxHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:self.descrAttr context:nil];
    
    CGFloat locationHeight = CRFontRowHeight(DrawFontName, App3xfont(12), 1);
    if ([self.distance floatValue]>0) {
        [self.distance drawWithRect:CGRectMake(DrawPan, 2*DrawPan +  titleHeight + maxHeight + 5, (AppWindow.width - 3*DrawPan - _thumbnailView.width - Aption)/2.0f,locationHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:self.disAttr context:nil];
    }
    if ([self.commentCount integerValue]>0) {
        [self.commentCount drawWithRect:CGRectMake(DrawPan/2.0f + (AppWindow.width - 3*DrawPan)/2.0f, 2*DrawPan +  titleHeight + maxHeight + 5, (AppWindow.width - 3*DrawPan- _thumbnailView.width - Aption)/2.0f,locationHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:self.cmtAttr context:nil];
    }
    
}

@end
