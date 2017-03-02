//
//  OrderEntity.h
//  PSClient
//
//  Created by Hackintosh on 15/9/29.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 
 {
    "status": "undeliver",
    "pay_type": "VIRTUALPAY",
    "qr": "http://smedia.msgcopy.net/smedia/qr/1443002434.9229901.jpg",
    "used_prize": "0.6",
    "ctime": "2015-09-23T18:00:34",
    "rebate_type": "phonepay",
    "order_id": "eee22d5261d911e58c7100163e002c35",
    "order_id_fp": "1509237174217",
    "receiver": 
            {
                "post_code": "332000",
                "name": "a",
                "default": true,
                "phone": "15426584654",
                "address": "福建省福州asdf",
                "id": 1607
            },
    "money_detail": "{\"product_count\":0.5}",
    "id": 6687,
    "goods_master": "kk_xyym",
    "is_del": false,
    "reason": null,
    "goods": [
                {
                    "stock_taking_url": "/wapi/form/goods/2207/stock/",
                    "is_del": true,
                    "app_id": 34,
                    "total": 1,
                    "id": 8215,
                    "goods_type": "B",
                    "pay_type": "money",
                    "img_small": "http://smedia.msgcopy.net/smedia/app/sda1/m/411569f22df71bf4c246bf26b870bd2a/image/2015/06/u27875587684248141089fm21gp0_5.jpg",
                    "goods_id": 2207,
                    "title": "云２这是一个非常长的东西,呵呵",
                    "source_app_id": 5,
                    "unit_price": 1.1,
                    "paydelivery": false,
                    "kwargs": "{\"type\":\"form_record\",\"id\":9001}",
                    "user_name": "1234",
                    "call_back_url": "/wapi/form/goods/callback/",
                    "desc": "云２这是一个非常长的东西,呵呵",
                    "goods_master": "kk_xyym",
                    "c_time": "2015-09-23T18:00:13",
                    "is_recharge": false,
                    "source_app_init_arg": "{\"id\":3378,\"color\":1}",
                    "points": 0,
                    "shopstore_id": 34
            }
        ],
    "ftime": null,
    "shopstore_id": 34,
    "op_master": "1234",
    "used_points": "0",
    "refundstatus": [],
    "express_type": "undelivery"
 },
 
 
 */

typedef NS_OPTIONS(NSUInteger, OrderDistributionState) {
    OrderDistributionStateUndeliver = 0,
    OrderDistributionStateDelivery = 1 << 0,
    OrderDistributionStateDeliveried = 1 << 1
};

typedef NS_OPTIONS(NSUInteger, OrderPayRebateType) {
    OrderPayRebateTypeFirst = 0,
    OrderPayRebateTypePhone = 1 << 0,
    OrderPayRebateTypeFullSale = 1 << 1,
    OrderPayRebateTypeFullGift = 1 << 2,
    OrderPayRebateTypeFullNone = 1 << 3,
};

typedef NS_OPTIONS(NSUInteger, OrderPayType){
    
    OrderPayTypeVirtual = 0,
    OrderPayTypeAliPay = 1 << 0,
    OrderPayTypeUnionPay = 1 << 1,
    OrderPayTypeWeixinPay = 1 << 2,
    OrderPayTypeJinBaoPay = 1 << 3,
    OrderPayTypePoints = 1 << 4,
    OrderPayTypeOnDel = 1 << 5,
};
@class OrderPayReciver;

@interface OrderEntity : NSObject
@property(nonatomic,assign) OrderDistributionState state;
@property(nonatomic,assign) OrderPayType payType;
@property(nonatomic,copy) NSString *qr;
@property(nonatomic,copy) NSString *used_prize;
@property(nonatomic,copy) NSString *ctime;
@property(nonatomic,assign) OrderPayRebateType rebate_type;
@property(nonatomic,copy) NSString *order_id;
@property(nonatomic,copy) NSString *order_id_fp;
@property(nonatomic,retain) OrderPayReciver *receiver;
@property(nonatomic,copy) NSString *money_detail;
@property(nonatomic,assign) NSInteger oid;
@property(nonatomic,copy) NSString *goods_master;
@property(nonatomic,retain) NSArray *goods;
@property(nonatomic,assign) BOOL is_del;
@property(nonatomic,copy) NSString *reason;
@property(nonatomic,copy) NSString *ftime;
@property(nonatomic,assign) NSInteger shopstore_id;
@property(nonatomic,copy) NSString *op_master;
@property(nonatomic,copy) NSString *used_points;
@property(nonatomic,retain) NSArray *refundstatus;
@property(nonatomic,copy) NSString *status;
@property(nonatomic,assign)OrderDistributionState express_type;
-(NSString*)orderPayType;
-(NSString*)distributionType;
-(NSString*)rebateType;
-(NSString*)orderStatus;
+(instancetype)buildWithJson:(NSDictionary*)json;

@end

@interface OrderPayReciver : NSObject

@property(nonatomic,copy) NSString *post_code;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,assign) BOOL isDefault;
@property(nonatomic,copy) NSString *phone;
@property(nonatomic,copy) NSString *address;
@property(nonatomic,assign) NSInteger oid;
+(instancetype)buildWithJson:(NSDictionary*)json;

@end

/*
 
 "stock_taking_url": "/wapi/form/goods/2207/stock/",
 "is_del": true,
 "app_id": 34,
 "total": 1,
 "id": 8215,
 "goods_type": "B",
 "pay_type": "money",
 "img_small": "http://smedia.msgcopy.net/smedia/app/sda1/m/411569f22df71bf4c246bf26b870bd2a/image/2015/06/u27875587684248141089fm21gp0_5.jpg",
 "goods_id": 2207,
 "title": "云２这是一个非常长的东西,呵呵",
 "source_app_id": 5,
 "unit_price": 1.1,
 "paydelivery": false,
 "kwargs": "{\"type\":\"form_record\",\"id\":9001}",
 "user_name": "1234",
 "call_back_url": "/wapi/form/goods/callback/",
 "desc": "云２这是一个非常长的东西,呵呵",
 "goods_master": "kk_xyym",
 "c_time": "2015-09-23T18:00:13",
 "is_recharge": false,
 "source_app_init_arg": "{\"id\":3378,\"color\":1}",
 "points": 0,
 "shopstore_id": 34
 
 */


@interface OrderGoodEntity : NSObject

@property(nonatomic,copy)NSString *stock_taking_url;
@property(nonatomic,assign)BOOL is_del;
@property(nonatomic,assign)NSInteger app_id;
@property(nonatomic,assign)NSUInteger total;
@property(nonatomic,assign)NSInteger gid;
@property(nonatomic,copy)NSString *goods_type;
@property(nonatomic,copy)NSString *pay_type;
@property(nonatomic,copy)NSString *img_small;
@property(nonatomic,copy)NSString *goods_id;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *desc;
@property(nonatomic,assign)NSInteger source_app_id;
@property(nonatomic,assign)NSInteger shopstore_id;
@property(nonatomic,assign)float unit_price;
@property(nonatomic,assign)BOOL paydelivery;
@property(nonatomic,copy)NSString *kwargs;
@property(nonatomic,copy)NSString *user_name;
@property(nonatomic,copy)NSString *call_back_url;
@property(nonatomic,copy)NSString *goods_master;
@property(nonatomic,copy)NSString *c_time;
@property(nonatomic,assign)BOOL is_recharge;
@property(nonatomic,copy)NSString *source_app_init_arg;
@property(nonatomic,assign)NSInteger points;
+(instancetype)buildWithJson:(NSDictionary*)json;

@end
