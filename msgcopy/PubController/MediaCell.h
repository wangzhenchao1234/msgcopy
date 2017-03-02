//
//  MediaCell.h
//  msgcopy
//
//  Created by wngzc on 15/6/30.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *playView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@end
