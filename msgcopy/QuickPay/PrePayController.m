//
//  PrePayController.m
//  msgcopy
//
//  Created by wngzc on 15/9/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "PrePayController.h"
#import "JKCountDownButton.h"

@interface PrePayController ()
{
    NSDictionary *placeOrderResult;
}
@property (nonatomic,retain)BankCardEntity *prePayCard;
@property (nonatomic,copy)  NSString *orderNo;
@property (weak, nonatomic) IBOutlet UITextField *codeView;
@property (weak, nonatomic) IBOutlet JKCountDownButton *retryButton;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *footerButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *codeCell;

@end

@implementation PrePayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付";
    _footerView.height = 64;
    _footerButton.layer.cornerRadius = 5;
    _footerButton.clipsToBounds = true;
    [_footerButton setBackgroundColor:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor]];
    [_retryButton setBackgroundColor:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor]];
    [self doPlaceOrder];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)setOrderNo:(NSString *)orderNo bankCard:(BankCardEntity *)card
{
    self.orderNo = orderNo;
    self.prePayCard = card;
}
-(void)doPlaceOrder{
    
    [MBProgressHUD showMessag:nil toView:AppWindow];
    NSDictionary *params = @{
                             @"orderNo":_orderNo,
                             @"bankId":_prePayCard.bankId,
                             @"bankAccountNo":_prePayCard.bankAccountNo,
                             @"idCardNo":_prePayCard.certNo,
                             @"mobile":_prePayCard.mobile,
                             @"accountName":_prePayCard.accountName
                             };
    CRWeekRef(self);
    [MSGRequestManager Post:kAPIPlaceOrder params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [MBProgressHUD hideHUDForView:AppWindow animated:false];
        
        NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%@",params);
        
        /*
         {
         amount = "1.10";
         errorCode = 0000;
         errorMessage = "\U8bf7\U6c42\U5904\U7406\U6210\U529f";
         fastPayToken = 1CWSZZA05JC5JTY30LPZM9NAE0ADH4IO;
         orderNo = 1509116316952;
         orderStatus = 1;
         signatureInfo = a0907f894f47e57ee5a2d804400268ad;
         }
         */
        
        placeOrderResult = data;
        NSInteger orderStatus = [data[@"orderStatus"] integerValue];
        if (orderStatus == 1) {
            [CustomToast showMessageOnWindow:@"短信验证码已发送请注意查收"];
            _retryButton.enabled = NO;
            //button type要 设置成custom 否则会闪动
            [_retryButton startWithSecond:60];
            [_retryButton didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
                NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
                return title;
            }];
            [_retryButton didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
                countDownButton.enabled = YES;
                return @"重新获取";
            }];
        }else{
            NSString *msg = data[@"errorMessage"];
            [CustomToast showMessageOnWindow:msg];
            [__self.navigationController popViewControllerAnimated:false];
        }

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
        [MBProgressHUD hideHUDForView:AppWindow animated:false];
        [__self.navigationController popViewControllerAnimated:false];
    }];
}

- (IBAction)retryGetCode:(JKCountDownButton*)sender {
    
    MBProgressHUD *hud =  [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
    [AppWindow addSubview:hud];
    NSString *fastPayToken = placeOrderResult[@"fastPayToken"];
    NSDictionary *params = @{@"orderNo":_orderNo,@"fastPayToken":fastPayToken};
    
    [MSGRequestManager Post:kAPIGetPayCode params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {

        [hud hide:true];
        NSInteger status = [data[@"status"] integerValue];
        if (status!=1) {
            [CustomToast showMessageOnWindow:data[@"errorMessage"]];
            sender.enabled = true;
            return;
        }
        sender.enabled = NO;
        //button type要 设置成custom 否则会闪动
        [sender startWithSecond:60];
        [sender didChange:^NSString *(JKCountDownButton *countDownButton,int second) {
            NSString *title = [NSString stringWithFormat:@"剩余%d秒",second];
            return title;
        }];
        [sender didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
            countDownButton.enabled = YES;
            return @"重新获取";
        }];
        [CustomToast showMessageOnWindow:@"验证码已发送"];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];

    
}
- (IBAction)doPay:(id)sender {
    
    if (_codeView.text.length == 0 || !_codeView.text) {
        [CustomToast showMessageOnWindow:@"请输入验证码！"];
        return;
    }
    [MBProgressHUD showMessag:nil toView:AppWindow];
    NSString *fastPayToken = placeOrderResult[@"fastPayToken"];
    /*
     {
     "orderNo": "",
     "phoneToken": "",
     "fastPayToken": ""
     }
     */

    NSDictionary *params =
    @{
        @"orderNo":_orderNo,
        @"fastPayToken":fastPayToken,
        @"phoneToken":_codeView.text
    };
    CRWeekRef(self);
    [MSGRequestManager Post:kAPIQuickPay params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {

        [MBProgressHUD hideHUDForView:AppWindow animated:false];
        NSInteger state = [data[@"orderStatus"] integerValue];
        NSInteger count = __self.navigationController.viewControllers.count;
        UIViewController *Vc = __self.navigationController.viewControllers[count - 3];
        if (state != 1) {
            [__self.navigationController popToViewController:Vc animated:true];
            if (_payCallBack) {
                _payCallBack(false);
            }
            [MBProgressHUD showSuccess:CRString(@"交易失败:%@",data[@"errorMessage"]) toView:AppWindow];
            return;
        }
        [CustomToast showMessageOnWindow:@"付款成功"];
        [__self.navigationController popToViewController:Vc animated:true];
        if (_payCallBack) {
            _payCallBack(true);
        }
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [MBProgressHUD hideHUDForView:AppWindow animated:false];
        [CustomToast showMessageOnWindow:msg];
    }];
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
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    NSLog(@"tableViewCellLog");
    return _codeCell;
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
