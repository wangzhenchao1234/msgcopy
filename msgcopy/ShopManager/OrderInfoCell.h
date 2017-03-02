//
//  OrderInfoCell.h
//  PSClient
//
//  Created by Hackintosh on 15/9/28.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderTime;
@property (weak, nonatomic) IBOutlet UILabel *orderNo;
@property (weak, nonatomic) IBOutlet UILabel *distrbState;

@end
