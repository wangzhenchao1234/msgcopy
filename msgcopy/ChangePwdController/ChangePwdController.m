//
//  ChangePwdController.m
//  msgcopy
//
//  Created by Gavin on 15/6/19.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ChangePwdController.h"

@interface ChangePwdController ()<UITextFieldDelegate>
{
    UITextField *_oldPass;
    UITextField *_passfiled;
    UITextField *_confirPassfiled;
}
@end

@implementation ChangePwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    // Do any additional setup after loading the view.
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
        [footerView addTarget:self action:@selector(doSubmite:) forControlEvents:UIControlEventTouchUpInside];
        [footerView setTitle:@"提   交" state:UIControlStateNormal];
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
    }
    switch (indexPath.row) {
        case 0:
           
            [cellInput setNeedsDisplay];
            [cellInput.iconView setImage:[UIImage imageNamed:@"dl_password"]];
            [cellInput setPlaceholder:@"旧密码"];
            cellInput.textInputView.returnKeyType = UIReturnKeyNext;
            cellInput.textInputView.secureTextEntry = true;
            _oldPass = cellInput.textInputView;
            break;
        case 1:
            [cellInput setNeedsDisplay];
            [cellInput.iconView setImage:[UIImage imageNamed:@"dl_password"]];
            [cellInput setPlaceholder:@"新密码"];
            cellInput.textInputView.returnKeyType = UIReturnKeyNext;
            cellInput.textInputView.secureTextEntry = true;
            _passfiled = cellInput.textInputView;
            break;
        case 2:
            [cellInput setNeedsDisplay];
            [cellInput.iconView setImage:[UIImage imageNamed:@"dl_password2"]];
            [cellInput setPlaceholder:@"确认新密码"];
            cellInput.textInputView.returnKeyType = UIReturnKeyDone;
            cellInput.textInputView.secureTextEntry = true;
            _confirPassfiled = cellInput.textInputView;
            break;
        default:
            break;
    }
    return cellInput;
    // Configure the cell...
}

#pragma mark - textFiledDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _oldPass) {
        [_oldPass resignFirstResponder];
        while (_oldPass.isFirstResponder) {
            
        }
        [_passfiled becomeFirstResponder];
        return true;
    }else if (textField == _passfiled) {
        [_passfiled resignFirstResponder];
        while (_passfiled.isFirstResponder) {
            
        }
        [_confirPassfiled becomeFirstResponder];
        return true;
    }
    [_confirPassfiled resignFirstResponder];
    return true;
}

#pragma mark - actions
-(void)doSubmite:(id)sender
{
    [self resignAllFirstResponder];
    if (_oldPass.text == nil||_oldPass.text.length == 0) {
        [CustomToast showMessageOnWindow:@"请输入旧密码"];
    }else if(_passfiled.text == nil||_passfiled.text.length == 0){
        [CustomToast showMessageOnWindow:@"请输入新密码！"];
    }else if(_passfiled.text.length < 4){
        [CustomToast showMessageOnWindow:@"密码不能小于4位！"];
    }else if(_confirPassfiled.text == nil||_confirPassfiled.text.length == 0){
        [CustomToast showMessageOnWindow:@"确认密码不能为空！"];
    }else if(![_confirPassfiled.text isEqualToString:_passfiled.text]){
        [CustomToast showMessageOnWindow:@"两次输入不能相同！"];
    }else if ([self isEmpty:_confirPassfiled.text]){
        [CustomToast showMessageOnWindow:@"确认密码中不能包含空格！"];
    }else{
        
        MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        hud.labelText = @"正在修改";
        NSDictionary *params  = @{
                                  @"old_password":_oldPass.text,
                                  @"new_password1":_passfiled.text,
                                  @"new_password2":_confirPassfiled.text,
                                  };
        //CRWeekRef(self);
        [MSGRequestManager MKUpdate:kAPIModifyPass params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
//             NSMutableDictionary *userinfo = [LocalManager objectForKey:kUserInfoKey];
//             [userinfo setObject:params[@"new_password1"] forKey:@"password"];
//            [LocalManager storeObject:userinfo forKey:kUserInfoKey];

//            [[NSUserDefaults standardUserDefaults]removeObjectForKey:kUserInfoKey];
    //            [__self.navigationController popViewControllerAnimated:true];
            [CustomToast showMessageOnWindow:@"修改成功"];

            NSDictionary *keychainUser = [UserDataManager keychainUser];
            NSLog(@"确认退出时的用户信息 --- %@",keychainUser);
            
            [[UserDataManager sharedManager] doLogin:keychainUser success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                    [hud hide:true];
                    CRBackgroundGCD(^{
                    [[XmppListenerManager sharedManager] disconnect];
                    });
              
                [CRRootNavigation() popToRootViewControllerAnimated:YES];
                
                }];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                [CustomToast showMessageOnWindow:msg];
            }];

//            弹出登录提示
            LoginController *loginVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LoginController"];
            loginVC.loginCallBack = nil;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [CRRootNavigation() presentViewController:nav animated:true completion:^{
            
            }];

  
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
 *  关闭键盘
 */
-(void)resignAllFirstResponder{
    [_oldPass resignFirstResponder];
    [_passfiled resignFirstResponder];
    [_confirPassfiled resignFirstResponder];
}

@end
