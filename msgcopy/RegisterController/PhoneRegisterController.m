//
//  PhoneRegisterController.m
//  msgcopy
//
//  Created by Gavin on 15/5/22.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "PhoneRegisterController.h"

@interface PhoneRegisterController ()<UITextFieldDelegate>
{
    UITextField *_phonefiled;
    UITextField *_codefiled;
}
@end

@implementation PhoneRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 2;
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
    if (indexPath.row == 0) {
        VerifyCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VerifyCodeCell"];
        if (!cell) {
            cell = [Utility nibWithName:@"VerifyCodeCell" index:0];
            cell.inputView.userInteractionEnabled = false;
            cell.lineRightInset = 36;
            cell.lineLeftInset = 36;
            cell.inputView.delegate = self;
            cell.codeAPI = kAPIVerifyCode;
            cell.inputView.text = _registerParams[@"username"];
        }
        _phonefiled = cell.inputView;
        _phonefiled.returnKeyType = UIReturnKeyNext;
        return cell;
        
    }else{
        
        InputCell *cellInput = (InputCell*)[tableView dequeueReusableCellWithIdentifier:InputCellIdentifire];
        if (!cellInput) {
            cellInput  = (InputCell*)[Utility nibWithName:InputCellIdentifire index:0];
            cellInput.lineRightInset = 36;
            cellInput.lineLeftInset = 36;
            cellInput.textInputView.delegate = self;
            [cellInput setNeedsDisplay];
            [cellInput.iconView setImage:[UIImage imageNamed:@"dl_vericode"]];
            [cellInput setPlaceholder:@"验证码"];
        }
        _codefiled = cellInput.textInputView;
        _codefiled.returnKeyType = UIReturnKeyDone;
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
    }
    [_codefiled resignFirstResponder];
    [self doRegister:nil];
    
    return true;
}
#pragma mark - actions
-(void)doRegister:(id)sender{
    
    if (_phonefiled.text == nil||_phonefiled.text.length == 0) {
        [CustomToast showMessageOnWindow:@"手机号码不能为空！"];
    }else if(![VerifyHanddler verifyPhone:_phonefiled.text]){
        [CustomToast showMessageOnWindow:@"手机号码格式不正确"];
    }else{
        MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        hud.labelText = @"正在验证";
        CRWeekRef(self);
        [MSGRequestManager MKGet:kAPIVerifyPhone(_phonefiled.text, _codefiled.text) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            hud.labelText = @"正在注册";
            [MSGRequestManager Post:kAPIRegister params:_registerParams success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                [__self handdleRegisterResult:_registerParams];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                [CustomToast showMessageOnWindow:msg];
                
            }];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            [CustomToast showMessageOnWindow:msg];
        }];
    }
    
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
            if (_isThildLogin) {
                NSString*username = _registerParams[@"username"];
                NSString*password = _registerParams[@"password1"];
                [OauthManager registerThirdPlt:@"weixin" params:@{@"username":username,@"password":password} openID:_openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [self handdleResult];
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [CustomToast showMessageOnWindow:data];
                }];
                
                
            }else{
                [self.navigationController popViewControllerAnimated:true];
            }
            
        }
        
    }else{
        
        //发送验证邮件
        
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
 *  关闭键盘
 */
-(void)resignAllFirstResponder{
    [_phonefiled resignFirstResponder];
    [_codefiled resignFirstResponder];
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
