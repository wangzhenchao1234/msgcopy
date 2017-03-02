//
//  MorderCell.m
//  Kaoke
//
//  Created by xiaogu on 14-6-5.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "MorderCell.h"

@implementation MorderCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *colorArray = @[@[@"232",@"35",@"41"],@[@"238",@"153",@"33"],@[@"116",@"193",@"142"],@[@"60",@"195",@"237"],@[@"255",@"202",@"8"],@[@"29",@"121",@"186"],@[@"196",@"60",@"149"],@[@"39",@"132",@"66"]];
        NSInteger index = arc4random()%8;
        NSArray *color  = colorArray[index];
        self.backgroundColor = [UIColor colorWithRed:[color[0] floatValue]/255 green:[color[1] floatValue]/255 blue:[color[2] floatValue]/255 alpha:1];
        _itemView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _itemView.backgroundColor = [UIColor clearColor];
        _itemView.contentMode = UIViewContentModeScaleAspectFill;
        _itemView.clipsToBounds = YES;
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width - 20, 20)];
        _titleLable.font = MSGFont(18);
        _titleLable.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_itemView];
        [self.contentView addSubview:_titleLable];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
