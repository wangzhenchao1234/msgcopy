//
//  ZakerPicCell.h
//  msgcopy
//
//  Created by Gavin on 15/5/5.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZakerPicCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;

@end
