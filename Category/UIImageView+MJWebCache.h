//
//  UIImageView+MJWebCache.h
//  FingerNews
//
//  Created by mj on 13-10-2.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

@interface UIImageView (MJWebCache)
- (void)setImageURL:(NSURL *)url placeholder:(UIImage *)placeholder;
- (void)setImageURLStr:(NSString *)urlStr placeholder:(UIImage *)placeholder;
- (void)setScaleImageURLStr:(NSString *)urlStr placeholder:(UIImage *)placeholder;
@end