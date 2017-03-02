//
//  ShopItemCell.h
//  Kaoke
//
//  Created by wngzc on 15/3/18.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopItemView : UIView<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSArray *menus;
}
@property (weak, nonatomic) IBOutlet UICollectionView *listView;
@property (weak, nonatomic) IBOutlet UILabel *bottomnLine;
-(void)buildWithLimbs:(NSArray*)limbs;
@end
