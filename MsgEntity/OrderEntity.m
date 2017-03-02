//
//  OrderEntity.m
//  PSClient
//
//  Created by Hackintosh on 15/9/29.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "OrderEntity.h"

@implementation OrderEntity
+(instancetype)buildWithJson:(NSDictionary *)json
{
    OrderEntity *order = [[OrderEntity alloc] init];
    order.state = [OrderEntity stateFor:[Utility dictionaryNullValue:json forKey:@"state"]];
    order.payType = [OrderEntity payTypeFor:[Utility dictionaryNullValue:json forKey:@"pay_type"]];
    order.qr = [Utility dictionaryNullValue:json forKey:@"qr"];
    
    order.used_prize = [Utility dictionaryNullValue:json forKey:@"used_prize"];
    order.ctime = [Utility dictionaryNullValue:json forKey:@"ctime"];
    order.rebate_type = [OrderEntity rebateType:[Utility dictionaryNullValue:json forKey:@"rebate_type"]];
    order.order_id = [Utility dictionaryNullValue:json forKey:@"order_id"];
    order.order_id_fp = [Utility dictionaryNullValue:json forKey:@"order_id_fp"];
    order.money_detail = [Utility dictionaryNullValue:json forKey:@"money_detail"];
    order.oid = [[Utility dictionaryNullValue:json forKey:@"id"] integerValue];
    order.goods_master = [Utility dictionaryNullValue:json forKey:@"goods_master"];
    order.is_del = [[Utility dictionaryNullValue:json forKey:@"is_del"] boolValue];
    order.reason = [Utility dictionaryNullValue:json forKey:@"reason"];
    order.ftime = [Utility dictionaryNullValue:json forKey:@"ftime"];
    order.shopstore_id = [[Utility dictionaryNullValue:json forKey:@"shopstore_id"] integerValue];
    order.used_points = [Utility dictionaryNullValue:json forKey:@"used_points"];
    order.refundstatus = [Utility dictionaryNullValue:json forKey:@"goods_master"];
    order.express_type = [OrderEntity stateFor:[Utility dictionaryNullValue:json forKey:@"express_type"]];
    order.status = [Utility dictionaryNullValue:json forKey:@"status"];
    NSDictionary *reciver = [Utility dictionaryNullValue:json forKey:@"receiver"];
    order.receiver = [OrderPayReciver buildWithJson:reciver];
    NSArray *goodsJson = [Utility dictionaryValue:json forKey:@"goods"];
    NSMutableArray *goods = [[NSMutableArray alloc] init];
    [goodsJson enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        OrderGoodEntity *good = [OrderGoodEntity buildWithJson:obj];
        [goods addObject:good];
    }];
    order.goods = goods;
    return order;
}
+(OrderDistributionState)stateFor:(NSString*)stateStr
{
    if ([stateStr isEqualToString:@"undelivery"]) {
        return OrderDistributionStateUndeliver;
    }else if([stateStr isEqualToString:@"delivery"]){
        return OrderDistributionStateDelivery;
    }else{
        return OrderDistributionStateDeliveried;
    }
}

+(OrderPayType)payTypeFor:(NSString*)stypeStr
{
    if ([stypeStr isEqualToString:@"ALIPAY"]) {
        return OrderPayTypeAliPay;
    }else if([stypeStr isEqualToString:@"WEIXINPAY"]){
        return OrderPayTypeWeixinPay;
    }else if([stypeStr isEqualToString:@"VIRTUALPAY"]){
        return OrderPayTypeVirtual;
    }else if([stypeStr isEqualToString:@"POINTS"]){
        return OrderPayTypePoints;
    }else if([stypeStr isEqualToString:@"UNIONPAY"]){
        return OrderPayTypeUnionPay;
    }else if([stypeStr isEqualToString:@"HUIJINPAY"]){
        return OrderPayTypeJinBaoPay;
    }else{
        return OrderPayTypeOnDel;
    }
}
+(OrderPayRebateType)rebateType:(NSString*)type{
    
    if ([type isEqualToString:@"undelivery"]) {
        return OrderPayRebateTypeFirst;
    }else if([type isEqualToString:@"phonepay"]){
        return OrderPayRebateTypeFullNone;
    }else if([type isEqualToString:@"fullsale"]){
        return OrderPayRebateTypeFullSale;
    }if([type isEqualToString:@"fullgift"]){
        return OrderPayRebateTypeFullSale;
    }else{
        return OrderPayRebateTypePhone;
    }
}

-(NSString*)orderPayType
{
    if (self.payType == OrderPayTypeAliPay) {
        return @"支付宝";
    }else if (self.payType == OrderPayTypeJinBaoPay){
        return @"快捷支付";
    }else if (self.payType == OrderPayTypeWeixinPay){
        return @"微信";
    }else if (self.payType == OrderPayTypeVirtual){
        return @"余额";
    }else if (self.payType == OrderPayTypeUnionPay){
        return @"银联";
    }else if (self.payType == OrderPayTypeOnDel){
        return @"货到付款";
    }else{
        return @"积分";
    }
}
-(NSString*)orderStatus
{
    return [OrderEntity orderStatus:self.status];
}
+(NSString*)orderStatus:(NSString*)status
{
    if ([status isEqualToString:@"undeal"]){
        return @"待支付";
    }else if([status isEqualToString:@"undeliver"] || [status isEqualToString:@"unpaid"]){
        return @"待发货";
    }else if([status isEqualToString:@"deliver"]){
        return @"已发货";
    }else if([status isEqualToString:@"complete"]){
        return @"已完成";
    }else if([status isEqualToString:@"closing"]){
        return @"取消中";
    }else if([status isEqualToString:@"closed"]){
        return @"已关闭";
    }else {
        return @"未知";
    }
    
}
-(NSString*)distributionType
{
    if (self.express_type == OrderDistributionStateDeliveried){
        return @"配送完成";
    }else if (self.express_type == OrderDistributionStateUndeliver){
        return @"未配送";
    }else{
        return @"配送中";
    }
}

-(NSString*)rebateType{
    
    if (self.rebate_type == OrderPayRebateTypeFirst ) {
        return @"首次支付";
    }else if(self.rebate_type == OrderPayRebateTypeFirst){
        return @"客户端支付";
    }else if(self.rebate_type == OrderPayRebateTypeFirst){
        return @"满额减钱";
    }if(self.rebate_type == OrderPayRebateTypeFirst){
        return @"满额送礼物";
    }else{
        return @"没有优惠信息";
    }
}

@end

@implementation OrderPayReciver

+(instancetype)buildWithJson:(NSDictionary *)json
{
    OrderPayReciver *reciver = [[OrderPayReciver alloc] init];
    reciver.post_code = [Utility dictionaryNullValue:json forKey:@"post_code"];
    reciver.name = [Utility dictionaryNullValue:json forKey:@"name"];
    reciver.isDefault = [[Utility dictionaryValue:json forKey:@"default"] boolValue];
    reciver.phone = [Utility dictionaryNullValue:json forKey:@"phone"];
    reciver.address = [Utility dictionaryNullValue:json forKey:@"address"];
    reciver.oid = [[Utility dictionaryNullValue:json forKey:@"id"] integerValue];
    return reciver;
}

@end

@implementation OrderGoodEntity
+(instancetype)buildWithJson:(NSDictionary *)json
{
    OrderGoodEntity *good = [[OrderGoodEntity alloc] init];
    good.stock_taking_url = [Utility dictionaryNullValue:json forKey:@"stock_taking_url"];
    good.is_del = [[Utility dictionaryNullValue:json forKey:@"is_del"] boolValue];
    good.app_id = [[Utility dictionaryNullValue:json forKey:@"app_id"] integerValue];
    good.total = [[Utility dictionaryNullValue:json forKey:@"total"] integerValue];
    good.gid = [[Utility dictionaryNullValue:json forKey:@"id"] integerValue];
    good.goods_type = [Utility dictionaryNullValue:json forKey:@"goods_type"];
    good.pay_type = [Utility dictionaryNullValue:json forKey:@"pay_type"];
    good.img_small = [Utility dictionaryNullValue:json forKey:@"img_small"];
    good.goods_id = [Utility dictionaryNullValue:json forKey:@"goods_id"];
    good.title = [Utility dictionaryNullValue:json forKey:@"title"];
    good.desc = [Utility dictionaryNullValue:json forKey:@"desc"];
    good.source_app_id = [[Utility dictionaryNullValue:json forKey:@"source_app_id"] integerValue];
    good.shopstore_id = [[Utility dictionaryNullValue:json forKey:@"shopstore_id"] integerValue];
    good.unit_price = [[Utility dictionaryNullValue:json forKey:@"unit_price"] floatValue];
    good.paydelivery = [[Utility dictionaryNullValue:json forKey:@"paydelivery"] boolValue];
    good.kwargs = [Utility dictionaryNullValue:json forKey:@"kwargs"];
    good.user_name = [Utility dictionaryNullValue:json forKey:@"user_name"];
    good.call_back_url = [Utility dictionaryNullValue:json forKey:@"call_back_url"];
    good.goods_master = [Utility dictionaryNullValue:json forKey:@"goods_master"];
    good.c_time = [Utility dictionaryNullValue:json forKey:@"c_time"];
    good.is_recharge = [[Utility dictionaryNullValue:json forKey:@"is_recharge"] boolValue];
    good.source_app_init_arg = [Utility dictionaryNullValue:json forKey:@"source_app_init_arg"];
    good.points = [[Utility dictionaryNullValue:json forKey:@"points"] integerValue];
    return good;
}

@end




