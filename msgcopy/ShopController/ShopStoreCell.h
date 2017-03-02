//
//  ShopStoreCell.h
//  Kaoke
//
//  Created by Gavin on 15/3/10.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShopStoreEntity.h"

@interface ShopStoreCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *shopTitleView;
@property (weak, nonatomic) IBOutlet UILabel *productCategoryView;
-(void)buildWithData:(ShopStoreEntity*)entity;
@end
