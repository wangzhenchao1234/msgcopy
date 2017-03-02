//
//  MsgCellContentView.m
//  msgcopy
//
//  Created by wngzc on 15/7/8.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MsgCellContentView.h"

@implementation MsgCellContentView
-(void)awakeFromNib
{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    _titleAttr = @{NSFontAttributeName:MSGYHFont(13),NSForegroundColorAttributeName:[UIColor colorFromHexRGB:@"393939"],NSParagraphStyleAttributeName:paragraphStyle};
    _descrAttr = @{NSFontAttributeName:MSGYHFont(12),NSForegroundColorAttributeName:[UIColor colorFromHexRGB:@"999999"],NSParagraphStyleAttributeName:paragraphStyle};
    _disAttr = @{NSFontAttributeName:MSGYHFont(11),NSForegroundColorAttributeName:[UIColor colorFromHexRGB:@"999999"],NSParagraphStyleAttributeName:paragraphStyle};
    NSMutableParagraphStyle *cmtParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    cmtParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    cmtParagraphStyle.alignment = NSTextAlignmentRight;
    _cmtAttr = @{NSFontAttributeName:MSGYHFont(12),NSForegroundColorAttributeName:[UIColor colorFromHexRGB:@"999999"],NSParagraphStyleAttributeName:cmtParagraphStyle};
}
-(void)drawRect:(CGRect)rect
{
    CGFloat titleHeight = CRFontRowHeight(DrawFontName, App3xfont(13), 1);
    [_title drawWithRect:CGRectMake(DrawPan, DrawPan, AppWindow.width - DrawPan*2, titleHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:_titleAttr context:nil];
    
    CGFloat maxHeight = CRFontRowHeight(DrawFontName, App3xfont(12), 2)+5;
    [_descr drawWithRect:CGRectMake(DrawPan,DrawPan +  titleHeight, AppWindow.width - 2*DrawPan, maxHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:_descrAttr context:nil];
    
    CGFloat locationHeight = CRFontRowHeight(DrawFontName, App3xfont(11), 1);
    if ([_distance floatValue]>0) {
        [_distance drawWithRect:CGRectMake(DrawPan, 2*DrawPan +  titleHeight + maxHeight + 5, (AppWindow.width - 3*DrawPan)/2.0f,locationHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:_disAttr context:nil];
    }
    if ([_commentCount integerValue]>0) {
        [_commentCount drawWithRect:CGRectMake(DrawPan/2.0f + (AppWindow.width - 3*DrawPan)/2.0f, 2*DrawPan +  titleHeight + maxHeight + 5, (AppWindow.width - 3*DrawPan)/2.0f,locationHeight) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:_cmtAttr context:nil];
    }
}
@end
