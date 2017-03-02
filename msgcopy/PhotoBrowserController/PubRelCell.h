//
//  KKPubRelCell.h
//  Kaoke
//
//  Created by xiaogu on 14-9-24.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PubEntity;

@interface PubRelCell : UICollectionViewCell
@property (nonatomic,retain) UIImageView *imageView;
@property (nonatomic,retain) UIImageView *videoFlag;
@property (nonatomic,retain) UILabel *titleView;
-(void)buildWithPub:(PubEntity *)pub;
@end
