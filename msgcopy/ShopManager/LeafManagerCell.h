//
//  LeafManagerCell.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/2.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeafManagerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *dotView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *detailView;

@end
