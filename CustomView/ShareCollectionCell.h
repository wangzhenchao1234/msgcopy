//
//  ShareCollectionCell.h
//  msgcopy
//
//  Created by wngzc on 15/6/25.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareCollectionCell : UICollectionViewCell
{
    BOOL isSelected;
}
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@end
