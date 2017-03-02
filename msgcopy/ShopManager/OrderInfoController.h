//
//  OrderInfoController.h
//  PSClient
//
//  Created by Hackintosh on 15/9/28.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderEntity;
@interface OrderInfoController : UITableViewController
@property(nonatomic,retain)OrderEntity *order;
@end
