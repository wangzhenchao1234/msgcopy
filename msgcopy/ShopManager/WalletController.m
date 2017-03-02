//
//  WalletController.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/3.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import "WalletController.h"
#import "DropDownloadView.h"
#import "VirtualPayCell.h"

#define TopInset (160)


@interface WalletController ()<UITableViewDataSource,UITableViewDelegate,DropDownloadViewDelegate>
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
@property (nonatomic,retain) NSMutableArray *all;
@property (nonatomic,retain) NSMutableArray *close;
@property (nonatomic,retain) NSMutableArray *complete;
@property (nonatomic,retain) UIView *headerView;
@end

@implementation WalletController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
    [self configTitleView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)configTableView
{
    self.automaticallyAdjustsScrollViewInsets = false;
    
    _all = [[NSMutableArray alloc] initWithCapacity:0];
    _close =[[NSMutableArray alloc] initWithCapacity:0];
    _complete = [[NSMutableArray alloc] initWithCapacity:0];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.contentInset = UIEdgeInsetsMake(NAV_H, 0, 0, 0);
    [self.view addSubview:_tableView];
    
    _headerView =[[ UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, TopInset)];
    
    _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, TopInset)];
    _backImageView.backgroundColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
    _backImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    
    [_headerView addSubview:_backImageView];
    
    UILabel *ye = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 130, 22)];
    ye.font = [UIFont systemFontOfSize:18];
    ye.textColor = [UIColor whiteColor];
    ye.text = @"我的账户余额：";
    
    [_headerView addSubview:ye];
    
    _virtualMoneyView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 20,80 )];
    _virtualMoneyView.center = CGPointMake(self.view.width/2.0f,NAV_H+32);
    _virtualMoneyView.textAlignment = NSTextAlignmentCenter;
    _backImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [_headerView addSubview:_virtualMoneyView];
    self.tableView.tableHeaderView = _headerView;
    
    
    CRWeekRef(self);
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [__self refreshDataSource];
    }];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [__self loadMoreDataSource];
    }];
    [self.tableView.header beginRefreshing];
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
-(void)refreshDataSource{
    
    CRWeekRef(self);
    [MSGRequestManager MKGet:kAPIShopCartTotoal params:@{@"shopstore_id":CRString(@"%d",kCurApp.aid)} success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSString *money = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (money) {
            NSMutableAttributedString *moneyText = [[NSMutableAttributedString alloc] initWithString:CRString(@"%.2f",[money floatValue]) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:44],NSForegroundColorAttributeName:CRCOLOR_WHITE}];
            NSAttributedString *yuan = [[NSAttributedString alloc] initWithString:@" 元" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:CRCOLOR_WHITE}];
            [moneyText appendAttributedString:yuan];
            _virtualMoneyView.attributedText = moneyText;
        }
        [_all removeAllObjects];
        [_close removeAllObjects];
        [_complete removeAllObjects];
        [__self.tableView reloadData];
        NSString *status = @"";
        if (curType==1) {
            status = @"complete";
        }else if(curType == 2){
            status = @"closed";
        }
        NSDictionary *params = @{
                                 @"status":status
                                 };
        
        [MSGRequestManager Get:kAPIShopCartWallet(kCurApp.aid, _shop.sid, 0, @"0") params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
            NSArray *datas = data;
            [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               
                BillingRecordEntity *record = [BillingRecordEntity buildWithJson:obj];
                if (curType == 0) {
                    [_all addObject:record];
                }else if(curType == 1){
                    [_complete addObject:record];
                }else{
                    [_close addObject:record];
                }
            }];
            [__self.tableView.header endRefreshing];
            if (curType == 0) {
                if (_all.count == 0) {
                    [__self showBlankView:@"暂无任何记录"];
                }else{
                    [__self showBlankView:@""];
                }
            }else if(curType == 1){
                if (_complete.count == 0) {
                    [__self showBlankView:@"暂无任何记录"];
                }else{
                    [__self showBlankView:@""];
                }
            }else{
                if (_close.count == 0) {
                    [__self showBlankView:@"暂无任何记录"];
                }else{
                    [__self showBlankView:@""];
                }
            }
            if (datas.count<20) {
                [self.tableView.footer noticeNoMoreData];
            }else{
                [self.tableView.footer resetNoMoreData];
            }
            [__self.tableView reloadData];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__self.tableView.header endRefreshing];
            [CustomToast showMessageOnWindow:msg];
        }];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__self.tableView.header endRefreshing];
        [CustomToast showMessageOnWindow:msg];
    }];

}

-(void)loadMoreDataSource{
    
    NSString *status = @"";
    NSString *time = @"0";
    BillingRecordEntity *record = nil;
    if (curType==0) {
        record = _all.lastObject;
     
    }else if(curType == 1){
        status = @"complete";
        record = _complete.lastObject;

    }else if(curType == 2){
        status = @"closed";
        record = _close.lastObject;
    }
    if (record) {
        time = [[record.time stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSDictionary *params = @{
                             @"status":status
                             };
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIShopCartWallet(kCurApp.aid, _shop.sid, 2, time) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__self.tableView.footer endRefreshing];
        NSArray *datas = data;
        [datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            BillingRecordEntity *record = [BillingRecordEntity buildWithJson:obj];
            if (curType == 0) {
                [_all addObject:record];
            }else if(curType == 1){
                [_complete addObject:record];
            }else{
                [_close addObject:record];
            }
        }];
        if (datas.count<20) {
            [self.tableView.footer noticeNoMoreData];
        }else{
            [self.tableView.footer resetNoMoreData];
        }
        [__self.tableView.header endRefreshing];
        if (curType == 0) {
            if (_all.count == 0) {
                [__self showBlankView:@"暂无任何记录"];
            }else{
                [__self showBlankView:@""];
            }
        }else if(curType == 1){
            if (_complete.count == 0) {
                [__self showBlankView:@"暂无任何记录"];
            }else{
                [__self showBlankView:@""];
            }
        }else{
            if (_close.count == 0) {
                [__self showBlankView:@"暂无任何记录"];
            }else{
                [__self showBlankView:@""];
            }
        }
        [__self.tableView reloadData];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__self.tableView.footer endRefreshing];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
        
        return self.complete.count;
    }
    return self.close.count;
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
   if(curType == 1){
        datas = self.complete;
    }else if(curType == 2){
        datas = self.close;
    }
    BillingRecordEntity *record = CRArrayObject(datas, indexPath.row);
    if (record) {
        if (record.type == WalletTypeComplete) {
            cell.titleView.text = @"收入";
            cell.moneyView.textColor = [UIColor colorFromHexRGB:@"669900"];
            cell.moneyView.text = CRString(@"+%.2f",record.money);
            NSArray *times = [record.time componentsSeparatedByString:@"T"];
            if (times.count > 1) {
                cell.descrView.text = times[0];
            }else{
                cell.descrView.text = @"";
            }
        }else{
            
            cell.titleView.text = @"取消";
            cell.moneyView.textColor = [UIColor colorFromHexRGB:@"669900"];
            cell.moneyView.text = CRString(@"-%.2f",record.money);
            NSArray *times = [record.time componentsSeparatedByString:@"T"];
            if (times.count > 1) {
                cell.descrView.text = times[0];
            }else{
                cell.descrView.text = @"";
            }
        }

    }
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
    NSArray *menus = @[@"全部",@"收入",@"取消"];
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
    curType = index;
    NSArray *menus = @[@"全部",@"收入",@"取消"];
    [_droipButton setTitle:menus[index] forState:UIControlStateNormal];
    [_droipButton sizeToFit];
    [_droipButton setImageEdgeInsets:UIEdgeInsetsMake(0, _droipButton.width+5, 0, -_droipButton.width+5)];
    self.navigationItem.titleView = _droipButton;
    [self.tableView.header beginRefreshing];

    if(index == 0){
        if (self.all.count == 0) {
            [self.tableView.header beginRefreshing];
        }else{
            [self showBlankView:@""];
            [self.tableView.header beginRefreshing];

        }
    }else if(index == 1){
        
        if (self.complete.count == 0) {
            [self.tableView.header beginRefreshing];
        }else{
            [self showBlankView:@""];
            [self.tableView.header beginRefreshing];

        }
        
    }else{
        if (self.close.count == 0) {
            [self.tableView.header beginRefreshing];
        }else{
            [self showBlankView:@""];
            [self.tableView.header beginRefreshing];

        }
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

@implementation BillingRecordEntity

+(instancetype)buildWithJson:(NSDictionary*)json
{
    BillingRecordEntity *entity = [[BillingRecordEntity alloc] init];
    entity.money = [[Utility dictionaryValue:json forKey:@"money"] floatValue];
    NSString *type = [Utility dictionaryValue:json forKey:@"type"];
    if ([type isEqualToString:@"closed"]) {
        entity.type = WalletTypeClosed;
    }else{
        entity.type = WalletTypeComplete;
    }
    entity.time = [Utility dictionaryValue:json forKey:@"time"];
    return entity;
}
@end
