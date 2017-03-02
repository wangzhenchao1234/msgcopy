//
//  CreateContentController.m
//  msgcopy
//
//  Created by wngzc on 15/7/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "CreateContentController.h"
@class KaokeImage;


@interface CreateContentController ()
@end

@implementation CreateContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
# pragma mark - tableView

-(void)configTableView
{
    //config some
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor colorFromHexRGB:@"f8f8f8"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = (id<UITableViewDelegate>)self;
    _tableView.dataSource = (id<UITableViewDataSource>)self;
    _tableView.autoresizesSubviews = false;
    [self.view addSubview:_tableView];
    [CRKeyboardUtility startObserving];
}
# pragma mark - actions

# pragma mark - 添加表情

-(void)addEmotion:(id)sender{
    
    //do something
    if (_facialShown) {
        [self hiddenEmotionView];
        return;
    }
    if (!_facialView) {
        _facialView = [[FacialPanView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 0) target:self];
        [self.view addSubview:_facialView];
    }
    _facialShown = true;
    CRKeyboardHide();
    [UIView animateWithDuration:.23 animations:^{
        _facialView.y = self.view.height - _facialView.height;
    }];
    [self adjustToolBar];
    
}
-(void)hiddenEmotionView{
    
    _facialShown = false;
    [UIView animateWithDuration:.23 animations:^{
        _facialView.y = self.view.height;
    }];
    [self adjustToolBar];
    
}
# pragma mark - 添加图片

-(void)addImage:(id)sender{
    //do something
    if (_attaches.count>=9) {
        [CustomToast showMessageOnWindow:@"最多支持添加9个附件"];
        return;
    }
    UIActionSheet *imageAction = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选取照片" otherButtonTitles:@"拍照", nil];
    imageAction.tag = ImageSheetTag;
    [imageAction showInView:self.view];
    
}

# pragma mark - 添加视频

-(void)addVideo:(id)sender{
    //do something
    if (_attaches.count>=9) {
        [CustomToast showMessageOnWindow:@"最多支持添加9个附件"];
        return;
    }
    UIActionSheet *imageAction = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选取视频" otherButtonTitles:@"录制", nil];
    imageAction.tag = VideoSheetTag;
    [imageAction showInView:self.view];
    
}

# pragma mark - 调整toolBar位置

-(void)adjustToolBar{
    //do something
    CGFloat y = self.view.height;
    
    if(_facialShown){
        y = _facialView.height;
    }else{
        y = [CRKeyboardUtility keyboardFrame].size.height;
    }
    [UIView animateWithDuration:.23 animations:^{
        _toolBar.y = self.view.height - y - _toolBar.height;
    }];
}


# pragma mark - actionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        return;
    }
    if (actionSheet.tag == ImageSheetTag) {
        
        if (buttonIndex == 0) {
            [self openPhotoAllbum:nil];
        }else if(buttonIndex == 1){
            [self openPhotoCamera:nil];
        }
    }else if (actionSheet.tag == VideoSheetTag){
        if (buttonIndex == 0) {
            [self openVideoAllbum:nil];
        }else if(buttonIndex == 1){
            [self openVideoCamera:nil];
        }
    }else if(actionSheet.tag == 3){
        
        //                NSString *voicePath = [[self getFileDir] stringByAppendingPathComponent:@"MySound.caf"];
        //                [voiceHud startForFilePath:voicePath];
    }
}

# pragma mark - 打开相册

-(void)openPhotoAllbum:(id)sender{
    //do something
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate  = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];

}
# pragma mark - 打开相机照片

-(void)openPhotoCamera:(id)sender{
    //do something
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate  = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}
# pragma mark - 打开视频相册

-(void)openVideoAllbum:(id)sender{
    //do something
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate  = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    picker.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    [self presentViewController:picker animated:YES completion:nil];
}
# pragma mark - 打开相机照片

-(void)openVideoCamera:(id)sender{
    //do something
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate  = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    [self presentViewController:picker animated:YES completion:nil];
}


# pragma mark - PickerDelegate
//相册代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        
        NSString* fileName = [self createImageFileName];
        NSString *jpgPath = [[self getFileDir] stringByAppendingPathComponent:fileName];
        UIImage* image = [info valueForKey:UIImagePickerControllerOriginalImage];
        UIImage *newImage = nil;
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            NSDictionary *imageMetadata = [info objectForKey:
                                           UIImagePickerControllerMediaMetadata];
            NSInteger oritation = [[imageMetadata valueForKeyPath:@"Orientation"] integerValue];
            UIImage *oImage = [UIImage thumbImage:image];
            image = nil;
            newImage = [UIImage image:oImage rotation:oritation];
            
        }else{
            newImage = [UIImage thumbImage:image];
        }
        BOOL saveSign = [UIImageJPEGRepresentation(newImage, 1.0) writeToFile:jpgPath atomically:NO];
        if(saveSign)
        {
            NSDictionary *dict = @{@"name": fileName,@"type":@"image"};
            [_attaches addObject:dict];
//            KaokeImage * image = [[KaokeImage alloc] init];
//            image.otitle = fileName;
//            image.isAdd = YES;
            //更新附件列表
            [self updateMediaView:_attaches];
//            NSLog(@"编辑页面父类中的attaches - %@",_attaches);
            newImage = nil;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([mediaType isEqualToString:@"public.movie"]){
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        [self convertToMp4:videoURL];
    }
}
-(void)convertToMp4:(NSURL*)_videoURL{
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:_videoURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality])
        
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetMediumQuality];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        NSString *fileName = [self createrMp4FileName];
        NSString *_mp4Path = [[self getFileDir] stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:_mp4Path error:nil];
        exportSession.outputURL = [NSURL fileURLWithPath:_mp4Path];
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"错误!"
                                                                    message:[[exportSession error] localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles: nil];
                    [alert show];
                    
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    break;
                case AVAssetExportSessionStatusCompleted:{
                    MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:_videoURL];
                    UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
                    UIImage *newThumbnail = [UIImage thumbImage:thumbnail];
                    NSString *tName = [self createImageFileName];
                    if (newThumbnail) {
                        NSString *filePath = CRUploadFilePath(tName);
                        BOOL saveSign = [UIImageJPEGRepresentation(newThumbnail, 1.0) writeToFile:filePath atomically:NO];
                        if (!saveSign) {
                            [CustomToast showMessageOnWindow:@"获取缩略图失败"];
                        }
                    }else{
                        [CustomToast showMessageOnWindow:@"获取缩略图失败"];
                    }
                    [self performSelectorOnMainThread:@selector(convertFinish:) withObject:@[fileName,tName] waitUntilDone:NO];
                    [player stop];
                    
                }
                    break;
                default:
                    break;
            }
        }];
        
    }
    else
    {
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)convertFinish:(id)datas{
    NSString *fileName = datas[0];
    NSString *thumbnail = datas[1];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:fileName forKey:@"name"];
    [dict setObject:@"video" forKey:@"type"];
    [dict setObject:thumbnail forKey:@"thumbnail"];
    [_attaches addObject:dict];
    //更新附件列表
    [self updateMediaView:_attaches];
    thumbnail = nil;
    
}
-(void)updateMediaView:(NSArray*)attachs
{
    

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


# pragma mark - fileManager

# pragma mark - 创建文件名
-(NSString*) createImageFileName
{
    NSString* name = [NSString stringWithFormat:@"%@.jpg", CRUUIDString()];
    return name;
}
-(NSString*) createrMp4FileName
{
    NSString* name = [NSString stringWithFormat:@"%@.mp4", CRUUIDString()];
    return name;
}
# pragma mark -  创建文件名
-(NSString*) getFileDir
{
    return CRUploadDirectoryPath();
}

@end
