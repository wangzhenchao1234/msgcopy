//
//  RightCell.m
//  msgcopy
//
//  Created by Gavin on 15/5/7.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "RightCell.h"

@implementation RightCell

- (void)awakeFromNib {
     [super awakeFromNib];
    // Initialization code
    _badgeView.hidden = true;
    _badgeView.layer.cornerRadius = _badgeView.height/2.0f;
    _badgeView.clipsToBounds = true;
    [_badgeView addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    _iconView.layer.cornerRadius = 5;
    _iconView.clipsToBounds = true;
    _titleView.font = MSGFont(13);
    _badgeView.font = MSGFont(13);
    _titleView.textColor = CellTitleColr;
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_arrow_right"]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"text"]) {
        [self performSelectorOnMainThread:@selector(adjustFrame) withObject:nil waitUntilDone:false];
    }
}
-(void)adjustFrame{
    
    [_badgeView sizeToFit];
    _badgeView.width = _badgeView.width>(_badgeView.height)?(_badgeView.width + 8):(_badgeView.height+4);
    _badgeView.height += 4;

}
-(void)dealloc
{
    [_badgeView removeObserver:self forKeyPath:@"text"];
}
@end
