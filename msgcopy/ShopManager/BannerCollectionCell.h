//
//  BannerCollectionCell.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/10.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  BannerCollectionCellDelegate<NSObject>
-(void)deleteItemAtIndex:(NSIndexPath*)index;
@end

@interface BannerCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (retain, nonatomic) NSIndexPath *indexPath;

@property (weak, nonatomic) id<BannerCollectionCellDelegate> delegate;

@end
