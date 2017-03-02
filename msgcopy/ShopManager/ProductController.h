//
//  ProductController.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/4.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GoodsTypeAdd 1
#define GoodsTypeEdite 2

@interface ProductController : UITableViewController
@property(nonatomic,assign)NSNumber *type;
@property(nonatomic,retain)PubEntity *pub;
@property(nonatomic,retain)ShopStoreEntity *shop;
@property(nonatomic,copy)void(^completeCallBack)(BOOL result);
@end


/*
 {
 "check_type" = CheckBox;
 descr = "";
 id = 2425;
 "img_url" = "http://smedia.msgcopy.net/smedia/app/sda1/m/30a5a17bb65e8e3e5db969f2493adbf3/image/2015/10/4a36acaf2edda3cc1b60822e03e93901213f9233.jpg";
 "pay_type" = money;
 price = "0.01";
 remain = 0;
 stock = 100000;
 title = "\U544a\U8bc9\U5bf9\U65b9\U8c46\U8150\U5e72\U5730\U65b9";
 total = 100000;
 type = Goods;
 unit = "";
 }

 */

@interface PriceEntity : NSObject
@property(nonatomic,copy)NSString*curPrice;
@property(nonatomic,copy)NSString*prePrice;
@property(nonatomic,retain)ThumbnailEntity *thumbnail;
@end

@interface ProductEntity :NSObject
@property(nonatomic,copy)NSString*check_type;
@property(nonatomic,copy)NSString*descr;
@property(nonatomic,assign)NSInteger pid;
@property(nonatomic,copy)NSString*img_url;
@property(nonatomic,copy)NSString*pay_type;
@property(nonatomic,retain)NSString *price;
@property(nonatomic,assign)BOOL remain;
@property(nonatomic,retain)NSString *stock;
@property(nonatomic,copy)NSString*title;
@property(nonatomic,copy)NSString*total;
@property(nonatomic,copy)NSString*type;
@property(nonatomic,copy)NSString*unit;
@property(nonatomic,assign)BOOL isAdd;
+(instancetype)buildWithJson:(NSDictionary*)json;
@end




