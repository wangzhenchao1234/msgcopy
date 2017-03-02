//
//  BandCardController.m
//  msgcopy
//
//  Created by wngzc on 15/9/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "BandCardController.h"
#import "GVPickerView.h"

@interface BandCardController ()<GVPickerViewDelegate>
{
    NSArray *cells;
    NSArray *titles;
    NSArray *bankNames;
    NSArray *bankCodes;
    NSString *curBankID;
    NSString *curCerType;

}
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *bankCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cardCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cernoCell;
@property (weak, nonatomic) IBOutlet UITextField *phoneFiled;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *cardField;
@property (weak, nonatomic) IBOutlet UITextField *cerField;
@property (retain,nonatomic) GVPickerView *bankPicker;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (retain,nonatomic) GVPickerView *typePicker;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UITextField *bankField;

@end

@implementation BandCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定银行卡";
    cells = @[@[_cardCell,_bankCell],@[_nameCell,_cernoCell],@[_phoneCell]];
    self.tableView.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1];
    _bankPicker = [[GVPickerView alloc] init];
    _bankPicker.delegate = self;
    _agreeButton.layer.cornerRadius = 5;
    _agreeButton.clipsToBounds = true;
    [_agreeButton setBackgroundColor:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor]];
    curCerType = @"1";
    /*
     中国工商银行	1021000
     中国农业银行	1031000
     中国银行股份有限公司 1041000
     中国建设银行股份有限公司 1051000
     交通银行	3011000
     中信银行	3021000
     中国光大银行 3031000
     中国民生银行	3051000
     平安银行	3135840
     招商银行	3085840
     中国邮政储蓄银行有限责任公司 0025840
     兴业银行	8010000
     */
    
    bankNames = @[@"中国工商银行",@"中国农业银行",@"中国银行股份有限公司",@"中国建设银行股份有限公司",@"交通银行",@"中信银行",@"中国光大银行",@"中国民生银行",@"平安银行",@"招商银行",@"中国邮政储蓄银行有限责任公司",@"兴业银行"];
    bankCodes = @[@"1021000",@"1031000",@"1041000",@"1051000",@"3011000",@"3021000",@"3031000",@"3051000",@"3135840",@"3085840",@"0025840",@"8010000"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self resignAll];
}
-(void)resignAll{
    [_phoneFiled resignFirstResponder];
    [_nameField resignFirstResponder];
    [_cardField resignFirstResponder];
    [_cerField resignFirstResponder];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return cells.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSArray *items = cells[section];
    return items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    
    NSArray *items = cells[indexPath.section];
    return items[indexPath.row];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.section == 0&&indexPath.row ==1 ) {
        
        /**
         * 选择银行
         */
        [self resignAll];
        [_bankPicker show];
        
    }
}
# pragma mark -  pickerDelegate

-(NSInteger)numberOfComponentsInPickerView:(GVPickerView *)pickerView;
{
    return 1;
}

-(NSInteger)pickerView:(GVPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return bankNames.count;
}

-(NSString*)pickerView:(GVPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return CRArrayObject(bankNames, row);
    
}

-(void)changePickerSubmite:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString *name = @"";
    name = CRArrayObject(bankNames, row);
    curBankID = CRArrayObject(bankCodes, row);
    _bankField.text = name;
}


# pragma mark - textFieldDelegate


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}

-(IBAction)submite:(id)sender{
    
    if ([_phoneFiled.text length] == 0) {
        [MBProgressHUD showError:@"请输入手机号码" toView:AppWindow];
    }else if ([_phoneFiled.text length] != 11){
        [MBProgressHUD showError:@"手机号码格式错误" toView:AppWindow];
    }else if ([_nameField.text length] == 0) {
        [MBProgressHUD showError:@"请输入开户名" toView:AppWindow];
    }else if ([_cardField.text length] == 0){
        [MBProgressHUD showError:@"请输入银行卡号" toView:AppWindow];
    }else if ([_cerField.text length] == 0) {
        [MBProgressHUD showError:@"请输入证件号码" toView:AppWindow];
    }else if ([curBankID length] == 0) {
        [MBProgressHUD showError:@"请选择银行" toView:AppWindow];
    }else{
        [MBProgressHUD showMessag:nil toView:AppWindow];
        NSDictionary *params = @{
                                 @"mobile":_phoneFiled.text,
                                 @"bankId":curBankID,
                                 @"accountName":_nameField.text,
                                 @"bankAccountNo":_cardField.text,
                                 @"certType":curCerType,
                                 @"certNo":_cerField.text
                                 };
        CRWeekRef(self);
        [MSGRequestManager Post:kAPIBindCard params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [MBProgressHUD hideHUDForView:AppWindow animated:false];
            NSInteger state = [data[@"orderStatus"] integerValue];
            NSString *errorMsg = data[@"errorMessage"];
            if (state ==1 ) {
                if (_bindCallBack) {
                    _bindCallBack(true);
                    [__self.navigationController popViewControllerAnimated:true];
                }
                [CustomToast showMessageOnWindow:@"绑定成功"];
            }else{
                [CustomToast showMessageOnWindow:errorMsg];
            }
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [MBProgressHUD hideHUDForView:AppWindow animated:false];
            [CustomToast showMessageOnWindow:msg];
        }];
    }
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
