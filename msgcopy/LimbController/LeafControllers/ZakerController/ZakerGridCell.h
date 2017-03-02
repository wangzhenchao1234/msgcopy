//
//  ZakerGridCell.h
//  msgcopy
//
//  Created by Gavin on 15/5/5.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZakerGridCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *sourceView;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@end