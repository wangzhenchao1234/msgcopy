//
//  VideoPubRelCell.h
//  msgcopy
//
//  Created by Gavin on 15/5/15.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPubRelCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIView *titleBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;

@end
