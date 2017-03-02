//
//  CardCell.h
//  msgcopy
//
//  Created by wngzc on 15/5/5.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CardHeaderView;
@class CardToolBar;

@interface CardCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet CardHeaderView *headerView;
@property (weak, nonatomic) IBOutlet CardToolBar *toolBar;
-(void)buildWithData:(PubEntity*)pub;
@end
