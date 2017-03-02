//
//  RegisterController.m
//  msgcopy
//
//  Created by wngzc on 15/5/20.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "RegisterController.h"
#import "PhoneRegisterController.h"
#import "VerifyEmailController.h"
#import "ScoreUserActionManager.h"
@interface RegisterController ()<UITextFieldDelegate>
{
    NSString *_loginPlaceholder;
    UITextField *_userfiled;
    UITextField *_passfiled;
    UITextField *_confirPassfiled;
    __block NSDictionary   *userPoint;

}
@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self intilizedDataSource];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
//datasource
-(void)intilizedDataSource{
    
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
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 3;
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
{
    if (section == 0) {
        ActionFooterView *footerView = [Utility nibWithName:@"ActionFooterView" index:0];
        [footerView addTarget:self action:@selector(doRegister:) forControlEvents:UIControlEventTouchUpInside];
        [footerView setTitle:@"注   册" state:UIControlStateNormal];
        return footerView;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
            _userfiled = cellInput.textInputView;
            _userfiled.returnKeyType = UIReturnKeyNext;

            break;
        case 1:
            [cellInput.iconView setImage:[UIImage imageNamed:@"dl_password"]];
            [cellInput setPlaceholder:@"输入密码"];
            cellInput.textInputView.secureTextEntry = true;
            _passfiled = cellInput.textInputView;
            _passfiled.returnKeyType = UIReturnKeyNext;

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
#pragma mark - textFiledDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
#pragma mark - actions

-(void)doRegister:(id)sender{
    
    if (![VerifyHanddler verifyied:_userfiled.text]) {
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
    
    
    
    if (_userfiled.text == nil||_userfiled.text.length == 0) {
        [CustomToast showMessageOnWindow:@"用户名不能为空！"];
    }else if(_userfiled.text.length < 5){
        [CustomToast showMessageOnWindow:@"用户名长度不能小与5！"];
    }else if(_passfiled.text == nil||_passfiled.text.length == 0){
        [CustomToast showMessageOnWindow:@"密码不能为空！"];
    }else if(_passfiled.text.length < 4){
        [CustomToast showMessageOnWindow:@"密码名长度不能小与4！"];
    }else if(![_confirPassfiled.text isEqualToString:_passfiled.text]){
        [CustomToast showMessageOnWindow:@"两次输入密码不一致"];
    }else if ([self isEmpty:_userfiled.text]||[self isEmpty:_passfiled.text]){
        [CustomToast showMessageOnWindow:@"密码中不能包含空格！"];
    }else if([VerifyHanddler verifyPhone:_userfiled.text]){
        NSDictionary *params  = @{
                                  @"username":_userfiled.text,
                                  @"password1":_passfiled.text,
                                  @"password2":_confirPassfiled.text,
                                  @"agreement":@"YES"
                                  };
        [self goToPhoneRegigest:params];
    }else{
        MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        hud.labelText = @"正在注册";
        NSDictionary *params  = @{
                                  @"username":_userfiled.text,
                                  @"password1":_passfiled.text,
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
    }
    
}
//是否包含空格
-(BOOL)isEmpty:(NSString *)str{
    NSRange range = [str rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return  YES; //yes代表空格
    }
    return NO;//反之
}


/**
 *  手机号注册
 */
-(void)goToPhoneRegigest:(NSDictionary*)params{
    
    PhoneRegisterController *phoneVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"PhoneRegisterController"];
    phoneVC.registerParams = [[NSDictionary alloc] initWithDictionary:params];
    phoneVC.registerCompleteAction = _registerCompleteAction;
    [self.navigationController pushViewController:phoneVC animated:true];
    
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
            [self.navigationController popViewControllerAnimated:true];
        }
        
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
                                  @"username":_userfiled.text,
                                  @"password":_passfiled.text,
                                  @"imei":MD5deviceId
                                  };
        UserDataManager *manager = [UserDataManager sharedManager];
        CRWeekRef(self);
        [manager doLogin:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            
            
            
            //发送验证邮件
            VerifyEmailController *emailVc = [Utility controllerInStoryboard:@"Main" withIdentifier:@"VerifyEmailController"];
            emailVc.email = _userfiled.text;
            [__self.navigationController pushViewController:emailVc animated:true];

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
    [_confirPassfiled resignFirstResponder];
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
