//
//  ShopLimbCell.h
//  Kaoke
//
//  Created by Gavin on 15/3/18.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StoreLimbEntity;

@interface ShopLimbCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UILabel *limbTitle;
    StoreLimbEntity *storeData;
}
@property (weak, nonatomic) IBOutlet UIView *moreView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UICollectionView *pubsView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLine;
@property (weak, nonatomic) IBOutlet UILabel *toolBarBottomLine;
@property (weak, nonatomic) IBOutlet UILabel *toolBarTopLine;
-(void)buildWithData:(StoreLimbEntity*)store;
+(CGFloat)getHeight:(NSArray*)pubs;
@end
