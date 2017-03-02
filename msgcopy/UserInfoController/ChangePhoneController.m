//
//  ChangePhoneController.m
//  msgcopy
//
//  Created by wngzc on 15/8/3.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ChangePhoneController.h"

@interface ChangePhoneController ()<UITextFieldDelegate>
{
    UITextField *_phonefiled;
    UITextField *_codefiled;
}
@end

@implementation ChangePhoneController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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
        [footerView addTarget:self action:@selector(doVerify:) forControlEvents:UIControlEventTouchUpInside];
        [footerView setTitle:@"验      证" state:UIControlStateNormal];
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
            cell.codeAPI = kAPIVerifyCode;
        }
        if (_actionType == PHONE_ACTION_TYPE_VERYFY) {
            _phonefiled.text = kCurUser.lastName;
            _phonefiled.userInteractionEnabled = false;
        }else{
            _phonefiled.userInteractionEnabled = true;
        }
        _phonefiled = cell.inputView;
        _phonefiled.placeholder = @"请输入手机号";
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
    [self doVerify:nil];
    
    return true;
}
#pragma mark - actions
-(void)doVerify:(id)sender{
    
    if (_phonefiled.text == nil||_phonefiled.text.length == 0) {
        [CustomToast showMessageOnWindow:@"手机号码不能为空！"];
    }else if(![VerifyHanddler verifyPhone:_phonefiled.text]){
        [CustomToast showMessageOnWindow:@"手机号码格式不正确"];
    }else if(_codefiled.text == nil||_codefiled.text.length == 0){
        [CustomToast showMessageOnWindow:@"验证码不能为空"];
    }else{
        MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        hud.labelText = @"正在验证";
        CRWeekRef(self);
        
        if (_actionType == PHONE_ACTION_TYPE_MODIFY) {
            NSDictionary *params = @{
                                     @"last_name":_phonefiled.text,
                                     @"smscode":_codefiled.text
                                     };
            [MSGRequestManager MKUpdate:kAPIBindPhone params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                NSMutableDictionary *userinfo = [LocalManager objectForKey:kLoginUserKey];
                [userinfo setObject:_codefiled.text forKey:@"last_name"];
                kCurUser.lastName = _codefiled.text;
                [hud hide:true];
                NSUInteger count =  __self.navigationController.viewControllers.count;
                if (count >= 3) {
                    UIViewController *pushVC = __self.navigationController.viewControllers[count - 2];
                    if ([pushVC isKindOfClass:[ChangePhoneController class]]) {
                        UIViewController *prePushVC = __self.navigationController.viewControllers[count - 3];
                        [__self.navigationController popToViewController:prePushVC animated:true];
                    }else{
                        [__self.navigationController popViewControllerAnimated:true];
                    }

                }
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                [CustomToast showMessageOnWindow:msg];
            }];
        }else if(_actionType == PHONE_ACTION_TYPE_VERYFY){
            [MSGRequestManager MKGet:kAPIVerifyPhone(_phonefiled.text, _codefiled.text) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                ChangePhoneController *phone = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ChangePhoneController"];
                phone.actionType = PHONE_ACTION_TYPE_MODIFY;
                [__self.navigationController pushViewController:phone animated:true];
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [hud hide:true];
                if (code == 404) {
                    [CustomToast showMessageOnWindow:@"验证码无效"];
                }else{
                    [CustomToast showMessageOnWindow:msg];
                }
            }];
        }
    }
}
/**
 *  关闭键盘
 */
-(void)resignAllFirstResponder{
    [_phonefiled resignFirstResponder];
    [_codefiled resignFirstResponder];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
