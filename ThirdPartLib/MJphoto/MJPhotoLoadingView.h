//
//  MJPhotoLoadingView.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMinProgress 0.0001
#import "MJPhotoProgressView.h"
@class MJPhotoBrowser;
@class MJPhoto;

@interface MJPhotoLoadingView : UIView
@property (nonatomic) float progress;
@property (nonatomic,retain)  MJPhotoProgressView *progressView;
- (void)showLoading;
- (void)showFailure;
@end