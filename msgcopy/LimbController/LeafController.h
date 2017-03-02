//
//  LeafController.h
//  msgcopy
//
//  Created by wngzc on 15/7/23.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeafControllerDelegate.h"

@interface LeafController : NSObject
+(void)leafController:(id<LeafControllerDelegate>)controller listViewRefresh:(UITableView *)tableView;
+(void)leafController:(id<LeafControllerDelegate>)controller listViewloadMore:(UITableView *)tableView;
+(void)leafController:(id<LeafControllerDelegate>)controller listView:(UITableView*)listView sortWithRegulation:(SortRegulation)regulation;
+(void)leafController:(id<LeafControllerDelegate>)controller listViewLoadData:(UITableView *)listView;
@end
