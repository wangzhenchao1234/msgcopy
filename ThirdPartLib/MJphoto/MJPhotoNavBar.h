//
//  MJPhotoNavBar.h
//  Kaoke
//
//  Created by xiaogu on 14-3-12.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJPhotoNavBar : UIView
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
@end
