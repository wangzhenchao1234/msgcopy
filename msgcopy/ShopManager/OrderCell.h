//
//  OrderCell.h
//  PSClient
//
//  Created by Hackintosh on 15/9/28.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OrderEntity;
@interface OrderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTime;
@property (weak, nonatomic) IBOutlet UIButton *shopButton;
@property (weak, nonatomic) IBOutlet UIImageView *product1Pic;
@property (weak, nonatomic) IBOutlet UIImageView *product2Pic;
@property (weak, nonatomic) IBOutlet UILabel *product1Title;
@property (weak, nonatomic) IBOutlet UILabel *product2Title;
@property (weak, nonatomic) IBOutlet UILabel *product2Descr;
@property (weak, nonatomic) IBOutlet UILabel *product1Descr;
@property (weak, nonatomic) IBOutlet UILabel *product1Price;
@property (weak, nonatomic) IBOutlet UILabel *product2Price;
@property (weak, nonatomic) IBOutlet UILabel *DistribState;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
-(void)buildWithOrder:(OrderEntity *)order;
@end
