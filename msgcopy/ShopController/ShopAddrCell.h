//
//  ShopAddrCell.h
//  msgcopy
//
//  Created by wngzc on 15/4/20.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopAddrCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addrView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLine;
@property (weak, nonatomic) IBOutlet UILabel *topLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineHeightConstraint;

@end
