//
//  ProductCell.h
//  PSClient
//
//  Created by Hackintosh on 15/9/28.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderProductCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *productPIc;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UILabel *productDescr;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;

@end
