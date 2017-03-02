//
//  BindEmailController.m
//  msgcopy
//
//  Created by wngzc on 15/9/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "BindEmailController.h"
#import "VerifyEmailController.h"
#import "EmailVerifyCell.h"

#import "InputCell.h"

@interface BindEmailController()

@property(nonatomic,copy)NSString *infoStr;
@property(nonatomic,retain)EmailVerifyCell *verCell;
@property(nonatomic,retain)InputCell *inputCell;


@end

@implementation BindEmailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inputCell  = (InputCell*)[Utility nibWithName:@"InputCell" index:0];
    _inputCell.lineRightInset = 36;
    _inputCell.lineLeftInset = 36;
    _inputCell.textInputView.text = _email;
    [_inputCell.iconView setImage:[UIImage imageNamed:@"dl_email"]];
    _inputCell.textInputView.placeholder = @"请输入新邮箱地址";
    _inputCell.textInputView.userInteractionEnabled = false;
    [_inputCell setNeedsDisplay];

    _verCell = (EmailVerifyCell*)[Utility nibWithName:@"EmailVerifyCell" index:0];
    _verCell.inputView.placeholder = @"请输入验证码";
    _verCell.params = @{@"appid":CRString(@"%d",kCurApp.aid),@"receiver":_email};
    _verCell.codeAPI = kAPIGetEmailCode;
    _verCell.lineRightInset = 36;
    _verCell.lineLeftInset = 36;
    [_inputCell setNeedsDisplay];

    // Do any additional setup after loading the view.
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
    if (indexPath.row == 2) {
        return 60;
    }
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 55;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    ActionFooterView *footerView = [Utility nibWithName:@"ActionFooterView" index:0];
    [footerView addTarget:self action:@selector(doSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [footerView setTitle:@"下一步" state:UIControlStateNormal];
    return footerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        return _verCell;
    }
    return _inputCell;
    // Configure the cell...
}

#pragma mark - actions
/**
 *  注册
 *
 *  @param sender
 */
- (void)doSubmit:(id)sender {
    
    if ([_verCell.inputView.text length] == 0) {
        [CustomToast showMessageOnWindow:@"请输入验证码"];
        return;
    }
    NSString *email = _inputCell.textInputView.text;
    MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
    [AppWindow addSubview:hud];
    hud.labelText = @"正在验证";
    NSDictionary *params  = @{
                              @"email":email,
                              @"emailcode":_verCell.inputView.text
                              };
    CRWeekRef(self);
    [MSGRequestManager MKPost:kAPIVerifyEmailCode params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [__self.tableView reloadData];
        VerifyEmailController *email = [Utility controllerInStoryboard:@"Main" withIdentifier:@"VerifyEmailController"];
        email.canEdite = true;
        email.email = nil;
        [__self.navigationController pushViewController:email animated:true];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
        [__self.tableView reloadData];
    }];
    
}
@end
