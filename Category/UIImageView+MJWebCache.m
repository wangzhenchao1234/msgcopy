//
//  UIImageView+MJWebCache.m
//  FingerNews
//
//  Created by mj on 13-10-2.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "UIImageView+MJWebCache.h"


@implementation UIImageView (MJWebCache)
- (void)setImageURL:(NSURL *)url placeholder:(UIImage *)placeholder
{
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageLowPriority];
}

- (void)setImageURLStr:(NSString *)urlStr placeholder:(UIImage *)placeholder
{
    [self setImageURL:[NSURL URLWithString:urlStr] placeholder:placeholder];
}
- (void)setScaleImageURLStr:(NSString *)urlStr placeholder:(UIImage *)placeholder
{
    
    self.image = [self image:placeholder scaleToSize:self.frame.size];
    CGSize size = self.frame.size;
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
    if (!cacheImage) {
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:urlStr] options:SDWebImageDownloaderLowPriority | SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
        {
    
            if (finished) {
                if (image) {
                    UIImage *scaleImage = [self image:image scaleToSize:size];
                    [[SDImageCache sharedImageCache] storeImage:scaleImage forKey:urlStr];
                    self.image = image;
                    image = nil;
                }
            }
        }];
        
    }else{

        self.image = cacheImage;
    
    }
}
-(UIImage*)image:(UIImage*)image scaleToSize:(CGSize)size
{
    CGFloat width = CGImageGetWidth(image.CGImage);
    CGFloat height = CGImageGetHeight(image.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}
@end
