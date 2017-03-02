//
//  ZakerGridCell.m
//  msgcopy
//
//  Created by wngzc on 15/5/5.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ZakerGridCell.h"

@implementation ZakerGridCell

-(void)awakeFromNib
{
     [super awakeFromNib];
    self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_click"]];
    _titleView.x = 10;
    _titleView.width = (AppWindow.width - 3)/2.0f - 20;
    _sourceView.x = 10;
    _titleView.font = MSGYHFont(15);
    _sourceView.width = _titleView.width;
    _mainView.frame = CGRectMake(0, 0,(AppWindow.width - 3)/2.0f , App3xScale(180));
    NSString *fontName = FontName;
    CGFloat sourceHeight = CRFontRowHeight(fontName, App3xfont(10), 1);
    _sourceView.font = MSGYHFont(10);
    _sourceView.height = sourceHeight + 5;
    [_titleView addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
/**
 *  KVO
 *
 *  @param keyPath
 *  @param object
 *  @param change
 *  @param context
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]) {
        [self performSelectorOnMainThread:@selector(ajustFrame) withObject:nil waitUntilDone:false];
    }
}
-(void)ajustFrame
{
    NSString *fontName = FontName;
    CGFloat titleHeight = CRFontRowHeight(fontName, App3xfont(15), 2);
    CGFloat maxHeight = ceil(titleHeight) + 5;
    NSDictionary *attr = @{NSFontAttributeName:MSGYHFont(15)};
    CGSize size = [_titleView.text boundingRectWithSize:CGSizeMake(_titleView.width,maxHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
    _titleView.height = size.height;
    _mainView.height = _titleView.height;
    if ([_sourceView.text length]>0) {
        _mainView.height +=  (2 + _sourceView.height);
    }
    _titleView.y = 0;
    _sourceView.y = _titleView.height + 2;
    _mainView.center = CGPointMake(self.width/2.0f, self.height/2.0f);
}
-(void)dealloc
{
    [_titleView removeObserver:self forKeyPath:@"text"];
}
@end
