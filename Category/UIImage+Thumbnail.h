//
//  UIImage+Thumbnail.h
//  Kaoke
//
//  Created by xiaogu on 14-4-16.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Thumbnail)
+(UIImage*)thumbImage:(UIImage *)image;
+(UIImage *)image:(UIImage *)image rotation:(NSInteger)orientation;
@end
