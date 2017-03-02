//
//  OrderController.m
//  PSClient
//
//  Created by Hackintosh on 15/9/25.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import "OrderController.h"
#import "OrderCell.h"
#import "OrderEntity.h"

@interface OrderController ()
{
    NSMutableArray *datas;
    NSString *express_type;
    BlankView *blank;
}
@end

@implementation OrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.contentInset = UIEdgeInsetsMake(NAV_H+44, 0, 0, 0);
    blank = [Utility nibWithName:@"BlankView" index:0];
    blank.actionView.hidden = true;
    blank.imageView.hidden = true;
    datas = [[NSMutableArray alloc] init];
    CRWeekRef(self);
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [__self refresh];
    }];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [__self loadMore];
    }];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    express_type = nil;
    _orderType = OrderTypeAll;
    switch (_orderType) {
        case OrderTypeAll:{
            blank.descrView.text = @"您没有任何支付订单";
        }
            break;
        case OrderTypePoints:{
            blank.descrView.text = @"您没有任何支付的订单";
        }
            break;
        default:{
        }
            break;
    }
    [self.tableView.header beginRefreshing];
}

-(void)refresh
{
    NSDictionary *params = nil;
    if (_orderType == OrderTypeAll) {
        params = @{
                   @"paytype":@"all"
                   };
    }else{
        params = @{
                   @"paytype":@"POINTS"
                   };
    }
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIShopCartOrder(kCurApp.aid, _shop.sid,0,@"0") params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__self.tableView.header endRefreshing];
        NSArray *list = data;
        NSMutableArray *newDatas = [[NSMutableArray alloc] init];
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            OrderEntity *order = [OrderEntity buildWithJson:obj];
            [newDatas addObject:order];
        }];
        datas = newDatas;
        if (datas.count == 0) {
            __self.tableView.backgroundView = blank;
        }else{
            __self.tableView.backgroundView = nil;
        }
        if (datas.count<20) {
            [__self.tableView.footer noticeNoMoreData];
        }else{
            [__self.tableView.footer resetNoMoreData];
        }
        [__self.tableView reloadData];

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
        [__self.tableView.header endRefreshing];
    }];
    
}
-(void)loadMore
{
    NSString *time = @"0";
    OrderEntity *order = datas.lastObject;
    if (order) {
        time = order.ctime;
        time = [[time stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSDictionary *params = nil;
    if (_orderType == OrderTypeAll) {
        params = @{
                   @"paytype":@"all"
                   };
    }else{
        params = @{
                   @"paytype":@"POINTS"
                   };
    }

    CRWeekRef(self);
    [MSGRequestManager Get:kAPIShopCartOrder(kCurApp.aid, _shop.sid,2,time) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__self.tableView.footer endRefreshing];
        NSArray *list = data;
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            OrderEntity *order = [OrderEntity buildWithJson:obj];
            [datas addObject:order];
        }];
        if (list.count<20) {
            [__self.tableView.footer noticeNoMoreData];
        }else{
            [__self.tableView.footer resetNoMoreData];
        }
        [__self.tableView reloadData];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
        [__self.tableView.footer endRefreshing];
    }];

}

-(void)setTitleLabel:(UILabel *)titleLabel
{
    _titleLabel = titleLabel;
    switch (_orderType) {
            
        case OrderTypeAll:
            _titleLabel.text = @"现金支付";
            break;
            
        case OrderTypePoints:
            _titleLabel.text = @"积分支付";
            
            break;
        default:
            break;
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderCell *cell = (OrderCell*)[tableView dequeueReusableCellWithIdentifier:@"OrderCell"];
    OrderEntity *order = CRArrayObject(datas, indexPath.row);
    cell.actionButton.hidden = true;
    if (order) {
        [cell buildWithOrder:order];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderEntity *order = CRArrayObject(datas, indexPath.row);
    if (order.goods.count>1) {
        return 380;
    }else{
        return 281;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderEntity *order = CRArrayObject(datas, indexPath.row);
    [self performSegueWithIdentifier:@"ShowInfo" sender:order];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *vc = segue.destinationViewController;
    [vc setValue:sender forKey:@"order"];
}
//-(void)insertOrder:(OrderEntity*)order{
//    [datas insertObject:order atIndex:0];
//    if (datas.count == 0) {
//        self.tableView.backgroundView = blank;
//    }else{
//        self.tableView.backgroundView = nil;
//    }
//    [self.tableView reloadData];
//}

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


#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    OrderInfoController *info = segue.destinationViewController;
    info.order = (OrderEntity*)sender;
}
 */
//-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    self.tableView.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height + 44, 0, 0, 0);
//    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationController.navigationBar.height + [UIApplication sharedApplication].statusBarFrame.size.height + 44, 0, 0, 0);
//
//}
@end
