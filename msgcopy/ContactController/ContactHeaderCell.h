//
//  ContactHeaderCell.h
//  msgcopy
//
//  Created by wngzc on 15/7/27.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *HeadView;
@property (weak, nonatomic) IBOutlet UILabel *nickView;
@property (weak, nonatomic) IBOutlet UIImageView *genderView;
@property (weak, nonatomic) IBOutlet UILabel *moodView;

@end
