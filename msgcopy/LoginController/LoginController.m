//
//  LoginController.m
//  msgcopy
//
//  Created by Gavin on 15/5/20.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "LoginController.h"
#import "RegisterController.h"
#import "GetPwdController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"


@interface LoginController ()<UITextFieldDelegate,LoginMenuCellDelegate>
{
    NSString *_loginPlaceholder;
    UITextField *_userfiled;
    UITextField *_passfiled;
    BOOL _hasThird;
}
@property(nonatomic,retain)ThirdLoginMenu *third;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self intilizedDataSource];
    [self configTableView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//tableView
-(void)configTableView
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [backButton setImage:BlackBackImage forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0,-10, 0, 10)];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [Utility setTransparentNavigation:self.navigationController navBarTransparent:TransParentNavBg];
}
//datasource
-(void)intilizedDataSource{
    
    UIImage *_sina = [UIImage imageNamed:@"login_sina"];
    UIImage *_qq = [UIImage imageNamed:@"login_qq"];
    UIImage *_weixin = [UIImage imageNamed:@"login_wx"];
    _third = [Utility nibWithName:@"ThirdLoginMenu" index:0];
    if (![QQAPP_ID isEqualToString:@"null"]&&!([QQAPP_ID length]==0)) {
        _third.qq = _qq;
        _hasThird = true;
    }
    if (![AppKey_Sina isEqualToString:@"null"]&&!([AppKey_Sina length]==0)) {
        _third.sina = _sina;
        _hasThird = true;

    }
    if (![WXAppID isEqualToString:@"null"]&&![WXAppSecret isEqualToString:@"null"]&&!([WXAppID length] == 0) && !([WXAppSecret length] == 0)) {
        _third.wechat = _weixin;
        _hasThird = true;

    }
    if (_hasThird) {
        _third.frame = CGRectMake(0, 0, self.view.width,72);
        self.tableView.tableFooterView = _third;
        [_third reloadData];
        [_third setNeedsDisplay];
    }
    
    switch (kRegisterType) {
        case RegegistTypeNormal:
            _loginPlaceholder = @"用户名/邮箱/手机号";
            break;
        case RegegistTypeEmail:
            _loginPlaceholder = @"邮箱";
            break;
        case RegegistTypePhone:
            _loginPlaceholder = @"手机号";
            break;
        case RegegistTypeEP:
            _loginPlaceholder = @"邮箱/手机号";
            break;
        default:
            break;
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [Utility setTransparentNavigation:self.navigationController navBarTransparent:TransParentNavBg];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resignAllFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 1) {
        return 2;
    }
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            CGFloat abs = AppWindow.height - (HeaderHeight) - _third.height - 55 - 10 - 39 - 100 - (NAV_H) - 80;
            CGFloat height = abs>32?abs:32;
            return height;
        }
        return 39;
    }
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 55;
    }
    return 0.0f;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        ActionFooterView *footerView = [Utility nibWithName:@"ActionFooterView" index:0];
        [footerView addTarget:self action:@selector(doLogin:) forControlEvents:UIControlEventTouchUpInside];
        [footerView setTitle:@"登   录" state:UIControlStateNormal];
        return footerView;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *InputCellIdentifire = @"InputCell";
    if (indexPath.section == 0) {
        InputCell *cellInput = (InputCell*)[tableView dequeueReusableCellWithIdentifier:InputCellIdentifire];
        if (!cellInput) {
            cellInput  = (InputCell*)[Utility nibWithName:InputCellIdentifire index:0];
            cellInput.lineRightInset = 36;
            cellInput.lineLeftInset = 36;
            cellInput.textInputView.delegate = self;
            [cellInput setNeedsDisplay];
        }
        switch (indexPath.row) {
            case 0:
                [cellInput.iconView setImage:[UIImage imageNamed:@"dl_user"]];
                [cellInput setPlaceholder:_loginPlaceholder];
                _userfiled = cellInput.textInputView;
                _userfiled.returnKeyType = UIReturnKeyNext;
                
                break;
            case 1:
                [cellInput.iconView setImage:[UIImage imageNamed:@"dl_password"]];
                [cellInput setPlaceholder:@"密码"];
                cellInput.textInputView.secureTextEntry = true;
                _passfiled = cellInput.textInputView;
                _passfiled.returnKeyType = UIReturnKeyDone;

                break;
            default:
                break;
        }
        return cellInput;


    }else{
        if (indexPath.row == 1) {
            return [tableView dequeueReusableCellWithIdentifier:@"cell"];
        }
        LoginMenuCell *cell = [Utility nibWithName:@"LoginMenuCell" index:0];
        cell.delegate = self;
        return cell;
        
    }
    // Configure the cell...
}

#pragma mark - textFiledDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userfiled) {
        [_userfiled resignFirstResponder];
        while (_userfiled.isFirstResponder) {
            
        }
        [_passfiled becomeFirstResponder];
        return true;
    }
    [_passfiled resignFirstResponder];
    [self doLogin:nil];

    return true;
}
#pragma mark - actions
/**
 *  注册
 *
 *  @param sender
 */
- (void)doRegister:(id)sender {
    
    RegisterController *registerVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"RegisterController"];
    CRWeekRef(self);
    registerVC.registerCompleteAction = ^(NSString *username,NSString *password){
        [__self.navigationController popToViewController:self animated:true];
        _userfiled.text = username;
        _passfiled.text = password;
        [__self doLogin:nil];
    };
    [self.navigationController pushViewController:registerVC animated:true];
    
}
/**
 *  找回密码
 *
 *  @param sender
 */
- (void)doGetPwd:(id)sender {    
    
    //忘记密码
    GetPwdController *registerVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"GetPwdController"];
    [self.navigationController pushViewController:registerVC animated:true];
    
}


-(void)goBack:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:true completion:^{
        GSliderViewController *slider = (GSliderViewController*)CRRootNavigation().viewControllers[0];
        UINavigationController *rootNav = (UINavigationController*)slider.centerViewController;
        CenterController *_rootCenter = (CenterController*)rootNav.viewControllers[0];
        BOOL state = [_rootCenter checkPermission];
        if (_loginCallBack&&state) {
            _loginCallBack(false);
        }
    }];
}

-(void)doLogin:(id)sender{
    
    [self resignAllFirstResponder];
    
    if (_userfiled.text == nil||_userfiled.text.length == 0) {
        [CustomToast showMessageOnWindow:@"用户名不能为空！"];
    }else if(_passfiled.text == nil||_passfiled.text.length == 0){
        [CustomToast showMessageOnWindow:@"密码不能为空！"];
    }else{
        MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        hud.labelText = @"正在登录";
        //自动生成UUID
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString *strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        //对UUID进行16位MD5编码
        NSString *MD5deviceId = [NSString getmd5_16WithString:strUUID];
//        NSLog(@"^^^^^^^^^^^^^--%@",MD5deviceId);
        if ([MD5deviceId isEqualToString:@""]||[MD5deviceId isEqual:nil]) {
            MD5deviceId = @"0000000000000000";
        }
        NSDictionary *params  = @{
                                  @"username":_userfiled.text,
                                  @"password":_passfiled.text,
                                  @"imei":MD5deviceId
                                  };
        UserDataManager *manager = [UserDataManager sharedManager];
        CRWeekRef(self);
        [manager doLogin:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
            [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                [hud hide:true];
                CRBackgroundGCD(^{
                    [[XmppListenerManager sharedManager] setUser:kCurUser];
                    [[HistoryContentManager sharedManager] getAllRoomsComplete:nil];
                });
                if (_openID) {
                    [OauthManager bindWxPlt:self.openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        kCurUser.wx_openid = _openID;
                        
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        NSLog(@"绑定失败web%@----msg==%@---data===%@==%ld",requestURL,msg,data,code);
                    }];
    
                }
                
                [__self.navigationController dismissViewControllerAnimated:true completion:^{
                    GSliderViewController *slider = (GSliderViewController*)CRRootNavigation().viewControllers[0];
                    UINavigationController *rootNav = (UINavigationController*)slider.centerViewController;
                    CenterController *_rootCenter = (CenterController*)rootNav.viewControllers[0];
                    BOOL state = [_rootCenter checkPermission];
                    if (_loginCallBack&&state) {
                        _loginCallBack(true);
                    }
                }];
                
            }];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            [CustomToast showMessageOnWindow:msg];
        }];
    }
    
}
/**
 *  关闭键盘
 */

-(void)resignAllFirstResponder{
    
    [_userfiled resignFirstResponder];
    [_passfiled resignFirstResponder];

}

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
