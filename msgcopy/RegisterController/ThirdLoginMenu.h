//
//  ThirdLoginMenu.h
//  msgcopy
//
//  Created by Gavin on 15/5/21.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;
@interface ThirdLoginMenu : UIView<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    UILabel *_logo;
    NSMutableArray *_datas;
    MBProgressHUD *_hudView;
}
@property(nonatomic,retain)UIImage *qq;
@property(nonatomic,retain)UIImage *sina;
@property(nonatomic,retain)UIImage *wechat;
-(void)reloadData;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@end
