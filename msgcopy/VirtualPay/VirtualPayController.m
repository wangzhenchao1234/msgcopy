//
//  VirtualPayController.m
//  Kaoke
//
//  Created by wngzc on 15/4/28.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "VirtualPayController.h"
#import "VirtualInfoController.h"
#import "VirtualPayCell.h"
#import "DropDownloadView.h"

#define TopInset 160

@interface VirtualPayController ()<UITableViewDataSource,UITableViewDelegate,DropDownloadViewDelegate>
{
    NSInteger curType;
}
@property(nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) UIImageView *backImageView;
@property (nonatomic,retain) UIButton *droipButton;
@property (nonatomic,retain) UILabel *virtualMoneyView;
@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,retain) UIImageView *arrow;
@property (nonatomic,retain) NSArray *titles;
@property (nonatomic,retain) DropDownloadView *menuView;
@property (nonatomic,retain) UILabel *blankView;
@property (nonatomic,retain) UIToolbar *toolBar;
@property (nonatomic,retain)NSMutableArray *all;
@property (nonatomic,retain)NSMutableArray *pay;
@property (nonatomic,retain)NSMutableArray *rech;
@end

@implementation VirtualPayController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configTableView];
    [self configTitleView];
    [self configToolBar];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getAllPayInfo];
}

-(void)configTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(TopInset, 0, 0, 0);
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    
    _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -TopInset, self.view.width, TopInset)];
    _backImageView.backgroundColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
    
    [self.tableView addSubview:_backImageView];
    
    UILabel *ye = [[UILabel alloc] initWithFrame:CGRectMake(15, -TopInset + 15, 130, 22)];
    ye.font = [UIFont systemFontOfSize:18];
    ye.textColor = [UIColor whiteColor];
    ye.text = @"我的账户余额：";
    
    [self.tableView addSubview:ye];
    
    _virtualMoneyView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 20,80 )];
    _virtualMoneyView.center = CGPointMake(self.view.width/2.0f,-(TopInset + NAV_H)/2.0f + 32);
    _virtualMoneyView.textAlignment = NSTextAlignmentCenter;
    [self.tableView addSubview:_virtualMoneyView];
    
}

-(void)titleClick:(id)sender
{
    if (_menuView.isShown) {
        [_menuView hidden];
        return;
    }
    [_menuView show];
}

-(void)configTitleView
{

    _menuView = [Utility nibWithName:@"DropDownloadView" index:0];
    _menuView.delegate = self;
    [_menuView.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    
    _droipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _droipButton.titleLabel.font = MSGFont(18);
    [_droipButton setTitleColor:CRCOLOR_BLACK forState:UIControlStateNormal];
    [_droipButton setTitle:@"全部" forState:UIControlStateNormal];
    [_droipButton sizeToFit];
    [_droipButton setImage:[UIImage imageNamed:@"ic_drop_down"] forState:UIControlStateNormal];
    [_droipButton sizeToFit];
    [_droipButton setImageEdgeInsets:UIEdgeInsetsMake(0, _droipButton.width+5, 0, -_droipButton.width+5)];
    [_droipButton addTarget:self action:@selector(dropMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _droipButton;
    
    _menuView  = [Utility nibWithName:@"DropDownloadView" index:0];
    _menuView.titles = _titles;
    _menuView.width = AppWindow.width;
    _menuView.height = AppWindow.height;
    _menuView.delegate = self;
    
}
-(void)configToolBar
{
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    [self.view addSubview:_toolBar];
    UIButton *pay = [UIButton buttonWithType:UIButtonTypeCustom];
    pay.frame = CGRectMake(0, 0, 100, 30);
    [pay setTitle:@"充值" forState:UIControlStateNormal];
    [pay addTarget:self action:@selector(doPay:) forControlEvents:UIControlEventTouchUpInside];
    [pay setTitleColor:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor] forState:UIControlStateNormal];
    [pay setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];

    [self.view addSubview:_toolBar];
    UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:pay];
    _toolBar.items = @[space1,item,space2];
    [_toolBar setBackgroundImage:[UIImage imageNamed:@"bg_bavBar_white"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
}
-(void)doPay:(id)sender
{
    //支付
    WebAppEntity *app = CRWebAppTitle(@"virtualpay");
    if (app) {
        /**
         *  webapp指向其他标准app
         *  @param app appentity
         */
        WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
        webAppCon.appid = app.aid;
        webAppCon.params = nil;
        webAppCon.goBackAction = nil;
        webAppCon.callBackAction = nil;
        [CRRootNavigation() pushViewController:webAppCon animated:true];    }
}

-(void)getAllPayInfo
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [AppWindow addSubview:hud];
    [hud show:true];
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIUserVirtualMoney(kCurAppID,kCurUserName) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSString *money = [Utility dictionaryValue:data forKey:@"money"];
        if (money) {
            NSMutableAttributedString *moneyText = [[NSMutableAttributedString alloc] initWithString:CRString(@"%@",money) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:50],NSForegroundColorAttributeName:CRCOLOR_WHITE}];
            NSAttributedString *yuan = [[NSAttributedString alloc] initWithString:@" 元" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:CRCOLOR_WHITE}];
            [moneyText appendAttributedString:yuan];
            _virtualMoneyView.attributedText = moneyText;
        }
        [MSGRequestManager Get:kAPIVirtualPay(kCurAppID, kCurUser.userName) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            NSMutableArray *all = [NSMutableArray new];
            NSMutableArray *pay = [NSMutableArray new];
            NSMutableArray *rech = [NSMutableArray new];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *item = obj;
                VirtualPayEntity *entity = [VirtualPayEntity buildWithJson:item];
                [all addObject:entity];
                if (entity.type == VirtualTypeReachUnionPay||entity.type ==VirtualTypeRechAliPay||entity.type ==VirtualTypeRechOffLine||entity.type == VirtualTypeRechDianQuan||entity.type == VirtualTypeRechWeiXin||entity.type == VirtualTypeRefund) {
                    [rech addObject:entity];
                }else{
                    [pay addObject:entity];
                }
            }];
            if (all.count == 0&&all!=nil) {
                [__self showBlankView:@"暂无任何记录"];
            }else if(all == nil){
                [__self showBlankView:@"网络连接错误，请检查网络"];
            }else{
                [__self showBlankView:@""];
            }
            self.all = all;
            self.rech = rech;
            self.pay = pay;
            [__self.tableView reloadData];

        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            [CustomToast showMessageOnWindow:msg];
        }];

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    
//    CGFloat yOffset  = scrollView.contentOffset.y;
//    if (yOffset < -(TopInset+NAV_H)) {
//        CGRect f = _backImageView.frame;
//        f.origin.y = yOffset;
//        f.size.height =  -yOffset;
//        _backImageView.frame = f;
//    }
//    
//}
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
    if (curType == 0) {
        return self.all.count;
    }
    if (curType == 1) {
       
        return self.rech.count;
    }
    return self.pay.count;
}

-(void)showBlankView:(NSString*)text
{
    CRWeekRef(self);
    if (!_blankView) {
        _blankView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _blankView.textColor = [UIColor colorFromHexRGB:@"bababa"];
        _blankView.font = [UIFont systemFontOfSize:16];
        _blankView.textAlignment = NSTextAlignmentCenter;
    }
    _blankView.text = text;
    __self.tableView.tableFooterView = _blankView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VirtualPayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VirtualPayCell"];
    if (!cell) {
        cell = [Utility nibWithName:@"VirtualPayCell" index:0];
    }
    // Configure the cell...
    NSArray *datas = self.all;
    if (curType == 1) {
        datas = self.rech;
    }else if(curType == 2){
        datas = self.pay;
    }
    VirtualPayEntity *pay = datas[indexPath.row];
    [cell buildWithData:pay];
    return cell;
}

# pragma mark - 点击下拉菜单

-(void)dropMenuClick:(id)sender{
    //do something
    if (_menuView.isShown) {
        [_menuView hidden];
        return;
    }
    [_menuView reloadData];
    [_menuView show];

}

# pragma mark - DropViewDelegate

-(NSString*)dropView:(DropDownloadView *)dropView titleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *menus = @[@"全部",@"收入",@"支出"];
    return menus[indexPath.row];
}
-(NSInteger)dropView:(DropDownloadView *)dropView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
-(void)dropView:(DropDownloadView *)dropView selectMenuAtIndext:(NSInteger)index
{
    [self selectMenuAtIndext:index];
}
-(void)cancelButtonClicked
{
    [_menuView hidden];
}

-(void)selectMenuAtIndext:(NSInteger)index
{
    if(index == 0){
        if (self.all.count == 0&&self.all!=nil) {
            [self showBlankView:@"暂无任何记录"];
        }else if(self.all == nil){
            [self showBlankView:@"网络连接错误，请检查网络"];
        }else{
            [self showBlankView:@""];
        }
    }else if(index == 1){
        
        if (self.rech.count == 0&&self.rech!=nil) {
            [self showBlankView:@"暂无任何收入记录"];
        }else if(self.rech == nil){
            [self showBlankView:@"网络连接错误，请检查网络"];
        }else{
            [self showBlankView:@""];
        }

    }else{
        if (self.pay.count == 0&&self.pay!=nil) {
            [self showBlankView:@"暂无任何支出记录"];
        }else if(self.pay == nil){
            [self showBlankView:@"网络连接错误，请检查网络"];
        }else{
            [self showBlankView:@""];
        }

    }
    curType = index;
    NSArray *menus = @[@"全部",@"收入",@"支出"];
    [_droipButton setTitle:menus[index] forState:UIControlStateNormal];
    [_droipButton sizeToFit];
    [_droipButton setImageEdgeInsets:UIEdgeInsetsMake(0, _droipButton.width+5, 0, -_droipButton.width+5)];
    self.navigationItem.titleView = _droipButton;
    [self.tableView reloadData];
    
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

@implementation VirtualPayEntity

+(instancetype)buildWithJson:(NSDictionary*)json
{
    VirtualPayEntity *entity = [[VirtualPayEntity alloc] init];
    entity.descr = [Utility dictionaryValue:json forKey:@"descr"];
    NSString *type = [Utility dictionaryValue:json forKey:@"type"];
    if ([type isEqualToString:@"rech_zhifubao"]) {
        entity.type = VirtualTypeRechAliPay;
        entity.paymoney = [[Utility dictionaryValue:json forKey:@"v_money"] floatValue];

    }else if ([type isEqualToString:@"rech_yinlian"]){
        entity.type = VirtualTypeReachUnionPay;
        entity.paymoney = [[Utility dictionaryValue:json forKey:@"v_money"] floatValue];

    }else if ([type isEqualToString:@"rech_xianxia"]){
        entity.type = VirtualTypeRechOffLine;
        entity.paymoney = [[Utility dictionaryValue:json forKey:@"v_money"] floatValue];

    }else if ([type isEqualToString:@"pay_xianxia"]){
        entity.type = VirtualTypePayOffLine;
        entity.paymoney = [[Utility dictionaryValue:json forKey:@"paymoney"] floatValue];
        
    }else if([type isEqualToString:@"rech_weixin"]){
        entity.type = VirtualTypeRechWeiXin;
        entity.paymoney = [[Utility dictionaryValue:json forKey:@"v_money"] floatValue];
        
    }else if([type isEqualToString:@"pay_dianjuan"]){
        entity.type = VirtualTypePayOffLine;
        entity.paymoney = [[Utility dictionaryValue:json forKey:@"paymoney"] floatValue];

    }else if ([type isEqualToString:@"rech_dianjuan"]){
        entity.type = VirtualTypeRechDianQuan;
        entity.paymoney = [[Utility dictionaryValue:json forKey:@"v_money"] floatValue];

    }else if([type isEqualToString:@"pay_xianshang"])
    {
        entity.type = VirtualTypePayOnLine;
        entity.paymoney = [[Utility dictionaryValue:json forKey:@"paymoney"] floatValue];
    }
    else if([type isEqualToString:@"refund"])
    {
        entity.type = VirtualTypeRefund;
        entity.paymoney = [[Utility dictionaryValue:json forKey:@"refundmoney"] floatValue];
    }

    entity.time = [Utility dictionaryValue:json forKey:@"time"];
    return entity;
}

@end
