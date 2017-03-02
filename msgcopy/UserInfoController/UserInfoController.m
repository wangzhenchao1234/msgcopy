//
//  UserInfoController.m
//  msgcopy
//
//  Created by Gavin on 15/6/19.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "UserInfoController.h"
#import <VPImageCropper/VPImageCropperViewController.h>
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "UserHeadEntity.h"
#import "ChangeMoodController.h"
#import "ChangeSexController.h"
#import "ChangeNickController.h"
#import "CustomDatePicker.h"
#import "CustomPickerView.h"
#import "ChangePhoneController.h"
#import "VerifyEmailController.h"
#import "QQOauth.h"
#import "SinaOauthController.h"
#import "WeiChatOauth.h"
#import "ResetUserController.h"
#import "BindEmailController.h"
#import "UserQRView.h"

#define ORIGINAL_MAX_WIDTH 320.0f

static NSString *CellIdentifire = @"UserInfoCell";

@interface UserInfoController ()<VPImageCropperDelegate,CustomDatePickerDelegate,CustomPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    CustomDatePicker *_datePicker;
    CustomPickerView *_provPicker;
    NSDateFormatter *_dateFormatter;
}
@property(nonatomic,retain) NSArray *countSettings;
@property(nonatomic,retain)NSArray *profileSettings;
@property(nonatomic,retain)NSMutableArray *bindsSettings;

@end

@implementation UserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configNavigationItem];
    self.title = @"个人中心";
    [self loadUserInfo:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [self.tableView reloadData];

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self intilizedDataSource];
    
}
-(void)configNavigationItem
{
    //config some
    UIButton *qrButton = [UIButton buttonWithType:UIButtonTypeCustom];
    qrButton.frame = CGRectMake(0, 0, 27, 27);
    qrButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [qrButton setImage:[UIImage imageNamed:@"user_qr"] forState:UIControlStateNormal];
    [qrButton addTarget:self action:@selector(showUserQR:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:qrButton];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)intilizedDataSource{
    //intilizedDataSource
    
    _countSettings = @[@[@"修改头像"],@[kCurUser.head50?kCurUser.head50:@""]];

    _profileSettings = @[@[@"昵称",kCurUser.firstName],@[@"签名",kCurUser.mood?kCurUser.mood:@""],@[@"性别",kCurUser.gender==true?@"男":@"女"],@[@"生日",kCurUser.birthday?kCurUser.birthday:@""],@[@"地区",kCurUser.city?kCurUser.city:@""]];
    
    _bindsSettings = [[NSMutableArray alloc] initWithCapacity:2];
    [_bindsSettings addObject:@"手机"];
    if ([AppDataManager sharedManager].registerType != RegegistTypePhone) {
        [_bindsSettings addObject:@"邮箱"];
    }
    if (![AppKey_Sina isEqualToString:@"null"]&&AppKey_Sina.length > 0) {
        [_bindsSettings addObject:@"微博"];
    }
    if (![QQAPP_ID isEqualToString:@"null"]&&QQAPP_ID.length>0) {
        [_bindsSettings addObject:@"QQ"];
    }
    if (![WXAppID isEqualToString:@"null"]&&![WXAppSecret isEqualToString:@"null"]) {
        [_bindsSettings addObject:@"微信"];
    }
    [self.tableView reloadData];
}

# pragma mark - 加载用户信息

-(void)loadUserInfo:(id)sender{
    //do something
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    [AppWindow addSubview:hud];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
    CRWeekRef(self);
    [[UserDataManager sharedManager] userInfoSuccess:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        if (CRJSONIsDictionary(data)) {
            [kCurUser buildProfileByJson:data];
        }
        [__self intilizedDataSource];
        
        
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return _profileSettings.count;
            break;
        case 2:
            return _bindsSettings.count;
            break;
        default:return 1;
            break;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 54;
    }
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *loginOut = @"LoginOut";
    if (indexPath.section == 3) {
        // 退出登录
        cell = [tableView dequeueReusableCellWithIdentifier:loginOut forIndexPath:indexPath];
        return cell;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire forIndexPath:indexPath];
    }
    NSArray *titles = nil;
    cell.imageView.image = nil;
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    switch (indexPath.section) {
        case 0:
        {
            UIImage *dfImage = [UIImage imageByScalingImage:UserPlaceImage toSize:CGSizeMake(44, 44)];
            cell.imageView.image = dfImage;
            UIImage *cachImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:kCurUser.head100];
            if (!cachImage) {
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(kCurUser.head100) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if (image&&finished) {
                        [cell.imageView setImage:[UIImage imageByScalingImage:image toSize:CGSizeMake(44, 44)]];
                        [[SDImageCache sharedImageCache] storeImage:image forKey:kCurUser.head100];
                    }
                }];
            }else{
                UIImage *newImage = [UIImage imageByScalingImage:cachImage toSize:CGSizeMake(44, 44)];
                [cell.imageView setImage:newImage];
            }
            titles = CRArrayObject(_countSettings, 0);
            cell.imageView.layer.cornerRadius = 22;
            cell.imageView.clipsToBounds = true;
            cell.textLabel.text = CRArrayObject(titles, 0);
        }
            break;
        case 1:{
            titles = CRArrayObject(_profileSettings, indexPath.row);
            cell.textLabel.text = CRArrayObject(titles, 0);
            cell.detailTextLabel.text = CRArrayObject(titles, 1);
        }
            break;
        case 2:{
            titles = _bindsSettings;
            cell.textLabel.text = CRArrayObject(_bindsSettings, indexPath.row);
        }
            break;
            
        default:
            break;
    }
    cell.textLabel.font = MSGFont(13);
    cell.textLabel.textColor = [UIColor colorFromHexRGB:@"4d4d4d"];
    cell.detailTextLabel.font = MSGFont(13);
    if (indexPath.section == 2) {
        
        NSString *title = CRArrayObject(titles, indexPath.row);
        if ([title isEqualToString:@"手机"]) {
            NSLog(@"%@",kCurUser.lastName);
            if (kCurUser.lastName&&kCurUser.lastName.length == 11) {
                cell.detailTextLabel.text = [kCurUser.lastName stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
            }else{
                cell.detailTextLabel.text = @"未绑定";
            }
        }else if ([title isEqualToString:@"邮箱"]){
            if (!kCurUser.email||kCurUser.email.length==0){
                cell.detailTextLabel.text = @"未绑定";
            }else if([kCurUser.email isEqualToString:@"m@m.mm"]){
                cell.detailTextLabel.text = @"待激活";
            }else{
                cell.detailTextLabel.text = @"已绑定";
            }
            
        }else if ([title isEqualToString:@"QQ"]){
            
            if (!kCurUser.qq_openid||kCurUser.qq_openid.length == 0) {
                cell.detailTextLabel.text = @"未绑定";
            }else{
                cell.detailTextLabel.text = @"已绑定";
            }
            
        }else if ([title isEqualToString:@"微信"]){
            
            if (!kCurUser.wx_openid||kCurUser.wx_openid.length == 0) {
                cell.detailTextLabel.text = @"未绑定";
            }else{
                cell.detailTextLabel.text = @"已绑定";
            }
            
        }else if ([title isEqualToString:@"微博"]){
            if (!kCurUser.sina_uid||kCurUser.sina_uid.length == 0) {
                cell.detailTextLabel.text = @"未绑定";
            }else{
                cell.detailTextLabel.text = @"已绑定";
            }
            
        }
    }
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSArray *sectionItem = nil;
    NSString *title = nil;
    switch (indexPath.section) {
        case 0:
            [self changeHeadeImage:nil];
            return;
            break;
        case 1:{
            sectionItem = _profileSettings;
            NSArray *titles = CRArrayObject(sectionItem, indexPath.row);
            title = CRArrayObject(titles, 0);
        }
            break;
        case 2:
        {
            title = CRArrayObject(_bindsSettings, indexPath.row);
        }
            break;
        case 3:
            [self loginOut:nil];
            return;
            break;
        default:
            break;
    }
    
    if ([title isEqualToString:@"昵称"]) {
        //修改昵称
        [self modifyNickName:nil];
    }else if([title isEqualToString:@"签名"]){
        //修改签名
        [self modifyMood:nil];
    }else if([title isEqualToString:@"性别"]){
        //修改性别
        [self modifySex:nil];
    }else if([title isEqualToString:@"生日"]){
        //修改生日
        [self modifyBirthDay:nil];
        
    }else if([title isEqualToString:@"地区"]){
        //修改地区
        [self modifyLocation:nil];
        
    }else if([title isEqualToString:@"手机"]){
        //绑定手机号
        [self bindPhone:nil];
        
    }else if([title isEqualToString:@"邮箱"]){
        //绑定邮箱
        [self bindEmail:nil];
        
    }else if([title isEqualToString:@"微博"]){
        //绑定微博
        [self bindWeiBo:nil];
        
    }else if([title isEqualToString:@"微信"]){
        //绑定微信
        [self bindWeiXin:nil];
        
    }else if([title isEqualToString:@"QQ"]){
        //绑定QQ
        [self bindQQ:nil];
        
    }
    
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    return [[MWPhoto alloc] initWithURL:CRURL(kCurUser.head320)];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return [[MWPhoto alloc] initWithURL:CRURL(kCurUser.head50)];
}

# pragma mark - 修改头像

-(void)changeHeadeImage:(id)sender{
    //do something
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看头像",@"从相册选择",@"拍照", nil];
    [sheet showInView:self.view];
    
}
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0){
        [self showUserHead:nil];
    }
    if (buttonIndex == 2) {
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
        
    } else if (buttonIndex == 1) {
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

# pragma mark - 显示用户二维码
/**
 *  显示用户二维码
 */
-(void)showUserQR:(id)sender
{
    [UserQRView showWithQRURL:kCurUser.qrpath];
}

# pragma mark - 查看头像

-(void)showUserHead:(id)sender
{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:(id<MWPhotoBrowserDelegate>)self];
    browser.displayActionButton = false;
    browser.displayNavArrows = true;
    browser.displaySelectionButtons = false;
    browser.alwaysShowControls = false;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = false;
    browser.startOnGrid = false;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:nc animated:true completion:^{
    }];
}

# pragma mark - 修改昵称

-(void)modifyNickName:(id)sender{
    //do something
    
    ChangeNickController *user = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ChangeNickController"];
    [self.navigationController pushViewController:user animated:true];
    
}
# pragma mark - 修改心情

-(void)modifyMood:(id)sender{
    //do something
    ChangeMoodController *mood = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ChangeMoodController"];
    [self.navigationController pushViewController:mood animated:true];
    
}
# pragma mark - 修改性别

-(void)modifySex:(id)sender{
    //do something
    ChangeSexController *sex = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ChangeSexController"];
    [self.navigationController pushViewController:sex animated:true];
    
}
# pragma mark - 修改位置

-(void)modifyLocation:(id)sender{
    //do something
    if (!_provPicker) {
        _provPicker = [CustomPickerView sharedPicker];
    }
    _provPicker.delegate = self;
    [_provPicker show];
}
# pragma mark - LocationPickDelegate

-(void)changePickerSubmite:(NSArray *)data{
    
    NSString *province = CRArrayObject(data, 0);
    NSString *currentCity = CRArrayObject(data, 1);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [AppWindow addSubview:hud];
    [hud show:true];
    CRWeekRef(self);
    [kCurUser changeAttr:@"prov" value:province success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        kCurUser.prov = province;
        [kCurUser changeAttr:@"city" value:currentCity success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            kCurUser.city = currentCity;
            [__self intilizedDataSource];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            [CustomToast showMessageOnWindow:msg];
            [__self intilizedDataSource];
        }];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}


# pragma mark - 修改生日

-(void)modifyBirthDay:(id)sender{
    //do something
    if (!_datePicker) {
        _datePicker = [CustomDatePicker sharedPicker];
    }
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    _datePicker.delegate = self;
    if (kCurUser.birthday) {
        _datePicker.datePicker.date = [_dateFormatter dateFromString:kCurUser.birthday];
    }
    [_datePicker show];
    
}
# pragma mark - DatePickerDelegate
-(void)changeDateSubmite:(NSDate *)date{
    
    NSString *birthDay = [_dateFormatter stringFromDate:date];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [AppWindow addSubview:hud];
    [hud show:true];
    CRWeekRef(self);
    [kCurUser changeAttr:@"birthday" value:birthDay success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
        [hud hide:true];
        kCurUser.birthday = birthDay;
        [__self intilizedDataSource];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
    }];
    
}

# pragma mark - 绑定微信

-(void)bindWeiXin:(id)sender{
    //do something
    CRWeekRef(self);
    
    
    if ([kCurUser.wx_openid length] == 0) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [AppWindow addSubview:hud];
        [hud show:true];
        [WeiChatOauth doBindWeiChat:^(BOOL result, id data) {
            [hud hide:true];
            NSLog(@" ---------------------%@",result?@"是":@"不是");
            if (result) {
                kCurUser.wx_openid = data;
                NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
                [userInfo setObject:data forKey:@"wx_openid"];
                [__self intilizedDataSource];
            }else{
                [CustomToast showMessageOnWindow:data];
            }
        }];
        
    }else{
        
//        NSLog(@"绑定微信失败！！！！！！！！！！！！");
        
//        if ([kCurUser.qq_openid length]==0&&[kCurUser.sina_uid length]==0&&[kCurUser.userName rangeOfString:@"@"].location!=NSNotFound) {
//            [ResetUserController showWithDebind:ThirdDebindTypeWX target:self complete:^(BOOL result, id data) {
//                if (result) {
//                    kCurUser.wx_openid = nil;
//                    NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
//                    [userInfo setObject:@"" forKey:@"wx_openid"];
//                    [__self.navigationController popViewControllerAnimated:true];
//                }else{
//                    [CustomToast showMessageOnWindow:data];
//                }
//            }];
//            
//            
//        }else{
        /**
         *  2015年8月31日 修改流程 卢迪
         *
         */

            [GVConfirmView showConfirm:@"确定解绑" inView:self.view confirmButton:@"解绑" action:^{
                
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                hud.removeFromSuperViewOnHide = true;
                [AppWindow addSubview:hud];
                [hud show:true];
                CRWeekRef(self);
                [OauthManager deBindWxPlt:kCurUser.wx_openid success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    kCurUser.wx_openid = nil;
                    NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
                    [userInfo setObject:@"" forKey:@"wx_openid"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"openID"];
                    [__self intilizedDataSource];
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    [CustomToast showMessageOnWindow:msg];
                }];
                
            } cancelTitle:@"取消" action:^{
                
            }];
        }
//    }
}

# pragma mark - 绑定微博

-(void)bindWeiBo:(id)sender{
    //do something
    CRWeekRef(self);
    if ([kCurUser.sina_uid length] == 0) {
        [SinaOauthController doOauth:^(BOOL result, id data, NSString *msg) {
            if (result) {
                //sinas授权成功
                __block NSString *uid = data[@"uid"];
                MBProgressHUD *hudView = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                hudView.removeFromSuperViewOnHide = true;
                [AppWindow addSubview:hudView];
                [hudView show:true];
                [OauthManager bindSinaPlt:uid success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hudView hide:true];
                    kCurUser.sina_uid = uid;
                    NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
                    [userInfo setObject:uid forKey:@"uid"];
                    [__self intilizedDataSource];
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hudView hide:true];
                    [CustomToast showMessageOnWindow:msg];
                }];
            }else{
                [CustomToast showMessageOnWindow:msg];return;
            }
        } target:self];
    }else{
        
//        if ([kCurUser.qq_openid length]==0&&[kCurUser.wx_openid length]==0&&[kCurUser.userName rangeOfString:@"@"].location!=NSNotFound) {
//            [ResetUserController showWithDebind:ThirdDebindTypeSina target:self complete:^(BOOL result, id data) {
//                if (result) {
//                    kCurUser.sina_uid = nil;
//                    NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
//                    [userInfo setObject:@"" forKey:@"uid"];
//                    [__self.navigationController popViewControllerAnimated:true];
//                }else{
//                    [CustomToast showMessageOnWindow:data];
//                }
//            }];
//            
//        }else{
        /**
         *  2015年8月31日 修改流程 卢迪
         *
         */

            [GVConfirmView showConfirm:@"确定解绑" inView:self.view confirmButton:@"解绑" action:^{
                
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                hud.removeFromSuperViewOnHide = true;
                [AppWindow addSubview:hud];
                [hud show:true];
                [OauthManager deBindSinaPlt:kCurUser.sina_uid success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    kCurUser.sina_uid = nil;
                    NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
                    [userInfo setObject:@"" forKey:@"uid"];
                    [__self intilizedDataSource];
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    [CustomToast showMessageOnWindow:msg];
                }];
                
            } cancelTitle:@"取消" action:^{
                
            }];
            
//        }
        
    }
}

# pragma mark - 绑定手机

-(void)bindPhone:(id)sender{
    //do something
    ChangePhoneController *phone = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ChangePhoneController"];
    if ([VerifyHanddler verifyPhone:kCurUser.lastName]) {
        phone.actionType = PHONE_ACTION_TYPE_VERYFY;
    }else{
        phone.actionType = PHONE_ACTION_TYPE_MODIFY;
    }
    [self.navigationController pushViewController:phone animated:true];
    
}
# pragma mark - 绑定邮箱

-(void)bindEmail:(id)sender{
    //do something
    if ([VerifyHanddler verifyEmail:kCurUser.email]) {
        BindEmailController *email = [Utility controllerInStoryboard:@"Main" withIdentifier:@"BindEmailController"];
        email.email = kCurUser.email;
        [self.navigationController pushViewController:email animated:true];

    }else{
        VerifyEmailController *email = [Utility controllerInStoryboard:@"Main" withIdentifier:@"VerifyEmailController"];
        email.canEdite = true;
        email.email = nil;
        [self.navigationController pushViewController:email animated:true];
    }
}

# pragma mark - 绑定QQ

-(void)bindQQ:(id)sender{
    //do something
    CRWeekRef(self);
    if ([kCurUser.qq_openid length]==0) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [AppWindow addSubview:hud];
        [hud show:true];
        [[QQOauth sharedQQOauth] doQQBindOauth:^(BOOL result, id data) {
            [hud hide:true];
            if (result) {
                kCurUser.qq_openid = data;
                NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
                [userInfo setObject:data forKey:@"qq_openid"];
                [__self intilizedDataSource];
            }else{
                [CustomToast showMessageOnWindow:data];
            }
        }];
    }else{
        /**
         *  2015年8月31日 修改流程 卢迪
         *
         */
//        if ([kCurUser.wx_openid length]==0&&[kCurUser.sina_uid length]==0&&[kCurUser.userName rangeOfString:@"@"].location!=NSNotFound) {
//            [ResetUserController showWithDebind:ThirdDebindTypeQQ target:self complete:^(BOOL result, id data) {
//                if (result) {
//                    kCurUser.qq_openid = data;
//                    NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
//                    [userInfo setObject:data forKey:@"qq_openid"];
//                    [__self.navigationController popViewControllerAnimated:true];
//                }else{
//                    [CustomToast showMessageOnWindow:data];
//                }
//                
//            }];
//            
//        }else{
        
            [GVConfirmView showConfirm:@"确定解绑" inView:self.view confirmButton:@"解绑" action:^{
                
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                hud.removeFromSuperViewOnHide = true;
                [AppWindow addSubview:hud];
                [hud show:true];
                [OauthManager deBindQQPlt:kCurUser.qq_openid success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    kCurUser.qq_openid = nil;
                    NSMutableDictionary *userInfo = [LocalManager objectForKey:kLoginUserKey];
                    [userInfo setObject:@"" forKey:@"qq_openid"];
                    [__self intilizedDataSource];
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    [CustomToast showMessageOnWindow:msg];
                }];
                
            } cancelTitle:@"取消" action:^{
                
            }];
            
//        }
        
        
    }
}
# pragma mark - 注销登录

-(void)loginOut:(id)sender{
    //do something
    CRWeekRef(self);
    [GVAlertView showAlert:@"确认退出？" message:nil confirmButton:@"退出" action:^{
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        [AppWindow addSubview:hud];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        NSDictionary *keychainUser = [UserDataManager keychainUser];
        NSLog(@"确认退出时的用户信息 --- %@",keychainUser);
        
        [[UserDataManager sharedManager] doLogin:keychainUser success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                [hud hide:true];
                CRBackgroundGCD(^{
                    [[XmppListenerManager sharedManager] disconnect];
                });
                [__self.navigationController popViewControllerAnimated:true];
                GSliderViewController *slider = (GSliderViewController*)CRRootNavigation().viewControllers[0];
                UINavigationController *rootNav = (UINavigationController*)slider.centerViewController;
                CenterController *_rootCenter = (CenterController*)rootNav.viewControllers[0];
                [_rootCenter checkPermission];
            }];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            [CustomToast showMessageOnWindow:msg];
        }];
        
    } cancelTitle:@"暂时不想" action:^{
        
    }];
}


#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    UIImage *head320 = editedImage;
    UIImage *head100 = [self imageByScalingAndCroppingForSourceImage:head320 targetSize:CGSizeMake(100, 100)];
    UIImage *head50 = [self imageByScalingAndCroppingForSourceImage:head320 targetSize:CGSizeMake(50, 50)];
    NSData *data320 = UIImagePNGRepresentation(head320);
    NSData *data100 = UIImagePNGRepresentation(head100);
    NSData *data50 = UIImagePNGRepresentation(head50);
    NSMutableDictionary *headImages = [NSMutableDictionary new];
    [headImages setObject:data320 forKey:@"s320"];
    [headImages setObject:data100 forKey:@"s100"];
    [headImages setObject:data50 forKey:@"s50"];
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        
        NSString* requestUrlString = kAPIUserHead;
        MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
        MKNetworkOperation *op = [engine operationWithURLString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:nil httpMethod:@"POST"];
        NSArray *keys = headImages.allKeys;
        for (int i = 0;i<keys.count;i++) {
            [op addData:[headImages objectForKey:keys[i]] forKey:keys[i] mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"head%d.png",i]];
        }
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        [AppWindow addSubview:hud];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        CRWeekRef(self);
        [op onCompletion:^(MKNetworkOperation *completedOperation) {
            NSError *error = nil;
            NSDictionary* jsonHead = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:&error];
            UserHeadEntity *head = [UserHeadEntity buildInstanceByJson:jsonHead];
            [kCurUser changeAttr:@"head" value:CRString(@"%d",head.hid) success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                kCurUser.head100 = head.head100;
                kCurUser.head50 = head.head50;
                kCurUser.head320 = head.head320;
                kCurUser.headId = head.hid;
                [__self intilizedDataSource];
                NSMutableDictionary *userinfo = [LocalManager objectForKey:kLoginUserKey];
                [userinfo setObject:data forKey:@"head"];
                [LocalManager storeObject:userinfo forKey:kLoginUserKey];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [CustomToast showMessageOnWindow:msg];
            }];
            
        } onError:^(NSError *error) {
            [hud hide:true];
            [CustomToast showMessageOnWindow:error.localizedDescription];
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
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
