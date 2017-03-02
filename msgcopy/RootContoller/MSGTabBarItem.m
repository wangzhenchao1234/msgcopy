//
//  MSGTabBarItem.m
//  msgcopy
//
//  Created by Gavin on 15/4/16.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MSGTabBarItem.h"
#import <QuartzCore/QuartzCore.h>

@interface MSGTabBarItem()

@property NSString *unselectedImageUrl;
@property NSString *selectedImageUrl;

@end

@implementation MSGTabBarItem

-(NSString*)finishedSelectedImageUrl
{
    return [self selectedImageUrl];
}

-(NSString*)finishedUnselectedImageUrl
{
    return [self unselectedImageUrl];
}

- (void)setFinishedSelectedImageUrl:(NSString *)selectedImageUrl withFinishedUnselectedImage:(NSString *)unselectedImageUrl {
    if (selectedImageUrl && (selectedImageUrl != [self selectedImageUrl])) {
        [self setSelectedImageUrl:selectedImageUrl];
    }
    
    if (unselectedImageUrl && (unselectedImageUrl != [self unselectedImageUrl])) {
        [self setUnselectedImageUrl:unselectedImageUrl];
    }
}
- (void)drawRect:(CGRect)rect {
    
    NSString *imageUrl = nil;
    __block UIImage *image = nil;
    
    if ([self isSelected]) {
        imageUrl = [self selectedImageUrl];
    } else {
        imageUrl = [self unselectedImageUrl];
    }
    if (imageUrl) {
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl];
        if (cacheImage) {
            image = cacheImage;
            [self drawItemImageRect:image rect:rect];
        }else{
            CRWeekRef(self);
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(imageUrl) options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *finishedImage, NSData *data, NSError *error, BOOL finished) {
                if (finished&&!error) {
                    [[SDImageCache sharedImageCache] storeImage:finishedImage forKey:imageUrl];
                    [__self setNeedsDisplay];
                }
            }];
        }
        [self drawItemImageRect:image?image:IconPlaceImage rect:rect];

    }else{
        if ([self isSelected]) {
            image = self.selectedImage;
        }else{
            image = self.unselectedImage;
        }
        [self drawItemImageRect:image?image:IconPlaceImage rect:rect];
    }
}
-(void)drawItemImageRect:(UIImage *)image rect:(CGRect)rect{

    self.titlePositionAdjustment = UIOffsetMake(0, 6);
    CGSize frameSize = self.frame.size;
    CGSize imageSize = CGSizeZero;
    CGSize titleSize = CGSizeZero;
    UIImage *backgroundImage = nil;
    CGFloat imageStartingY =0.0f;
    NSDictionary *titleAttributes = nil;
    if ([self isSelected]) {
//        backgroundImage = [self selectedBackgroundImage];
        titleAttributes = [self selectedTitleAttributes];
        if (!titleAttributes) {
            titleAttributes = [self unselectedTitleAttributes];
        }
    } else {
//        backgroundImage = [self unselectedBackgroundImage];
        titleAttributes = [self unselectedTitleAttributes];
    }

//    imageSize = [image size];
    imageSize = CGSizeMake(20, 20);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [backgroundImage drawInRect:self.bounds];
    
    // Draw image and title
    
    if (![self.title length]) {
        [image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2) +
                                     self.imagePositionAdjustment.horizontal,
                                     roundf(frameSize.height / 2 - imageSize.height / 2) +
                                     self.imagePositionAdjustment.vertical,
                                     imageSize.width, imageSize.height)];
    } else {
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            titleSize = [self.title boundingRectWithSize:CGSizeMake(frameSize.width, 20)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:titleAttributes
                                             context:nil].size;
            
            imageStartingY = roundf((frameSize.height - imageSize.height - titleSize.height - self.imagePositionAdjustment.vertical - self.titlePositionAdjustment.vertical) / 2);
            
            [image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2) +
                                         self.imagePositionAdjustment.horizontal,
                                         imageStartingY + self.imagePositionAdjustment.vertical,
                                         imageSize.width, imageSize.height)];
            
            CGContextSetFillColorWithColor(context, [titleAttributes[NSForegroundColorAttributeName] CGColor]);

            [self.title drawInRect:CGRectMake(roundf(frameSize.width / 2 - titleSize.width / 2) +
                                          self.titlePositionAdjustment.horizontal,
                                          imageStartingY + imageSize.height + self.titlePositionAdjustment.vertical,
                                          titleSize.width, titleSize.height)
                withAttributes:titleAttributes];
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            titleSize = [_title sizeWithFont:titleAttributes[UITextAttributeFont]
                           constrainedToSize:CGSizeMake(frameSize.width, 20)];
            UIOffset titleShadowOffset = [titleAttributes[UITextAttributeTextShadowOffset] UIOffsetValue];
            imageStartingY = roundf((frameSize.height - imageSize.height - titleSize.height) / 2);
            
            [image drawInRect:CGRectMake(roundf(frameSize.width / 2 - imageSize.width / 2) +
                                         _imagePositionAdjustment.horizontal,
                                         imageStartingY + _imagePositionAdjustment.vertical,
                                         imageSize.width, imageSize.height)];
            
            CGContextSetFillColorWithColor(context, [titleAttributes[UITextAttributeTextColor] CGColor]);
            
            UIColor *shadowColor = titleAttributes[UITextAttributeTextShadowColor];
            
            if (shadowColor) {
                CGContextSetShadowWithColor(context, CGSizeMake(titleShadowOffset.horizontal, titleShadowOffset.vertical),
                                            1.0, [shadowColor CGColor]);
            }
            
            [_title drawInRect:CGRectMake(roundf(frameSize.width / 2 - titleSize.width / 2) +
                                          _titlePositionAdjustment.horizontal,
                                          imageStartingY + imageSize.height + _titlePositionAdjustment.vertical,
                                          titleSize.width, titleSize.height)
                      withFont:titleAttributes[UITextAttributeFont]
                 lineBreakMode:NSLineBreakByTruncatingTail];
#endif
        }
    }
    
    // Draw badges
    
    if ([[self badgeValue] length]) {
        CGSize badgeSize = CGSizeZero;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            badgeSize = [self.badgeValue boundingRectWithSize:CGSizeMake(frameSize.width, 20)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName: [self badgeTextFont]}
                                                  context:nil].size;
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            badgeSize = [_badgeValue sizeWithFont:[self badgeTextFont]
                                constrainedToSize:CGSizeMake(frameSize.width, 20)];
#endif
        }
        
        CGFloat textOffset = 2.0f;
        
        if (badgeSize.width < badgeSize.height) {
            badgeSize = CGSizeMake(badgeSize.height, badgeSize.height);
        }
        
        CGRect badgeBackgroundFrame = CGRectMake(roundf(frameSize.width / 2 + (image.size.width / 2) * 0.9) +
                                                 [self badgePositionAdjustment].horizontal,
                                                 textOffset + [self badgePositionAdjustment].vertical,
                                                 badgeSize.width + 2 * textOffset, badgeSize.height + 2 * textOffset);
        
        if ([self badgeBackgroundColor]) {
            CGContextSetFillColorWithColor(context, [[self badgeBackgroundColor] CGColor]);
            
            CGContextFillEllipseInRect(context, badgeBackgroundFrame);
        } else if ([self badgeBackgroundImage]) {
            [[self badgeBackgroundImage] drawInRect:badgeBackgroundFrame];
        }
        
        CGContextSetFillColorWithColor(context, [[self badgeTextColor] CGColor]);
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            NSMutableParagraphStyle *badgeTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [badgeTextStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [badgeTextStyle setAlignment:NSTextAlignmentCenter];
            
            NSDictionary *badgeTextAttributes = @{
                                                  NSFontAttributeName: [self badgeTextFont],
                                                  NSForegroundColorAttributeName: [self badgeTextColor],
                                                  NSParagraphStyleAttributeName: badgeTextStyle,
                                                  };
            
            [[self badgeValue] drawInRect:CGRectMake(CGRectGetMinX(badgeBackgroundFrame) + textOffset,
                                                     CGRectGetMinY(badgeBackgroundFrame) + textOffset,
                                                     badgeSize.width, badgeSize.height)
                           withAttributes:badgeTextAttributes];
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            [[self badgeValue] drawInRect:CGRectMake(CGRectGetMinX(badgeBackgroundFrame) + textOffset,
                                                     CGRectGetMinY(badgeBackgroundFrame) + textOffset,
                                                     badgeSize.width, badgeSize.height)
                                 withFont:[self badgeTextFont]
                            lineBreakMode:NSLineBreakByTruncatingTail
                                alignment:NSTextAlignmentCenter];
#endif
        }
    }
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    CGContextBeginPath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor colorFromHexRGB:@"9f9fa0"].CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextStrokePath(context);
    //上分割线
    
    CGContextRestoreGState(context);
    
}
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *pngData = UIImagePNGRepresentation(reSizeImage);
    
    return [UIImage imageWithData:pngData];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
