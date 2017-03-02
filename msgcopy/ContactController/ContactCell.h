//
//  ContactCell.h
//  msgcopy
//
//  Created by wngzc on 15/7/25.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UILabel *nickView;
@property (weak, nonatomic) IBOutlet UILabel *phoneView;
@end
