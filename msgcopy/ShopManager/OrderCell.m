//
//  OrderCell.m
//  PSClient
//
//  Created by Hackintosh on 15/9/28.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import "OrderCell.h"
#import "OrderEntity.h"

@interface OrderCell()
{
    OrderEntity *curOrder;
    NSString *curDistributionType;
    
}
@end

@implementation OrderCell

- (void)awakeFromNib {
    // Initialization code
    _shopButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _shopButton.layer.borderWidth = 0.5;
    _shopButton.clipsToBounds = true;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)buildWithOrder:(OrderEntity *)order
{
    _orderNumberLabel.text = order.order_id_fp;
    curOrder = order;
    __block CGFloat price = 0;
    [order.goods enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OrderGoodEntity *good = obj;
        price += good.total*good.unit_price;
    }];
    _priceLabel.text = CRString(@"%.2f元",price);
    _orderTime.text = [order.ctime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    _orderNumberLabel.text = order.order_id_fp;
    [_shopButton setTitle:order.goods_master forState:UIControlStateNormal];
    OrderGoodEntity *good = order.goods.firstObject;
    [_product1Pic sd_setImageWithURL:CRURL(good.img_small)];
    _product1Title.text = good.title;
    _product1Descr.text = good.desc;
    _product1Price.text = CRString(@"￥%.2f x %d元",good.unit_price,(int)good.total);
    if (order.goods.count>1) {
        OrderGoodEntity *good = order.goods[1];
        [_product2Pic sd_setImageWithURL:CRURL(good.img_small)];
        _product2Title.text = good.title;
        _product2Descr.text = good.desc;
        _product2Price.text = CRString(@"￥%.2f x %d元",good.unit_price,(int)good.total);
    }
    curDistributionType = [order orderStatus];
    _DistribState.text = curDistributionType;
    [_actionButton setTitle:@"修改状态" forState:UIControlStateNormal];
    _actionButton.hidden = !([order.status isEqualToString:@"undeliver"]||[order.status isEqualToString:@"unpaid"]);
}
//-(NSString*)distributionType:(OrderDistributionState)state{
//    
//    if (state == OrderDistributionStateDeliveried){
//        return @"配送完成";
//    }else if (state == OrderDistributionStateUndeliver){
//        return @"未配送";
//    }else{
//        return @"配送中...";
//    }
//}
//-(NSString*)distributionActionState:(OrderDistributionState)state{
//    
//    if (state == OrderDistributionStateDeliveried){
//        return @"已完成";
//    }else if (state == OrderDistributionStateUndeliver){
//        return @"开始配送";
//    }else{
//        return @"配送完成";
//    }
//}
- (IBAction)doChangeState:(id)sender {
 
    [GVAlertView showAlert:@"提示" message:@"是否确认修改？" confirmButton:@"确定" action:^{
        
        [MSGRequestManager MKUpdate:kAPIShopUpdateOrder(curOrder.oid) params:@{@"status":@"deliver"} success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            _actionButton.hidden = true;
            curOrder.status = @"deliver";
            _DistribState.text = [curOrder orderStatus];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [CustomToast showMessageOnWindow:msg];
        }];
        
    } cancelTitle:@"取消" action:^{
        
    }];

}
@end
