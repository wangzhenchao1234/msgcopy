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

#import "JSQPhotoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"


@interface JSQPhotoMediaItem ()

@end


@implementation JSQPhotoMediaItem

#pragma mark - Initialization

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = [image copy];
    }
    return self;
}
-(instancetype)initWithImageUrl:(NSString *)imageUrl complete:(void(^)(BOOL result, UIImage*image))complete
{
    self = [super init];
    if (self) {
        _imageUrl = [imageUrl copy];
        UIImage *cacheImage= [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageUrl];
        if (!cacheImage) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(imageUrl) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (complete) {
                    complete(finished,image);
                }
                [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrl];
                _image = image;
            }];
        }else{
            _image = [cacheImage copy];
        }
        _cachedImageView = nil;
    }
    return self;
}
- (void)dealloc
{
    _image = nil;
    _cachedImageView = nil;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    _image = [image copy];
    _cachedImageView = nil;
}
- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = [imageUrl copy];
    _cachedImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.image == nil) {
        return nil;
    }
    
    if (self.cachedImageView == nil) {
        CGSize size = [self mediaViewDisplaySize];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_image];
        imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedImageView = imageView;
    }
    
    return self.cachedImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.image.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@,imageUrl=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.image,self.imageUrl, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
        _imageUrl = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(imageUrl))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
    [aCoder encodeObject:self.imageUrl forKey:NSStringFromSelector(@selector(imageUrl))];

}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQPhotoMediaItem *copy = nil;
    if (self.image) {
         copy = [[[self class] allocWithZone:zone] initWithImage:self.image];
    }else{
         copy = [[[self class] allocWithZone:zone] initWithImageUrl:self.imageUrl complete:nil];
    }
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end