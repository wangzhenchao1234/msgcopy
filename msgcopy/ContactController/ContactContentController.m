//
//  ContactContentController.m
//  msgcopy
//
//  Created by Gavin on 15/7/27.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ContactContentController.h"
#import "ContactHeaderCell.h"
#import "ChangeGroupController.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "ChangeAttrController.h"
#import "XMContntController.h"

#define TOPHEIGHT 204
#define TOPEDGE 15


static NSString *infoCellidentifire = @"Cell";
static NSString *footerCellidentifire = @"Footer";
static NSString *headerCellidentifire = @"ContactHeader";


@interface ContactContentController ()<MWPhotoBrowserDelegate>
@property(nonatomic,retain)UIImageView *topImageView;
@property(nonatomic,retain)UIButton *headView;
@property(nonatomic,retain)UIButton *nickView;
@property(nonatomic,retain)UIButton *moodView;

@end

@implementation ContactContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
    [self configTopImage];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.title = @"联系人信息";
    if (!_contact&&_userName) {
        CRWeekRef(self);
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        [AppWindow addSubview:hud];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [MSGRequestManager Get:kAPIUserProfile(_userName) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            ContactEntity *contact = [[ContactEntity alloc] init];
            [contact buildByProfile:data];
            contact.title = [contact.firstName copy];
            contact.phone = [contact.lastName copy];
            _contact = contact;
            [__self configTopImage];
            [__self.tableView reloadData];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            _contact = [[ContactEntity alloc] init];
            [CustomToast showMessageOnWindow:msg];
            [__self.tableView reloadData];
        }];
    }else{
        if(_contact && !_contact.userName){
            
            
            _contact.userName = [ _contact.phone copy];
            
            NSLog(@"_contact.userName为空的");
        }
        [self.tableView reloadData];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configTableView
{
    //config some
    self.tableView.contentInset = UIEdgeInsetsMake(TOPHEIGHT, 0, 0, 0);
}
-(void)configTopImage
{
    //config some
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -TOPHEIGHT, self.view.width, TOPEDGE+TOPHEIGHT)];
        [self.view addSubview:_topImageView];
        
        _headView = [UIButton buttonWithType:UIButtonTypeCustom];
        _headView.frame = CGRectMake(0, 0, 55, 55);
        _headView.center = CGPointMake(CGRectGetMidX(self.view.frame), -TOPHEIGHT/2+10);
        _headView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _headView.layer.cornerRadius = 55/2.0f;
        _headView.layer.borderColor = CRCOLOR_WHITE.CGColor;
        _headView.layer.borderWidth = 2.0f;
        _headView.clipsToBounds = true;
        [_headView addTarget:self action:@selector(showHead:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_headView];
        
        _nickView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nickView setTitleColor:CRCOLOR_WHITE forState:UIControlStateNormal];
        [_nickView setTitleShadowColor:CRCOLOR_BLACK forState:UIControlStateNormal];
        [_nickView setTitleShadowOffset:CGSizeMake(1, 1)];
        [_nickView setImage:[UIImage imageNamed:@"ic_drop_down"] forState:UIControlStateNormal];
        _nickView.titleLabel.font = MSGFont(15);
        [_nickView addTarget:self action:@selector(modifyNickName) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nickView];
        
        _nickView.y = _headView.center.y + _headView.height/2.0f + 20;
        
        _moodView = [UIButton buttonWithType:UIButtonTypeCustom];
        _moodView.frame = CGRectMake(0, 0, 200, 30);
        _moodView.titleLabel.font = MSGFont(15);
        [_moodView setTitleColor:CRCOLOR_WHITE forState:UIControlStateNormal];
        [_moodView setTitleShadowColor:CRCOLOR_BLACK forState:UIControlStateNormal];
        [_moodView setTitleShadowOffset:CGSizeMake(1, 1)];
        [self.view addSubview:_moodView];
 

    }
    
    UIImage *cacheImage =  UserPlaceImage;
    if (_contact.head100.length > 0) {
        cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_contact.head100];
    }
    if (!cacheImage&&_contact.head100.length>0) {
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(_contact.head100) options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
           
            UIImage *newImage = [image applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.000 alpha:0.100] saturationDeltaFactor:1.0 maskImage:nil];
            _topImageView.image = newImage;
            [_headView setImage:image forState:UIControlStateNormal];
            [[SDImageCache sharedImageCache] storeImage:image forKey:_contact.head100];
        }];
    }else{
        UIImage *newImage = [cacheImage applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.000 alpha:0.100] saturationDeltaFactor:1.0 maskImage:nil];
        _topImageView.image = newImage;
        [_headView setImage:cacheImage forState:UIControlStateNormal];
    }
    [_nickView setTitle:_contact.title forState:UIControlStateNormal];
    [_nickView sizeToFit];
    [_nickView setImageEdgeInsets:UIEdgeInsetsMake(0, _nickView.width+5, 0, -_nickView.width+5)];
    _nickView.center = CGPointMake(self.view.width/2.0f, _nickView.y);
    
    [_moodView setTitle:_contact.mood forState:UIControlStateNormal];
    _moodView.center = CGPointMake(self.view.width/2.0f, _nickView.y + _nickView.height + 20);
    
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    if (CRWebAppTitle(@"chatroom")&&_contact.userName&&![_contact.userName isEqualToString:kCurUserName]) {
        
//        NSLog(@"相同^^^^^^^^^^^^^^^^^^^^^^^^^^%@ - %@",_contact.userName,kCurUserName);
        return 3;
    }
//    NSLog(@"不同^^^^^^^^^^^^^^^^^^^^^^^^^^%@ - %@",_contact.userName,kCurUserName);
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    if(section == 0)
        return 1;
    if (section == 1) {
        return 7;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*if(indexPath.section == 0)
    {
        ContactHeaderCell *header = [tableView dequeueReusableCellWithIdentifier:headerCellidentifire];
        if (!header){
            header = [Utility nibWithName:@"ContactHeaderCell" index:0];
            [header.HeadView addTarget:self action:@selector(showHead:) forControlEvents:UIControlEventTouchUpInside];
        }
        [header.HeadView sd_setImageWithURL:CRURL(_contact.head100) forState:UIControlStateNormal placeholderImage:UserPlaceImage];
        header.genderView.image = UserPlaceImage;
        header.nickView.text = _contact.title;
        header.moodView.text = _contact.mood;
        header.selectionStyle = UITableViewCellSelectionStyleNone;
        [header.nickView sizeToFit];
        header.nickView.height = 21;

        header.genderView.x = header.nickView.x + header.nickView.width + 8;
        header.genderView.y = header.nickView.y;
        [header.genderView setImage:_contact.gender?[UIImage imageNamed:@"sex_man"]:[UIImage imageNamed:@"sex_woman"]];
        return header;

    }*/
    
    if (indexPath.section == 2) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:footerCellidentifire];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:footerCellidentifire];
       
        }
//        NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%@",cell);
         return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoCellidentifire];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:infoCellidentifire];
    }
    cell.textLabel.font = MSGFont(14);
    cell.detailTextLabel.font = MSGFont(14);
    cell.textLabel.textColor = CellTitleColr;
    cell.detailTextLabel.text = nil;
    cell.textLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    if (indexPath.section == 0) {
        
        cell.textLabel.text = @"手机号";
        cell.detailTextLabel.text = _contact.phone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return cell;
    }
    
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"分组";
            cell.detailTextLabel.text = _contact.parent.title;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;


        }
            break;
        case 1:
        {
            cell.textLabel.text = @"性别";
            cell.detailTextLabel.text = _contact.gender==false?@"男":@"女";
            UIImage *accessoryImage = _contact.gender==false?[UIImage imageNamed:@"sex_man"]:[UIImage imageNamed:@"sex_woman"];
            cell.accessoryView = [[UIImageView alloc] initWithImage:accessoryImage];
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"公司";
            cell.detailTextLabel.text = _contact.company;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"职位";
            cell.detailTextLabel.text = _contact.occupation;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
            break;

        case 4:
        {
            cell.textLabel.text = @"生日";
            cell.detailTextLabel.text = _contact.birthday;
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"地区";
            if (_contact.prov&&_contact.city) {
                cell.detailTextLabel.text = CRString(@"%@ %@",_contact.prov,_contact.city);
            }else{
                cell.detailTextLabel.text = nil;
            }
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"备注";
            cell.detailTextLabel.text = _contact.remarks;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
            break;
   
        default:
            break;
    }
    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == 0) {
        //修改手机号
        if (_disableEdite) {
            return;
        }
        CRWeekRef(self);
        ChangeAttrController *nick = [[ChangeAttrController alloc] initWithTitle:@"修改联系人" placeholder:@"输入昵称" defautContent:_contact.phone completeAction:^(id text) {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
            hud.removeFromSuperViewOnHide = true;
            [AppWindow addSubview:hud];
            [hud show:true];
            NSDictionary *params = @{
                                     @"title":__self.contact.title,
                                     @"phone":text?text:@"",
                                     @"group":CRString(@"%d",__self.contact.parent.gid)
                                     };
            [MSGRequestManager MKUpdate:kAPIEditeContact(_contact.cid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                __self.contact.phone = text;
                [__self.navigationController popViewControllerAnimated:true];
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                [CustomToast showMessageOnWindow:msg];
            }];
            
        }];
        [self.navigationController pushViewController:nick animated:true];
        return;
    }
    if (indexPath.section == 1) {
        if (_disableEdite) {
            return;
        }
        switch (indexPath.row) {
            case 0:
            {
               //修改分组
                ChangeGroupController *group = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ChangeGroupController"];
                group.contact = _contact;
                [self.navigationController pushViewController:group animated:true];
            }
                break;
            case 2:
            {
                //修改公司
                CRWeekRef(self);
                ChangeAttrController *company = [[ChangeAttrController alloc] initWithTitle:@"修改公司" placeholder:@"输入公司名称" defautContent:_contact.company completeAction:^(id text) {
                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                    hud.removeFromSuperViewOnHide = true;
                    [AppWindow addSubview:hud];
                    [hud show:true];
                    NSDictionary *params = @{
                                             @"title":__self.contact.title,
                                             @"phone":__self.contact.phone?__self.contact.phone:@"",
                                             @"company":text?text:@"",
                                             @"group":CRString(@"%d",__self.contact.parent.gid)
                                             };
                    [MSGRequestManager MKUpdate:kAPIEditeContact(_contact.cid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        __self.contact.company = text;
                        [__self.navigationController popViewControllerAnimated:true];
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        [CustomToast showMessageOnWindow:msg];
                    }];
                }];
                [self.navigationController pushViewController:company animated:true];

                
            }
                break;
            case 3:
            {
                //修改职位
                CRWeekRef(self);
                ChangeAttrController *occupation = [[ChangeAttrController alloc] initWithTitle:@"修改职业" placeholder:@"输入职业" defautContent:_contact.occupation completeAction:^(id text) {
                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                    hud.removeFromSuperViewOnHide = true;
                    [AppWindow addSubview:hud];
                    [hud show:true];
                    NSDictionary *params = @{
                                             @"title":__self.contact.title,
                                             @"phone":__self.contact.phone?__self.contact.phone:@"",
                                             @"occupation":text?text:@"",
                                             @"group":CRString(@"%d",__self.contact.parent.gid)
                                             };
                    [MSGRequestManager MKUpdate:kAPIEditeContact(_contact.cid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        __self.contact.occupation = text;
                        [__self.navigationController popViewControllerAnimated:true];
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        [CustomToast showMessageOnWindow:msg];
                    }];
                    
                }];

                [self.navigationController pushViewController:occupation animated:true];

            
            }
                break;
            case 6:
            {
                //修改备注
                CRWeekRef(self);
                ChangeAttrController *remarks = [[ChangeAttrController alloc] initWithTitle:@"修改备注" placeholder:@"输入备注" defautContent:_contact.remarks completeAction:^(id text) {
                    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                    hud.removeFromSuperViewOnHide = true;
                    [AppWindow addSubview:hud];
                    [hud show:true];
                    NSDictionary *params = @{
                                             @"title":__self.contact.title,
                                             @"phone":__self.contact.phone?__self.contact.phone:@"",
                                             @"remarks":text?text:@"",
                                             @"group":CRString(@"%d",__self.contact.parent.gid)
                                             };
                    [MSGRequestManager MKUpdate:kAPIEditeContact(_contact.cid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        __self.contact.remarks = text;
                        [__self.navigationController popViewControllerAnimated:true];
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        [CustomToast showMessageOnWindow:msg];
                    }];
                    
                }];
                [self.navigationController pushViewController:remarks animated:true];

            }
                break;

            default:
                break;
        }

    }
    if (indexPath.section == 2) {
        //聊天
        //如果未登录
        if (!LoginState) {
            [LoginHandler showLoginControllerFromController:CRRootNavigation() complete:nil];
            return;
        }
        
        
        XMContntController *XMVC = [XMContntController messagesViewController];
        if (_contact.userName)
        {
            XMVC.roser = [_contact.userName copy];
            XMVC.senderDisplayName = _contact.title;
            [CRRootNavigation() pushViewController:XMVC animated:true];
        }else{
            [CustomToast showMessageOnWindow:@"暂时不能聊天请稍后再试"];
        }
    }
}


# pragma mark - actions

# pragma mark - 查看头像

-(void)showHead:(id)sender{
    //do something
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
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [CRRootNavigation() presentViewController:nc animated:true completion:^{
    }];
}

-(void)modifyNickName{
    
    CRWeekRef(self);
    if (_disableEdite) {
        return;
    }
    ChangeAttrController *nick = [[ChangeAttrController alloc] initWithTitle:@"修改联系人" placeholder:@"输入昵称" defautContent:_contact.title completeAction:^(id text) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [AppWindow addSubview:hud];
        [hud show:true];
        NSDictionary *params = @{
                                 @"title":text?text:@"",
                                 @"phone":__self.contact.phone,
                                 @"group":CRString(@"%d",__self.contact.parent.gid)
                                 };
        [MSGRequestManager MKUpdate:kAPIEditeContact(_contact.cid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            __self.contact.title = text;
            [__self.navigationController popViewControllerAnimated:true];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            
            [CustomToast showMessageOnWindow:msg];
        }];
    }];
    [self.navigationController pushViewController:nick animated:true];

}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    
    return 1;
    
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    return [[MWPhoto alloc] initWithURL:CRURL(_contact.head320)];
;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    
    return [[MWPhoto alloc] initWithURL:CRURL(_contact.head50)];
}
-(void)dealloc
{
    NSLog(@"dealloc");
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
