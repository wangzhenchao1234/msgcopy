//
//  LimbEditController.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/2.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "LimbEditController.h"
#import <VPImageCropper/VPImageCropperViewController.h>

#define ORIGINAL_MAX_WIDTH 320.0f

@interface LimbEditController ()<VPImageCropperDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>
{
    NSInteger iconIndex;
    NSData *nordata;
    NSData *seldata;
    IconEntity *ico;
}
@property (weak, nonatomic) IBOutlet UITableViewCell *contentCell;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIButton *iconView;
@property (weak, nonatomic) IBOutlet UIButton *selectedIconView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation LimbEditController

- ( void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"分类管理";
    [_iconView setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    [_selectedIconView setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    if ([_type integerValue] == EditeType) {
        
        _titleField.text = _limb.title;
        if (_limb.icon.normal_icon) {
            [_iconView sd_setImageWithURL:CRURL(_limb.icon.normal_icon) forState:UIControlStateNormal];
        }
        if (_limb.icon.selected_icon) {
            [_selectedIconView sd_setImageWithURL:CRURL(_limb.icon.selected_icon) forState:UIControlStateNormal];
        }
        _contentTextView.text = _limb.descr;
        
    }
    _iconView.layer.cornerRadius = 7;
    _iconView.clipsToBounds = true;
    _iconView.layer.borderWidth = 1;
    _iconView.layer.borderColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:.5].CGColor;
    
    _selectedIconView.layer.cornerRadius = 7;
    _selectedIconView.clipsToBounds = true;
    _selectedIconView.layer.borderWidth = 1;
    _selectedIconView.layer.borderColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:.5].CGColor;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self setRightButton];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)setThumbnail:(UIButton*)sender {
    
    [_titleField resignFirstResponder];
    [_contentTextView resignFirstResponder];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"拍照", nil];
    sheet.tag = sender.tag;
    [sheet showInView:AppWindow];
}


-(void)setRightButton{
    
    UIButton *edite = [UIButton buttonWithType:UIButtonTypeCustom];
    edite.frame = CGRectMake(0, 0, 27, 27);
    edite.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [edite setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
    [edite addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:edite];
    self.navigationItem.rightBarButtonItem = item;
}
-(void)done:(id)sender{
    
    [_titleField resignFirstResponder];
    [_contentTextView resignFirstResponder];
    if ([_titleField.text length]==0) {
        [CustomToast showMessageOnWindow:@"请输入标题"];
        return;
    }
    [MBProgressHUD hideAllHUDsForView:AppWindow animated:true];

    if ([_type integerValue] == AddType) {
        
        /*
         title:频道标题
         descr:频道描述（可选）
         idx:手工排序（数字大的排序靠前）
         app:应用id
         icon:图标（Icon）（可选）
         placeholder:占位图（PlaceholderImage）（可选）
         ctype:内容类型，如：
         */
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params addEntriesFromDictionary:@{@"title":_titleField.text}];
        if ([_contentTextView.text length]) {
            [params addEntriesFromDictionary:@{@"descr":_contentTextView.text}];
        }
        [params addEntriesFromDictionary:@{@"shopstore":CRString(@"%d",_shop.sid)}];
        [params addEntriesFromDictionary:@{@"app":CRString(@"%d",kCurApp.aid)}];

        [MSGRequestManager Post:kAPICreateLimb params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
            LimbEntity *limb = [LimbEntity buildInstanceByJson:data];
            _limb = limb;
            if (nordata&&seldata) {
                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
                NSString *urlString = [NSString stringWithFormat:@"%@app/icon/", URL_API];
                NSString *UUID1 = CRUUIDString();
                NSString *UUID2 = CRUUIDString();
                MKNetworkOperation *op              = [engine operationWithURLString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:nil httpMethod:@"POST"];
                [op addData:nordata forKey:@"normal_icon" mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"%@.jpg",UUID1]];
                [op addData:seldata forKey:@"selected_icon" mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"%@.jpg",UUID2]];
                [op onCompletion:^(MKNetworkOperation *completedOperation) {
                    NSError *error = nil;
                    NSDictionary* jsonMedia = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:&error];
                    if ([jsonMedia respondsToSelector:@selector(objectForKey:)]) {
                        ico = [IconEntity buildInstanceByJson:jsonMedia];
                        _limb.icon = ico;
                        [MBProgressHUD showMessag:nil toView:AppWindow];
                        [MSGRequestManager MKUpdate:kAPILimbIcon(_limb.lid) params:@{@"icon":CRString(@"%d",ico.icid)} success:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
                        {
                            [MBProgressHUD hideHUDForView:AppWindow animated:false];
                            if (_callBacl) {
                                _callBacl(true,_limb);
                            }

                        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                            [MBProgressHUD hideHUDForView:AppWindow animated:false];
                            if (_callBacl) {
                                _callBacl(true,_limb);
                            }
                        }];
                    }
                 
                 } onError:^(NSError *error) {
                     [MBProgressHUD hideHUDForView:AppWindow animated:false];
                     if (_callBacl) {
                         _callBacl(true,_limb);
                     }
                 }];
                [engine enqueueOperation:op];
                
            }else{
                
                [MBProgressHUD hideHUDForView:AppWindow animated:false];
                if (_callBacl) {
                    _callBacl(true,_limb);
                }

            }
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [CustomToast showMessageOnWindow:msg];
            [MBProgressHUD hideHUDForView:AppWindow animated:false];
            
        }];

        return;
    }

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params addEntriesFromDictionary:@{@"title":_titleField.text}];
    if ([_contentTextView.text length]) {
        [params addEntriesFromDictionary:@{@"descr":_contentTextView.text}];
    }
    if (nordata&&seldata) {
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
        NSString *urlString = [NSString stringWithFormat:@"%@app/icon/", URL_API];
        NSString *UUID1 = CRUUIDString();
        NSString *UUID2 = CRUUIDString();
        MKNetworkOperation *op              = [engine operationWithURLString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:nil httpMethod:@"POST"];
        [op addData:nordata forKey:@"normal_icon" mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"%@.jpg",UUID1]];
         [op addData:seldata forKey:@"selected_icon" mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"%@.jpg",UUID2]];
        [op onCompletion:^(MKNetworkOperation *completedOperation) {
            NSError *error = nil;
            NSDictionary* jsonMedia = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:&error];
            if ([jsonMedia respondsToSelector:@selector(objectForKey:)]) {
                ico = [IconEntity buildInstanceByJson:jsonMedia];
                _limb.icon = ico;
                [MBProgressHUD showMessag:nil toView:AppWindow];
                [MSGRequestManager MKUpdate:kAPILimbIcon(_limb.lid) params:@{@"icon":CRString(@"%d",ico.icid)} success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    
                    [MSGRequestManager MKUpdate:kAPIModifyLimb(_limb.lid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        _limb.title = _titleField.text;
                        _limb.descr = _contentTextView.text;
                        [MBProgressHUD hideHUDForView:AppWindow animated:false];
                        if (_callBacl) {
                            _callBacl(true,nil);
                        }

                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [MBProgressHUD hideHUDForView:AppWindow animated:false];
                        [CustomToast showMessageOnWindow:msg];

                    }];

                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [MSGRequestManager MKUpdate:kAPIModifyLimb(_limb.lid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        _limb.title = _titleField.text;
                        _limb.descr = _contentTextView.text;
                        [MBProgressHUD hideHUDForView:AppWindow animated:false];
                        if (_callBacl) {
                            _callBacl(true,nil);
                        }

                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [CustomToast showMessageOnWindow:msg];
                        [MBProgressHUD hideHUDForView:AppWindow animated:false];

                    }];
                }];
            }
            
        } onError:^(NSError *error) {
            [MBProgressHUD hideAllHUDsForView:AppWindow animated:true];
            [CustomToast showMessageOnWindow:@"上传失败"];
        }];
        [engine enqueueOperation:op];
    }else{

        [MSGRequestManager MKUpdate:kAPIModifyLimb(_limb.lid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            _limb.title = _titleField.text;
            _limb.descr = _contentTextView.text;
            [MBProgressHUD hideHUDForView:AppWindow animated:false];
            if (_callBacl) {
                _callBacl(true,nil);
            }

        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [CustomToast showMessageOnWindow:msg];
            [MBProgressHUD hideHUDForView:AppWindow animated:false];

        }];

    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 323;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return _contentCell;
}
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    iconIndex = actionSheet.tag - 100;
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
            [self presentViewController:controller
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
            [self presentViewController:controller
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
    if (iconIndex==0) {
        nordata = [[NSData alloc] initWithData:data100];
        [_iconView setImage:head100 forState:UIControlStateNormal];
    }else{
        seldata = [[NSData alloc] initWithData:data100];
        [_selectedIconView setImage:head100 forState:UIControlStateNormal];
    }
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
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
        [self presentViewController:imgEditorVC animated:YES completion:^{
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
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return false;
    }
    return true;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
