//
//  UserHeadView.m
//  msgcopy
//
//  Created by Gavin on 15/6/12.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "HeadView.h"

@implementation HeadView

-(void)awakeFromNib{
     [super awakeFromNib];
    self.clipsToBounds = true;
    self.layer.cornerRadius = self.size.height/2.0f;
}
-(void)setImageWithUrl:(NSString *)headUrl
{
    _url = headUrl;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (!_url) {
        [UserPlaceImage drawInRect:rect];
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *cachImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_url];
    if (cachImage) {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        CGContextFillRect(context, rect);
        [cachImage drawInRect:rect];
    }else{
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(_url) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            if (finished&&!error) {
                [image drawInRect:rect];
                [[SDImageCache sharedImageCache] storeImage:image forKey:_url];
            }
        }];
    }
}


@end
