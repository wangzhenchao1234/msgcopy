//
//  UICollectionViewController+LeafTop.h
//  msgcopy
//
//  Created by wngzc on 15/7/31.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeafControllerDelegate.h"

@interface UICollectionViewController (LeafTop)<LeafControllerDelegate>
-(UITableView*)listView;
@end
