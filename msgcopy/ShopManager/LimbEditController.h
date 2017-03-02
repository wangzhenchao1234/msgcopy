//
//  LimbEditController.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/2.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AddType 0
#define EditeType 1

@interface LimbEditController : UITableViewController
@property(nonatomic,retain)LimbEntity *limb;
@property (nonatomic,assign) NSNumber *type;
@property (nonatomic,retain) ShopStoreEntity *shop;
@property(nonatomic,copy)void(^callBacl)(BOOL result,id data);
@end
