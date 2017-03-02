//
//  CardHeaderView.h
//  msgcopy
//
//  Created by Gavin on 15/5/5.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIButton *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickView;
@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet UIButton *locationView;

@end
