//
//  ResetUserController.m
//  msgcopy
//
//  Created by wngzc on 15/8/3.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ResetUserController.h"
#import "OauthManager.h"

@interface ResetUserController ()<UITextFieldDelegate>
{
    NSString *_loginPlaceholder;
    UITextField *_userfiled;
    UITextField *_passfiled;
    UITextField *_confirPassfiled;
}
@end

@implementation ResetUserController

+(void)showWithDebind:(ThirdDebindType)type target:(UIViewController*)target complete:(void(^)(BOOL result,id data))complete
{
    ResetUserController *user = [[ResetUserController alloc] init];
    user.debindCompleteAction = complete;
    user.debindType = type;
    UINavigationController *navigation = nil;
    if ([target isKindOfClass:[UINavigationController class]]) {
        navigation = (UINavigationController*)target;
    }else if([target isKindOfClass:[UIViewController class]]){
        UIViewController *vc = target;
        if (vc.navigationController) {
            navigation = vc.navigationController;
        }
    }
    if (!navigation) {
        navigation = CRRootNavigation();
        return;
    }
    [navigation pushViewController:user animated:true];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self intilizedDataSource];
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}
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

//datasource

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
        [footerView addTarget:self action:@selector(doSubmite:) forControlEvents:UIControlEventTouchUpInside];
        [footerView setTitle:@"提     交" state:UIControlStateNormal];
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
    [self doSubmite:nil];
    
    return true;
}
#pragma mark - actions

-(void)doSubmite:(id)sender{
    
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
    }else{
        MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        hud.labelText = @"正在修改";
        NSDictionary *params  = @{
                                  @"old_username":kCurUserName,
                                  @"new_username":_passfiled.text,
                                  @"new_pwd":_confirPassfiled.text,
                                  };
        [MSGRequestManager MKUpdate:kAPIUserFix params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            kCurUser.userName = _userfiled.text;
            kCurUser.passWord = _passfiled.text;
            
            switch (_debindType) {
                case ThirdDebindTypeQQ:
                {
                    [OauthManager deBindQQPlt:kCurUser.qq_openid success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        _debindCompleteAction(true,@"解绑成功");
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        _debindCompleteAction(false,@"解绑失败,用户名密码已修改成功");
                    }];
                }
                    break;
                case ThirdDebindTypeWX:
                {
                    [OauthManager deBindSinaPlt:kCurUser.sina_uid success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        _debindCompleteAction(true,@"解绑成功");

                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        _debindCompleteAction(false,@"解绑失败,用户名密码已修改成功");
                    }];
                    
                }
                    break;
                case ThirdDebindTypeSina:
                {
                    [OauthManager deBindWxPlt:kCurUser.wx_openid success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        _debindCompleteAction(true,@"解绑成功");
                        
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        _debindCompleteAction(false,@"解绑失败,用户名密码已修改成功");
                    }];
                }
                    break;
                default:
                    break;
            }
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            _debindCompleteAction(false,@"解绑失败,用户名密码已修改失败");
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
