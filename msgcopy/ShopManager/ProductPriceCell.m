//
//  ProductPriceCell.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/11.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "ProductPriceCell.h"
#import "ProductController.h"

#define ORIGINAL_MAX_WIDTH 320.0f


@implementation ProductPriceCell

- (void)awakeFromNib {
    // Initialization code
    _curPrice.placeholderStr = @"请输入当前价格";
    _prePrice.placeholderStr = @"请输入原价";
    
    _mainView.layer.cornerRadius = 5;
    _mainView.layer.borderWidth = 1;
    _mainView.layer.borderColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1].CGColor;
    _mainView.backgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1];
    _imageButton.layer.cornerRadius = 5;
    _imageButton.layer.borderWidth = 1;
    _imageButton.layer.borderColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1].CGColor;
    _imageButton.backgroundColor = CRCOLOR_CLEAR;
}
-(void)load:(NSString*)price pre:(NSString*)prePrice thumbnail:(NSString*)url
{
    _curPrice.placeholderStr = @"请输入当前价格";
    _prePrice.placeholderStr = @"请输入原价";
    _curPrice.text = price?price:@"";
    _prePrice.text = prePrice?prePrice:@"";
    if (url) {
        [_imageButton sd_setImageWithURL:CRURL(url) forState:UIControlStateNormal];
    }else{
        [_imageButton setImage:[UIImage imageNamed:@"corss"] forState:UIControlStateNormal];
    }
    
}
- (IBAction)setImage:(id)sender {
    [_curPrice resignFirstResponder];
    [_prePrice resignFirstResponder];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"拍照", nil];
    [sheet showInView:AppWindow];
}
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [CRController(self) presentViewController:controller
                                             animated:YES
                                           completion:^(void){
                                           }];
            controller = nil;
        }
        
    } else if (buttonIndex == 0) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [CRController(self) presentViewController:controller
                                             animated:YES
                                           completion:^(void){
                                           }];
            controller = nil;
        }
    }
}
#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    UIImage *head100 = [self imageByScalingAndCroppingForSourceImage:editedImage targetSize:CGSizeMake(100, 100)];
    NSData *data100 = UIImagePNGRepresentation(head100);
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        [MBProgressHUD showMessag:nil toView:AppWindow];
        [UploadManager createArticleThumnail:data100 success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
            _priceData.thumbnail = data;
            [_imageButton sd_setImageWithURL:CRURL(_priceData.thumbnail.turl) forState:UIControlStateNormal];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            _priceData.thumbnail = nil;
            [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
            NSLog(@"创建收藏缩略图失败");
        }];
    }];
}
- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController
{
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, AppWindow.width, AppWindow.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [CRController(self) presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility

- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (BOOL)textView:(ProductTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  
    if ([text isEqualToString:@"\n"]) {
        
        if (textView == _curPrice) {
            [textView resignFirstResponder];
            while (textView.isFirstResponder) {
                
            }
            [_prePrice becomeFirstResponder];
        }else {
            [textView resignFirstResponder];
        }
        return false;
    }
    return true;
}
-(void)textViewDidChange:(ProductTextView *)textView
{
    if (textView == _curPrice) {
        _priceData.curPrice = textView.text;
    }else if (textView == _prePrice) {
        _priceData.prePrice = textView.text;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
