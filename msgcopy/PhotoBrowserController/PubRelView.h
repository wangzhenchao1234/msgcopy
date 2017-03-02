//
//  KKPubRelView.h
//  Kaoke
//
//  Created by xiaogu on 14-9-24.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PubRelView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    UICollectionViewFlowLayout *layout;
}
@property (nonatomic,retain) UICollectionView *listView;
@property (nonatomic,retain) NSArray *datas;
@end
