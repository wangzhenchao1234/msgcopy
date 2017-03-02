//
//  VerifyEmailController.m
//  msgcopy
//
//  Created by wngzc on 15/5/22.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "VerifyEmailController.h"

static NSString *successStr = @"激活信息已发送，请您查看邮件\n若暂未收到激活信息请点击重新发送";
static NSString *failedStr = @"验证邮件发送失败，请点击重新发送！";


@interface VerifyEmailController ()
@property(nonatomic,copy)NSString *infoStr;
@end

@implementation VerifyEmailController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (LoginState) {
        return;
    }
    [self performSelector:@selector(doSubmit:) withObject:nil afterDelay:1];
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
    [footerView setTitle:@"获取激活信息" state:UIControlStateNormal];
    return footerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *InputCellIdentifire = @"InputCell";
    if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = MSGFont(14);
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.text = _infoStr;
        cell.textLabel.backgroundColor = CRCOLOR_CLEAR;
        return cell;
    }
    InputCell *cellInput = (InputCell*)[tableView dequeueReusableCellWithIdentifier:InputCellIdentifire];
    if (!cellInput) {
        cellInput  = (InputCell*)[Utility nibWithName:InputCellIdentifire index:0];
        cellInput.lineRightInset = 36;
        cellInput.lineLeftInset = 36;
        cellInput.textInputView.text = _email;
        [cellInput.iconView setImage:[UIImage imageNamed:@"dl_email"]];
        cellInput.textInputView.placeholder = @"请输入新邮箱地址";
        cellInput.textInputView.userInteractionEnabled = _canEdite;
        [cellInput setNeedsDisplay];
    }
    return cellInput;
    // Configure the cell...
}

#pragma mark - actions
/**
 *  注册
 *
 *  @param sender
 */
- (void)doSubmit:(id)sender {
    
    InputCell *cellInput = (InputCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *email = cellInput.textInputView.text;
    if ([email length] == 0) {
        [CustomToast showMessageOnWindow:@"请输入邮箱地址"];
        return;
    }
    MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
    [AppWindow addSubview:hud];
    hud.labelText = @"正在发送验证邮件";
    NSDictionary *params  = @{
                              @"email":email,
                              };
    CRWeekRef(self);
    [MSGRequestManager MKUpdate:kAPIVerifyEmail params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        _infoStr = successStr;
        [__self.tableView reloadData];
        if (_isThirdLogin) {
            
            
            [OauthManager registerThirdPlt:@"weixin" params:@{@"username":_email,@"password":_thirdLoginPassword} openID:_openID success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [self handdleResult];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [CustomToast showMessageOnWindow:data];
            }];
            
            
        }
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        _infoStr = msg;
        [hud hide:true];
        [__self.tableView reloadData];
    }];
    
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


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
