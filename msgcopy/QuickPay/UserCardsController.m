//
//  UserCardsController.m
//  msgcopy
//
//  Created by wngzc on 15/9/16.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "UserCardsController.h"
#import "BandCardController.h"
#import "PrePayController.h"

@interface UserCardsController ()
{
    NSMutableArray *userBanks;
    NSArray *bankNames;
    NSArray *bankCodes;
    NSInteger curSe;
}
@property (weak, nonatomic) IBOutlet UILabel *orderNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation UserCardsController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"选择银行卡";
    _headerView.height = 180;
    bankNames = @[@"中国工商银行",@"中国农业银行",@"中国银行股份有限公司",@"中国建设银行股份有限公司",@"交通银行",@"中信银行",@"中国光大银行",@"中国民生银行",@"平安银行",@"招商银行",@"中国邮政储蓄银行有限责任公司",@"兴业银行"];
    bankCodes = @[@"1021000",@"1031000",@"1041000",@"1051000",@"3011000",@"3021000",@"3031000",@"3051000",@"3135840",@"3085840",@"0025840",@"8010000"];
    _headerView.backgroundColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
    [_nextButton setBackgroundColor:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor]];
    _nextButton.layer.cornerRadius = 5;
    _nextButton.clipsToBounds = true;
    userBanks = [[NSMutableArray alloc] init];
    [self setBackButton:@"ic_back" action:@selector(goBack:) target:self];
    [self getUserBankCards];
    curSe = 0;
    
    //Mark test
//    _money = @"-100.0";
//    _orderNo = @"TE4422211223";
    
    _moneyLabel.text = CRString(@"-%@",_money);
    _orderNoLabel.text = _orderNo;
    _orderNoLabel.hidden = true;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
# pragma mark - 设置返回按钮

-(void)setBackButton:(NSString*)image action:(SEL)action target:(id)target{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 27, 27);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backBarButton;
}
-(void)goBack:(id)sender{
    
    [self.navigationController popViewControllerAnimated:true];
    if (_payCallBack) {
        _payCallBack(false);
    }
}
-(void)getUserBankCards{
    
    [MBProgressHUD showMessag:@"正在加载" toView:AppWindow];
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIUserBankCards(kCurUserName) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [userBanks removeAllObjects];
        if (CRJSONIsArray(data)) {
            NSArray *list = data;
            [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BankCardEntity *entity = [BankCardEntity buildByJson:obj];
                [userBanks addObject:entity];
            }];
            [__self.tableView reloadData];
            [MBProgressHUD hideHUDForView:AppWindow animated:false];
        }else{
            [CustomToast showMessageOnWindow:@"获取银行卡信息失败请重试"];
        }
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [MBProgressHUD hideHUDForView:AppWindow animated:false];
        [CustomToast showMessageOnWindow:@"获取银行卡信息失败请重试"];
    }];
}
- (IBAction)next:(id)sender {
    
    [self performSegueWithIdentifier:@"payOrder" sender:self];
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
    return userBanks.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *BankCellID = @"BankCell";
    static NSString *AddCellID = @"AddCell";

    if (indexPath.row == userBanks.count) {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddCellID];
        UILabel *label = (UILabel*)[cell.contentView viewWithTag:100];
        label.textColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BankCellID];
    // Configure the cell...
    BankCardEntity *bank = userBanks[indexPath.row];
    [bankCodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:bank.bankId]) {
            cell.textLabel.text = CRString(@"%@(尾号%@)",CRArrayObject(bankNames, idx),[bank.bankAccountNo substringFromIndex:bank.bankAccountNo.length - 4]);
            *stop = true;
        }
    }];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (curSe == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.row == userBanks.count) {
        return;
    }
    [tableView.visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITableViewCell *cell = obj;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    curSe = indexPath.row;
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addBankCard"]) {
        
        CRWeekRef(self);
        BandCardController *band = (BandCardController*)segue.destinationViewController;
        [band setBindCallBack:^(BOOL result) {
            if (result) {
                [__self getUserBankCards];
            }
        }];
    
    }else if([segue.identifier isEqualToString:@"payOrder"]){
        PrePayController *prePay = (PrePayController*)segue.destinationViewController;
        prePay.payCallBack = _payCallBack;
        [prePay setOrderNo:_orderNo bankCard:userBanks[curSe]];
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

@implementation BankCardEntity

/*
 "username": "1234",
 "authtoken": "b9c6be32532772db433c6e0cfefc0813",
 "mobile": "15801334581",
 "certNo": "341003199111200531",
 "certType": "1",
 "accountName": "蒋宁",
 "bankId": "1051000",
 "bankAccountNo": "6217000010057198270",
 "id": 1
 */

+(instancetype)buildByJson:(NSDictionary *)json{
    
    BankCardEntity *entity = [[BankCardEntity alloc] init];
    entity.username = [Utility dictionaryNullValue:json forKey:@"username"];
    entity.authtoken = [Utility dictionaryNullValue:json forKey:@"authtoken"];
    entity.mobile = [Utility dictionaryNullValue:json forKey:@"mobile"];
    entity.certNo = [Utility dictionaryNullValue:json forKey:@"certNo"];
    entity.certType = [Utility dictionaryNullValue:json forKey:@"certType"];
    entity.accountName = [Utility dictionaryNullValue:json forKey:@"accountName"];
    entity.bankId = [Utility dictionaryNullValue:json forKey:@"bankId"];
    entity.bankAccountNo = [Utility dictionaryNullValue:json forKey:@"bankAccountNo"];
    entity.bid = [[Utility dictionaryNullValue:json forKey:@"id"] integerValue];
    return entity;
}

@end

