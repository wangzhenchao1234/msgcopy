//
//  UIImage+Thumbnail.m
//  Kaoke
//
//  Created by xiaogu on 14-4-16.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "UIImage+Thumbnail.h"

@implementation UIImage (Thumbnail)
+(UIImage*)thumbImage:(UIImage *)image{
    
    CGSize thumbSize = image.size;
    CGFloat scale = 1000/thumbSize.width;
    CGFloat thumbHeight = thumbSize.height*scale;
    if (thumbSize.width>1000) {
        thumbSize.width = 1000;
        thumbSize.height = thumbHeight;
    }else if(thumbSize.height>1775){
        thumbSize.width = thumbSize.width*(1775/thumbSize.height);
        thumbSize.height = 1775;
    }
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat scaleFactor = 0.0;
    CGPoint thumbPoint = CGPointMake(0.0,0.0);
    CGFloat widthFactor = thumbSize.width / width;
    CGFloat heightFactor = thumbSize.height / height;
    if (widthFactor > heightFactor)  {
        scaleFactor = widthFactor;
    }
    else {
        scaleFactor = heightFactor;
    }
    CGFloat scaledWidth  = width * scaleFactor;
    CGFloat scaledHeight = height * scaleFactor;
    if (widthFactor > heightFactor)
    {
        thumbPoint.y = (thumbSize.height - scaledHeight) * 0.5;
    }
    else if (widthFactor < heightFactor)
    {
        thumbPoint.x = (thumbSize.width - scaledWidth) * 0.5;
    }
    UIGraphicsBeginImageContext(thumbSize);
    CGRect thumbRect = CGRectZero;
    thumbRect.origin = thumbPoint;
    thumbRect.size.width  = scaledWidth;
    thumbRect.size.height = scaledHeight;
    [image drawInRect:thumbRect];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *newImage = UIImageJPEGRepresentation(thumbImage, 0.7);
    return [UIImage imageWithData:newImage];
}
+(UIImage *)image:(UIImage *)image rotation:(NSInteger)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case 3:
            rotate = -M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, -image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case 1:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, -image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case 8:
            rotate = -M_PI;
            rect = CGRectMake(0, 0, image.size.width, -image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

@end
