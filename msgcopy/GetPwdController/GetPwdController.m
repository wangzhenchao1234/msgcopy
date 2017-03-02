//
//  GetPwdController.m
//  msgcopy
//
//  Created by wngzc on 15/5/22.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "GetPwdController.h"

@interface GetPwdController ()<UITextFieldDelegate>
{
    UITextField *_phonefiled;
    UITextField *_codefiled;
    UITextField *_passfiled;
    UITextField *_confirPassfiled;
}
@end

@implementation GetPwdController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    return 4;
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
    if (indexPath.row == 0) {
        VerifyCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VerifyCodeCell"];
        if (!cell) {
            cell = [Utility nibWithName:@"VerifyCodeCell" index:0];
            cell.lineRightInset = 36;
            cell.lineLeftInset = 36;
            cell.inputView.delegate = self;
            cell.inputView.returnKeyType = UIReturnKeyNext;
            cell.codeAPI = kAPIForgotPass;
            _phonefiled = cell.inputView;
            _phonefiled.placeholder = @"请输入手机号";
        }
        return cell;
        
    }else{
        InputCell *cellInput = (InputCell*)[tableView dequeueReusableCellWithIdentifier:InputCellIdentifire];
        if (!cellInput) {
            cellInput  = (InputCell*)[Utility nibWithName:InputCellIdentifire index:0];
        }

        switch (indexPath.row) {
            case 1:
                cellInput.lineRightInset = 36;
                cellInput.lineLeftInset = 36;
                cellInput.textInputView.delegate = self;
                [cellInput setNeedsDisplay];
                [cellInput.iconView setImage:[UIImage imageNamed:@"dl_vericode"]];
                [cellInput setPlaceholder:@"验证码"];
                cellInput.textInputView.returnKeyType = UIReturnKeyNext;
                _codefiled = cellInput.textInputView;
                break;
            case 2:
                cellInput.lineRightInset = 36;
                cellInput.lineLeftInset = 36;
                cellInput.textInputView.delegate = self;
                [cellInput setNeedsDisplay];
                [cellInput.iconView setImage:[UIImage imageNamed:@"dl_password"]];
                [cellInput setPlaceholder:@"密码"];
                cellInput.textInputView.returnKeyType = UIReturnKeyNext;
                _passfiled = cellInput.textInputView;
                break;
            case 3:
                cellInput.lineRightInset = 36;
                cellInput.lineLeftInset = 36;
                cellInput.textInputView.delegate = self;
                [cellInput setNeedsDisplay];
                [cellInput.iconView setImage:[UIImage imageNamed:@"dl_password2"]];
                [cellInput setPlaceholder:@"确认密码"];
                cellInput.textInputView.returnKeyType = UIReturnKeyDone;
                _confirPassfiled = cellInput.textInputView;
                break;
            default:
                break;
        }
                return cellInput;
    }
    // Configure the cell...
}

#pragma mark - textFiledDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _phonefiled) {
        [_phonefiled resignFirstResponder];
        while (_phonefiled.isFirstResponder) {
            
        }
        [_codefiled becomeFirstResponder];
        return true;
    }else if (textField == _codefiled) {
        [_codefiled resignFirstResponder];
        while (_codefiled.isFirstResponder) {
            
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
    if (_phonefiled.text == nil||_phonefiled.text.length == 0) {
        [CustomToast showMessageOnWindow:@"手机号不能为空！"];
    }else if(_codefiled.text == nil||_codefiled.text.length == 0){
        [CustomToast showMessageOnWindow:@"请输入验证码！"];
    }else if(_passfiled.text == nil||_passfiled.text.length == 0){
        [CustomToast showMessageOnWindow:@"密码不能为空！"];
    }else if ([self isEmpty:_confirPassfiled.text]||[self isEmpty:_passfiled.text]){
        [CustomToast showMessageOnWindow:@"密码中不能包含空格！"];
    }else if(_confirPassfiled.text == nil||_confirPassfiled.text.length == 0){
        [CustomToast showMessageOnWindow:@"确认密码不能为空！"];
    }else{
        
        MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        hud.labelText = @"正在修改";
        NSDictionary *params  = @{
                                  @"mobile":_phonefiled.text,
                                  @"new_password1":_passfiled.text,
                                  @"new_password2":_confirPassfiled.text,
                                  @"smscode":_codefiled.text
                                  };
        CRWeekRef(self);
        [MSGRequestManager MKUpdate:kAPIForgotPass params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            NSMutableDictionary *userinfo = [LocalManager objectForKey:kUserInfoKey];
            [userinfo setObject:params[@"new_password1"] forKey:@"password"];
            [LocalManager storeObject:userinfo forKey:kUserInfoKey];
            [__self.navigationController popViewControllerAnimated:true];
            [CustomToast showMessageOnWindow:@"修改成功"];

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
    [_phonefiled resignFirstResponder];
    [_passfiled resignFirstResponder];
    [_codefiled resignFirstResponder];
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
