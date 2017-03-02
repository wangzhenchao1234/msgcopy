//
//  MJPhotoNavBar.m
//  Kaoke
//
//  Created by xiaogu on 14-3-12.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "MJPhotoNavBar.h"
#import "MJPhoto.h"
@interface MJPhotoNavBar()
{
    // 显示页码
    UILabel *_indexLabel;
}
@end
@implementation MJPhotoNavBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.frame = self.bounds;
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
    
    // 保存图片按钮
}
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    // 更新页码
    if (_photos.count<=1) {
        _indexLabel.text = @"";
        return;
    }
    _indexLabel.text = [NSString stringWithFormat:@"%d / %d", _currentPhotoIndex + 1, _photos.count];
    // 按钮
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
