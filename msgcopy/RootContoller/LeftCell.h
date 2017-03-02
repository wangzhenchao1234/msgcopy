//
//  LeftCell.h
//  msgcopy
//
//  Created by Gavin on 15/4/10.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *dotView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UIButton *arrowView;
-(void)buidWithData:(id)data;
@end
