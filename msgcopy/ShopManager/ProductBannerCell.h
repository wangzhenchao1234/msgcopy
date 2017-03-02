//
//  ProductBannerCell.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/6.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductBannerCell : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(nonatomic,retain) NSMutableArray *datas;
@property(nonatomic,retain) NSMutableArray *deleteDatas;
@property(nonatomic,retain) NSMutableArray *addDatas;

@end
