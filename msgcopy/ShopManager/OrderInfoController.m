//
//  OrderInfoController.m
//  PSClient
//
//  Created by Hackintosh on 15/9/28.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "OrderInfoController.h"
#import "OrderContactCell.h"
#import "PayCell.h"
#import "OrderEntity.h"
#import "OrderProductCell.h"
#import "OrderInfoCell.h"

@interface OrderInfoController ()

@end

@implementation OrderInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单详情";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    if (section == 0) {
        return 3;
    }
    return _order.goods.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0 ) {
            return 104;
        }else if (indexPath.row == 1){
            return 92;
        }else{
            return 151;
        }
    }
    return 113;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if(indexPath.row == 0){
            OrderContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
            cell.nameView.text = _order.receiver.name;
            cell.phoneView.text = _order.receiver.phone;
            cell.addressView.text = _order.receiver.address;
            return cell;
        }else if (indexPath.row == 1){
            PayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PayCell"];
             __block float price = 0;
            [_order.goods enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OrderGoodEntity *good = obj;
                price += good.total*good.unit_price;
            }];
            cell.realPayMoney.text = CRString(@"%.2f元",price);
            cell.youhui.text = [_order rebateType];
            
            return cell;
        }else if (indexPath.row == 2){
            OrderInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderInfoCell"];
            cell.orderTime.text = [_order.ctime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            cell.orderNo.text = _order.order_id_fp;
            cell.distrbState.text = [self distributionType:_order.express_type];
            return cell;
        }
    }
    OrderProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell"];
    OrderGoodEntity *good = CRArrayObject(_order.goods, indexPath.row);
    if (good) {
        [cell.productPIc sd_setImageWithURL:CRURL(good.img_small)];
        cell.productDescr.text = good.desc;
        cell.productTitle.text = good.title;
        cell.productPrice.text = CRString(@"￥%.2f x %d元",good.unit_price,(int)good.total);
    }
    return cell;
}

-(NSString*)distributionType:(OrderDistributionState)state{
    
    if (state == OrderDistributionStateDeliveried){
        return @"配送完成";
    }else if (state == OrderDistributionStateUndeliver){
        return @"未配送";
    }else{
        return @"配送中...";
    }
}
-(NSString*)distributionActionState:(OrderDistributionState)state{
    
    if (state == OrderDistributionStateDeliveried){
        return @"已完成";
    }else if (state == OrderDistributionStateUndeliver){
        return @"开始配送";
    }else{
        return @"配送完成";
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
