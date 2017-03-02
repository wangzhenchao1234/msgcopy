//
//  CardHeaderView.m
//  msgcopy
//
//  Created by wngzc on 15/5/5.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "CardHeaderView.h"
#define HeadSize App3xScale(40)

@implementation CardHeaderView
-(void)awakeFromNib
{ 
     [super awakeFromNib];
    _headImageView.frame = CGRectMake(DefaultPan, DefaultPan, HeadSize, HeadSize);
    NSString *fontName = FontName;
    CGFloat labelHeight = CRFontRowHeight(fontName, App3xfont(13), 1) + 5;
    _nickView.frame = CGRectMake(_headImageView.x + _headImageView.width + DefaultInset, DefaultPan, AppWindow.width - _headImageView.x - _headImageView.width - DefaultInset - DefaultPan*2,labelHeight);
    _timeView.x = _nickView.x;
    _timeView.height = labelHeight;
    _timeView.y = _headImageView.y + _headImageView.height - labelHeight;
    _timeView.font = MSGYHFont(13);
    _nickView.font = MSGYHFont(13);
    _locationView.titleLabel.font = MSGYHFont(13);
    _locationView.frame = CGRectMake(_timeView.x + _timeView.width + DefaultPan, _timeView.y, 40,_timeView.height);
    [_timeView addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]) {
        [self performSelectorOnMainThread:@selector(adjustFrame:) withObject:object waitUntilDone:false];
    }
}
-(void)adjustFrame:(id)sender{
    
    [_timeView sizeToFit];
    _timeView.x = _nickView.x;
    _timeView.y = _headImageView.y + _headImageView.height - _timeView.height;
    [_locationView sizeToFit];
    _locationView.x = _timeView.x + _timeView.width + DefaultPan;
    _locationView.height = _timeView.height;
    _locationView.y = _timeView.y;
}
-(void)dealloc
{
    [_timeView removeObserver:self forKeyPath:@"text"];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
