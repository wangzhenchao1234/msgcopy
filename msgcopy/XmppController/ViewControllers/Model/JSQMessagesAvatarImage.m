//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesAvatarImage.h"

@implementation JSQMessagesAvatarImage 

#pragma mark - Initialization

+ (instancetype)avatarWithImage:(NSString *)image
{
    NSParameterAssert(image != nil);
    
    return [[JSQMessagesAvatarImage alloc] initWithAvatarImage:image
                                              highlightedImage:image
                                              placeholderImage:UserPlaceImage];
}

+ (instancetype)avatarImageWithPlaceholder:(UIImage *)placeholderImage
{
    return [[JSQMessagesAvatarImage alloc] initWithAvatarImage:nil
                                              highlightedImage:nil
                                              placeholderImage:placeholderImage];
}

- (instancetype)initWithAvatarImage:(NSString *)avatarImage
                   highlightedImage:(NSString *)highlightedImage
                   placeholderImage:(UIImage *)placeholderImage
{
    NSParameterAssert(placeholderImage != nil);
    
    self = [super init];
    if (self) {
        _avatarImage = avatarImage;
        _avatarHighlightedImage = highlightedImage;
        _avatarPlaceholderImage = placeholderImage;
    }
    return self;
}

- (id)init
{
    NSAssert(NO, @"%s is not a valid initializer for %@. Use %@ instead.",
             __PRETTY_FUNCTION__, [self class], NSStringFromSelector(@selector(initWithAvatarImage:highlightedImage:placeholderImage:)));
    return nil;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: avatarImage=%@, avatarHighlightedImage=%@, avatarPlaceholderImage=%@>",
            [self class], self.avatarImage, self.avatarHighlightedImage, self.avatarPlaceholderImage];
}

- (id)debugQuickLookObject
{
    __block UIImageView *imageView = [[UIImageView alloc] init];
    if (_avatarImage) {
        UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_avatarImage];
        if (cacheImage) {
            UIImage *avatar = [JSQMessagesAvatarImage jsq_circularImage:cacheImage withDiameter:30 highlightedColor:nil];
            imageView.image = avatar;
        }else{
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(_avatarImage) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (image&&!error&&finished) {
                    UIImage *avatar = [JSQMessagesAvatarImage jsq_circularImage:image withDiameter:30 highlightedColor:nil];
                    imageView.image = avatar;
                    [[SDImageCache sharedImageCache] storeImage:image forKey:_avatarImage];
                }
            }];
        }
    }else{
        UIImage *avatar = [JSQMessagesAvatarImage jsq_circularImage:_avatarPlaceholderImage withDiameter:30 highlightedColor:nil];
        imageView.image = avatar;
    }
    return imageView;
}
+ (UIImage *)jsq_circularImage:(UIImage *)image withDiameter:(NSUInteger)diameter highlightedColor:(UIColor *)highlightedColor
{
    NSParameterAssert(image != nil);
    NSParameterAssert(diameter > 0);
    CGRect frame = CGRectMake(0.0f, 0.0f, diameter, diameter);
    UIImage *newImage = nil;
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, [UIScreen mainScreen].scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIBezierPath *imgPath = [UIBezierPath bezierPathWithOvalInRect:frame];
        [imgPath addClip];
        [image drawInRect:frame];
        if (highlightedColor != nil) {
            CGContextSetFillColorWithColor(context, highlightedColor.CGColor);
            CGContextFillEllipseInRect(context, frame);
        }
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithAvatarImage:self.avatarImage
                                                 highlightedImage:self.avatarHighlightedImage
                                                 placeholderImage:[UIImage imageWithCGImage:self.avatarPlaceholderImage.CGImage]];
}

@end
