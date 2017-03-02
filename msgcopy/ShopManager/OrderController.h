//
//  OrderController.h
//  PSClient
//
//  Created by Hackintosh on 15/9/25.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OrderEntity;

typedef NS_ENUM(NSUInteger,OrderType){
    
    OrderTypeAll = 0,
    OrderTypePoints,
    
};

@interface OrderController : UITableViewController
@property(nonatomic,retain)ShopStoreEntity *shop;
@property (nonatomic,assign)OrderType orderType;
@property (nonatomic,retain)UILabel *titleLabel;
//-(void)insertOrder:(OrderEntity*)order;
@end
