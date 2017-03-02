//
//  JudgeIsLoginOrRegisterViewController.m
//  msgcopy
//
//  Created by sh on 2016/12/5.
//  Copyright © 2016年 Gavin. All rights reserved.
//

#import "JudgeIsLoginOrRegisterViewController.h"
#import "ThirdLoginMenu.h"
#import "ThirdIconCell.h"
#import "WeiChatOauth.h"
#import "RegisterController.h"
#import "OauthManager.h"
#import "LoginController.h"
#import "WXApi.h"
#import "PhoneRegisterController.h"
#import "VerifyEmailController.h"
#import "ScoreUserActionManager.h"
#define HeaderHeight App3xScale(AppWindow.height*(157/1136.0f))
#define KscreenW [UIScreen mainScreen].bounds.size.width
#define KscreenH [UIScreen mainScreen].bounds.size.height
@interface JudgeIsLoginOrRegisterViewController ()<UITableViewDataSource,UITableViewDelegate,LoginMenuCellDelegate,UITextFieldDelegate>{
    UITableView*_tableView1;
    UITableView*_tableView2;
    NSString *_loginPlaceholder;
    UITextField *_userfiled;
    UITextField *_passfiled;
    UITextField *_registerUserfiled;
    UITextField *_registerPasswordfiled;
    UITextField *_confirPassfiled;
    __block NSDictionary   *userPoint;
    
}
@property(nonnull,strong)UIButton*button1;
@property(nonnull,strong)UIButton*button2;
@property(nonatomic,retain)ThirdLoginMenu *third;

@end

@implementation JudgeIsLoginOrRegisterViewController
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resignAllFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexRGB:@"eeeeee"];
    [self initData];
    [self configNavigationItem];
    
    [self configSelectButtonMethod];
}
-(void)initData{
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
-(void)configNavigationItem{
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 27, 27)];
    [backButton setImage:BlackBackImage forState:UIControlStateNormal];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0,-10, 0, 10)];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

-(void)configSelectButtonMethod{
    
    UIView*view = [[UIView alloc]initWithFrame:CGRectMake(KscreenW/10, 70,KscreenW-(KscreenW/10)*2+10, 42)];
    view.backgroundColor = [UIColor clearColor];
    view.layer.cornerRadius = 8;
    view.clipsToBounds = YES;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    UIButton*button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame =CGRectMake(0, 0, view.bounds.size.width/2, view.bounds.size.height);
    
    UIButton*button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame =CGRectMake(view.bounds.size.width/2, 0, view.bounds.size.width/2, view.bounds.size.height);
//    button1.layer.borderWidth = 1;
//    button1.layer.borderColor = [UIColor blackColor].CGColor;
//    button2.layer.borderWidth = 1;
//    button2.layer.borderColor = [UIColor blackColor].CGColor;
    self.button1 = button1;
    self.button2 = button2;
    self.button2.tag = 22;
    self.button1.tag = 21;
    [_button1 setTitle:@"绑定已有账号" forState:UIControlStateNormal];
    _button1.selected =YES;
    _button1.enabled = NO;
    _button2.enabled = YES;
    [_button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_button2 setTitle:@"注册新账号" forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    _button1.backgroundColor = [UIColor lightGrayColor];
    
    _button2.backgroundColor = [UIColor whiteColor];
    [_button1 addTarget:self action:@selector(sortButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_button2 addTarget:self action:@selector(sortButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [view addSubview:_button1];
    [view addSubview:_button2];
    [self.view addSubview:view];
    [self tableViewMethod:view];
    
}
#pragma mark-表视图方法
-(void)tableViewMethod:(UIView*)view{
            
    _tableView1 = [[UITableView alloc]initWithFrame:CGRectMake(0, 135, KscreenW, KscreenH-135-49)];
    
    [self.view addSubview:_tableView1];
    
    _tableView1.userInteractionEnabled = YES;
    
    _tableView1.multipleTouchEnabled = YES;
    
    _tableView1.backgroundColor = [UIColor clearColor];
    
    _tableView1.delegate = self;
    
    _tableView1.dataSource = self;
    
    _tableView2 = [[UITableView alloc]initWithFrame:CGRectMake(KscreenW,135 , KscreenW, KscreenH-135-49)];
    
    [self.view addSubview:_tableView2];
    
    _tableView2.userInteractionEnabled =YES;
    
    _tableView2.multipleTouchEnabled =YES;
    
    _tableView2.backgroundColor = [UIColor clearColor];
    
    _tableView2.delegate = self;
    
    _tableView2.dataSource = self;
    
}

-(void)goBack:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:true completion:^{
    }];
}
-(void)sortButtonClick:(UIButton*)button{
    
    if (button == _button1) {
        
        _tableView1.frame = CGRectMake(0, 135, KscreenW, KscreenH-135-49);
        _tableView2.frame = CGRectMake(KscreenW, 135, KscreenW, KscreenH-135-49);
        _button1.enabled=NO;
        _button2.enabled = YES;
        if (!button.enabled) {
            [_button1 setBackgroundColor:[UIColor lightGrayColor]];
            [_button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        if (_button2.enabled) {
            [_button2 setBackgroundColor:[UIColor whiteColor]];
            [_button2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            
        }
    }
    if (button ==_button2) {
        _tableView1.frame = CGRectMake(-KscreenW, 135, KscreenW, KscreenH-135-49);
        _tableView2.frame = CGRectMake(0, 135, KscreenW, KscreenH-135-49);
        _button2.enabled = NO;
        _button1.enabled = YES;
        
        if (!_button2.enabled) {
            
            [_button2 setBackgroundColor:[UIColor lightGrayColor]];
            [_button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
        }
        
        if (_button1.enabled) {
            [_button1 setBackgroundColor:[UIColor whiteColor]];
            [_button1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            
        }
    }
    
    
    
}

#pragma mark-tableView的代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (tableView == _tableView1) {
        
        return 1;
        
    }else{
        
        return 1;
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == _tableView1) {
        
        return 2;
    }else{
        
        return 3;
        
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
{    if(tableView==_tableView2){
    
    if (section == 0) {
        ActionFooterView *footerView = [Utility nibWithName:@"ActionFooterView" index:0];
        [footerView addTarget:self action:@selector(doRegister:) forControlEvents:UIControlEventTouchUpInside];
        [footerView setTitle:@"注   册" state:UIControlStateNormal];
        return footerView;
    }
    
}
    if (tableView==_tableView1) {
        if (section == 0) {
            ActionFooterView *footerView = [Utility nibWithName:@"ActionFooterView" index:0];
            [footerView addTarget:self action:@selector(doLogin:) forControlEvents:UIControlEventTouchUpInside];
            [footerView setTitle:@"登   录" state:UIControlStateNormal];
            return footerView;
        }
        
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==_tableView1) {
        
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
        
    }else{
        static NSString *InputCellIdentifire = @"InputCell";
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
                _registerUserfiled = cellInput.textInputView;
                _registerUserfiled.returnKeyType = UIReturnKeyNext;
                
                break;
            case 1:
                [cellInput.iconView setImage:[UIImage imageNamed:@"dl_password"]];
                [cellInput setPlaceholder:@"输入密码"];
                cellInput.textInputView.secureTextEntry = true;
                _registerPasswordfiled = cellInput.textInputView;
                _registerPasswordfiled.returnKeyType = UIReturnKeyNext;
                
                break;
            case 2:
                [cellInput.iconView setImage:[UIImage imageNamed:@"dl_password2"]];
                [cellInput setPlaceholder:@"确认密码"];
                _confirPassfiled = cellInput.textInputView;
                cellInput.textInputView.secureTextEntry = true;
                _confirPassfiled.returnKeyType = UIReturnKeyDone;
                
                break;
            default:
                break;
        }
        // Configure the cell...
        return cellInput;
        
    }
    
    return nil;
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
-(void)doRegister:(id)sender{
    
    if (![VerifyHanddler verifyied:_registerUserfiled.text]) {
        NSString *type = nil;
        switch (kRegisterType) {
            case RegegistTypePhone:type = @"手机号";
                break;
            case RegegistTypeEmail | RegegistTypePhone:
                type = @"手机号或邮箱";
                break;
            case RegegistTypeEmail:
                type = @"邮箱";
                break;
            default:
                break;
        }
        [CustomToast showMessageOnWindow:[NSString stringWithFormat:@"您输入的%@格式不正确",type]];
        return;
    }
    
    if (_registerUserfiled.text == nil||_registerUserfiled.text.length == 0) {
        [CustomToast showMessageOnWindow:@"用户名不能为空！"];
    }else if(_registerUserfiled.text.length < 5){
        [CustomToast showMessageOnWindow:@"用户名长度不能小与5！"];
    }else if(_registerPasswordfiled.text == nil||_registerPasswordfiled.text.length == 0){
        [CustomToast showMessageOnWindow:@"密码不能为空！"];
    }else if(_registerPasswordfiled.text.length < 4){
        [CustomToast showMessageOnWindow:@"密码名长度不能小与4！"];
    }else if(![_confirPassfiled.text isEqualToString:_registerPasswordfiled.text]){
        [CustomToast showMessageOnWindow:@"两次输入密码不一致"];
    }else if ([self isEmpty:_registerUserfiled.text]||[self isEmpty:_registerPasswordfiled.text]){
        [CustomToast showMessageOnWindow:@"密码中不能包含空格！"];
    }else if([VerifyHanddler verifyPhone:_registerUserfiled.text]){
        NSDictionary *params  = @{
                                  @"username":_registerUserfiled.text,
                                  @"password1":_registerPasswordfiled.text,
                                  @"password2":_confirPassfiled.text,
                                  @"agreement":@"YES"
                                  };
        //    _registerCompleteAction(params[@"username"],params[@"password1"]);
        [self goToPhoneRegigest:params];
    }else{
        MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        hud.labelText = @"正在注册";
        NSDictionary *params  = @{
                                  @"username":_registerUserfiled.text,
                                  @"password1":_registerPasswordfiled.text,
                                  @"password2":_confirPassfiled.text,
                                  @"agreement":@"YES"
                                  };
        CRWeekRef(self);
        [MSGRequestManager Post:kAPIRegister params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            NSDictionary * dict = [[NSDictionary alloc] init];
            dict = data;
            
            [__self handdleRegisterResult:params];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            [CustomToast showMessageOnWindow:msg];
        }];
    };
    
    
}


/**
 *  处理注册结果
 */
-(void)handdleRegisterResult:(NSDictionary*)params
{
    
    NSString *username = params[@"username"];
    NSString *passowrd = params[@"password1"];
    
    if (kRegisterType != RegegistTypeEmail&&![VerifyHanddler verifyEmail:username]) {
        
        if (_registerCompleteAction) {
            _registerCompleteAction(username,passowrd);
        }else{
            //            [self.navigationController popViewControllerAnimated:true];
        }
        
        
        [OauthManager registerThirdPlt:@"weixin" params:@{@"username":_registerUserfiled.text,@"password":_registerPasswordfiled.text} openID:_openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [self handdleResult];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [CustomToast showMessageOnWindow:data];
        }];
        
        
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
        NSDictionary *params  = @{
                                  @"username":_registerUserfiled.text,
                                  @"password":_registerPasswordfiled.text,
                                  @"imei":MD5deviceId
                                  };
        UserDataManager *manager = [UserDataManager sharedManager];
        CRWeekRef(self);
        [manager doLogin:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            
            
            
            //发送验证邮件
            VerifyEmailController *emailVc = [Utility controllerInStoryboard:@"Main" withIdentifier:@"VerifyEmailController"];
            emailVc.isThirdLogin = YES;
            emailVc.email = _registerUserfiled.text;
            emailVc.thirdLoginPassword = _registerPasswordfiled.text;
            emailVc.openID = _openID;
            [__self.navigationController pushViewController:emailVc animated:true];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            [CustomToast showMessageOnWindow:msg];
        }];
        
    }
    
}
-(void)handdleResult{
    
    //    CRWeekRef(self);
    CRBackgroundGCD(^{
        [[XmppListenerManager sharedManager] setUser:kCurUser];
        [[HistoryContentManager sharedManager] getAllRoomsComplete:nil];
    });
    [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
        
        [self.navigationController dismissViewControllerAnimated:true completion:^{
            GSliderViewController *slider = (GSliderViewController*)CRRootNavigation().viewControllers[0];
            UINavigationController *rootNav = (UINavigationController*)slider.centerViewController;
            CenterController *_rootCenter = (CenterController*)rootNav.viewControllers[0];
            [_rootCenter checkPermission];
        }];
        
    }];
    
}


/**
 *  手机号注册
 */
-(void)goToPhoneRegigest:(NSDictionary*)params{
    
    PhoneRegisterController *phoneVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"PhoneRegisterController"];
    phoneVC.registerParams = [[NSDictionary alloc] initWithDictionary:params];
    phoneVC.isThildLogin = YES;
    phoneVC.openID = _openID;
    if (!_registerPasswordfiled) {
        
    }else{
        phoneVC.registerCompleteAction = _registerCompleteAction;
        
        
    }
    [self.navigationController pushViewController:phoneVC animated:true];
    
}

#pragma mark - textFiledDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(!_button1.enabled){
        
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
    if (!_button2.enabled) {
        if (textField == _userfiled) {
            [_userfiled resignFirstResponder];
            while (_userfiled.isFirstResponder) {
                
            }
            [_passfiled becomeFirstResponder];
            return true;
        }else if(textField == _passfiled){
            [_passfiled resignFirstResponder];
            while (_passfiled.isFirstResponder) {
                
            }
            [_confirPassfiled becomeFirstResponder];
            return true;
        }
        [_confirPassfiled resignFirstResponder];
        [self doRegister:nil];
        
        return true;
        
    }
    return true;
}
-(void)resignAllFirstResponder{
    
    [_userfiled resignFirstResponder];
    [_passfiled resignFirstResponder];
    [_confirPassfiled resignFirstResponder];
    
}
//是否包含空格
-(BOOL)isEmpty:(NSString *)str{
    NSRange range = [str rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return  YES; //yes代表空格
    }
    return NO;//反之
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
