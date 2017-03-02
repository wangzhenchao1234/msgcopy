//
//  ProductBannerCell.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/6.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "ProductBannerCell.h"
#import <VPImageCropper/VPImageCropperViewController.h>
#import "BannerCollectionCell.h"

#define ORIGINAL_MAX_WIDTH 320.0f


@interface ProductBannerCell()<VPImageCropperDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,BannerCollectionCellDelegate>

@end

@implementation ProductBannerCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];

}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}
-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        return  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat size = floor((AppWindow.width-70)/5);
    return CGSizeMake(size,size);
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_datas.count<5) {
        return _datas.count+1;
    }
    return _datas.count;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BannerCollectionCell *cell = (BannerCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    KaokeImage *image = CRArrayObject(_datas, indexPath.row);
    UIImageView *thumbnail = cell.imageView;
     if (image) {
         cell.delegate = (id<BannerCollectionCellDelegate>)self;
         cell.indexPath = indexPath;
        [thumbnail sd_setImageWithURL:CRURL(image.ourl)];
         cell.deleteButton.hidden = false;
    }else{
        cell.delegate = nil;
        cell.indexPath = nil;
        [thumbnail setImage:[UIImage imageNamed:@"cross"]];
        cell.deleteButton.hidden = true;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    if (_datas.count == 0||(_datas.count<5&&indexPath.row == _datas.count)) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"拍照", nil];
        [sheet showInView:AppWindow];
        return;
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
            NSError *error = nil;
            NSDictionary* jsonMedia = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:&error];
            if ([jsonMedia respondsToSelector:@selector(objectForKey:)]) {
                
                MediaEntity* media = [MediaEntity buildInstanceByJson:jsonMedia];
                media.fType = extension;
                [UploadManager createArticleMedia:media.mid descr:@" " fType:@"image" thumnail:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [MBProgressHUD hideAllHUDsForView:AppWindow animated:true];
                    ArticleMediaEntity *aMedia = data;
                    KaokeImage *image = [[KaokeImage alloc] init];
                    image.oid = aMedia.aid;
                    image.ourl = aMedia.url;
                    image.descr = aMedia.descr;
                    image.isAdd = true;
                    [_datas addObject:image];
                    [_addDatas addObject:image];
                    [_collectionView reloadData];
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [MBProgressHUD hideAllHUDsForView:AppWindow animated:true];
                    [CustomToast showMessageOnWindow:@"上传失败"];
                }];
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
-(void)deleteItemAtIndex:(NSIndexPath *)index
{
    KaokeImage *image = [_datas objectAtIndex:index.row];
    if (!image.isAdd) {
        [_deleteDatas addObject:image];
    }else{
        [_addDatas removeObject:image];
    }
    [_datas removeObjectAtIndex:index.row];
    [_collectionView reloadData];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
