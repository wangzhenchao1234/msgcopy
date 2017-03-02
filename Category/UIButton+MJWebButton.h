//
//  UIButton+MJWebButton.h
//  Kaoke
//
//  Created by xiaogu on 14-9-2.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+MJWebButton.h"

@interface UIButton (MJWebButton)
- (void)setScaleImageWithURL:(NSString *)urlStr placeholder:(UIImage *)placeholder forState:(UIControlState)state;

@end
