//
//  ProductCell.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/6.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import "ProductCell.h"
#import "ProductController.h"

#define ORIGINAL_MAX_WIDTH 320.0f
@implementation ProductCell

- (void)awakeFromNib {
    // Initialization code
    _mainView.layer.cornerRadius = 5;
    _mainView.layer.borderWidth = 1;
    _mainView.layer.borderColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1].CGColor;
    _mainView.backgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1];

}
- (IBAction)setImage:(id)sender {
    
    [_titleTextView resignFirstResponder];
    [_priceTextView resignFirstResponder];
    [_remainTextView resignFirstResponder];
    [_descrTextView resignFirstResponder];

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"拍照", nil];
    [sheet showInView:AppWindow];
}
- (IBAction)deleteProduct:(id)sender {
    if ([_delegate respondsToSelector:@selector(deleteItem:)]) {
        [_delegate deleteItem:_indexPath];
    }
}
-(void)loadProduct:(ProductEntity *)product
{
    _titleTextView.placeholderStr = @"商品名称";
    _priceTextView.placeholderStr = @"商品价格";
    _remainTextView.placeholderStr = @"商品库存";
    _descrTextView.placeholderStr = @"描述";
    curProduct = product;
    _titleTextView.text = product.title;
    _priceTextView.text = product.price?product.price:@"";
    _remainTextView.text  = product.stock?product.stock:@"";
    _descrTextView.text = product.descr;
    if ([product.img_url length]>0) {
        [_imageButton sd_setImageWithURL:CRURL(product.img_url) forState:UIControlStateNormal];
    }
    
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
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
        NSString *urlString = [NSString stringWithFormat:@"%@media/", URL_API];
        NSString *extension = @"jpg";
        NSData *data = nil;
        NSString *type = @"image";
        data = data100;
        NSString *UUID = CRUUIDString();
        NSMutableDictionary *params         = [NSMutableDictionary dictionaryWithObjectsAndKeys:UUID,@"title",type,@"ftype",@"iphone",@"source",nil];
        MKNetworkOperation *op              = [engine operationWithURLString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:params httpMethod:@"POST"];
        [op addData:data forKey:@"imgFile" mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"%@.%@",UUID,extension]];
        [op onCompletion:^(MKNetworkOperation *completedOperation) {
            NSLog(@"uploadcomplete");
            [MBProgressHUD hideAllHUDsForView:AppWindow animated:true];
            NSError *error = nil;
            NSDictionary* jsonMedia = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:&error];
            if ([jsonMedia respondsToSelector:@selector(objectForKey:)]) {
                MediaEntity* media = [MediaEntity buildInstanceByJson:jsonMedia];
                curProduct.img_url = media.url;
                [_imageButton sd_setImageWithURL:CRURL(media.url) forState:UIControlStateNormal];
            }
            
        } onError:^(NSError *error) {
            [MBProgressHUD hideAllHUDsForView:AppWindow animated:true];
            [CustomToast showMessageOnWindow:@"上传失败"];
        }];
        [engine enqueueOperation:op];
        
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
    if (textView == _titleTextView) {
        curProduct.title = textView.text;
    }else if (textView == _priceTextView) {
        curProduct.price = textView.text;
    }else if (textView == _remainTextView) {
        curProduct.stock = textView.text;
    }else if (textView == _descrTextView) {
        curProduct.descr = textView.text;
    }
    if ([text isEqualToString:@"\n"]) {
        
        if (textView == _titleTextView) {
            [textView resignFirstResponder];
            while (textView.isFirstResponder) {
                
            }
            [_priceTextView becomeFirstResponder];
        }else  if (textView == _priceTextView) {
            [textView resignFirstResponder];
            while (textView.isFirstResponder) {
                
            }
            [_remainTextView becomeFirstResponder];
        } else  if (textView == _remainTextView) {
            [textView resignFirstResponder];
            while (textView.isFirstResponder) {
                
            }
            [_descrTextView becomeFirstResponder];
        }else{
            [textView resignFirstResponder];
        }
        return false;
    }
    return true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
