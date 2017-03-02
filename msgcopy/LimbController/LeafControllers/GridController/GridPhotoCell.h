//
//  GridPhotoCell.h
//  msgcopy
//
//  Created by wngzc on 15/4/29.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridPhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *blackShadowView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *descrView;
@property (weak, nonatomic) IBOutlet UIButton *actionView;
@property (weak, nonatomic) IBOutlet UIButton *likeCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *likeCountWidthConstraint;
-(void)updateLikeCount:(NSInteger)count;
@end
