//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoToolbar.h"
#import "MJPhoto.h"

@interface MJPhotoToolbar()
{
    UILabel *titleLabel;
    UILabel *descrText;
    UIImageView *bgView;
    UIButton *_saveImageBtn;
}
@end

@implementation MJPhotoToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *image = [[UIImage imageNamed:@"toolbarBKG"] stretchableImageWithLeftCapWidth:0 topCapHeight:10];
        bgView = [[UIImageView alloc] initWithImage:image];
        bgView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 110);
        descrText = [[UILabel alloc] init];
        descrText.textColor = [UIColor whiteColor];
        descrText.backgroundColor = [UIColor clearColor];
        descrText.font = [UIFont systemFontOfSize:12];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, 15)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:bgView];
        [self addSubview:titleLabel];
        [self addSubview:descrText];
    }
    return self;
}
-(void)setSaveButtonEnable:(BOOL)enable{
    if (enable) {
        _saveImageBtn.enabled = YES;
        return;
    }
    _saveImageBtn.enabled = NO;
}
- (void)setTitles:(NSArray *)titles
{
    
    _titles = titles;
    
    
}
-(void)setDescrs:(NSArray *)descrs{
    
    
    _descrs = descrs;
    
    
}
- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    CGFloat btnWidth = 44;
    _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveImageBtn.frame = CGRectMake(self.frame.size.width - btnWidth, self.frame.size.height - btnWidth, btnWidth, btnWidth);
    _saveImageBtn.enabled =NO;
    _saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon"] forState:UIControlStateNormal];
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon"] forState:UIControlStateHighlighted];
    [_saveImageBtn setImage:[UIImage imageNamed:@"photo-gallery-trashcan.png"] forState:UIControlStateHighlighted];
    [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveImageBtn];
    
}
- (void)saveImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MJPhoto *photo = _photos[_currentPhotoIndex];
        UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [MBProgressHUD showSuccess:@"保存失败" toView:nil];
    } else {
        [MBProgressHUD showSuccess:@"成功保存到相册" toView:nil];
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    titleLabel.text = _titles[currentPhotoIndex];
    descrText.text = _descrs[currentPhotoIndex];
    descrText.numberOfLines = 0;
    CGRect descrFrame = self.frame;
    descrFrame.origin.y = titleLabel.frame.origin.y + titleLabel.frame.size.height;
    descrFrame.origin.x = titleLabel.frame.origin.x;
    descrFrame.size.width = titleLabel.frame.size.width;
    CGSize dsize  = [descrText.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(self.frame.size.width - 10, self.frame.size.height-40)];
    descrFrame.size.height = dsize.height;
    descrText.frame = descrFrame;
}

@end
