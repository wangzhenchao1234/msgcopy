//
//  ShopItemCell.m
//  Kaoke
//
//  Created by wngzc on 15/3/18.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "ShopItemView.h"
#import "ShopItemCollectionCell.h"

#define TW (AppWindow.width-5)/4.0f

#define TP 10
#define BP 10

#define SP 5


@implementation ShopItemView

- (void)awakeFromNib {
    // Initialization code
    _bottomnLine.height = 1/ScreenScale;
    _listView.width = AppWindow.width;
    [_listView registerNib:[UINib nibWithNibName:@"ShopItemCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"item"];
    _listView.backgroundColor = [UIColor colorFromHexRGB:@"f4f4f4"];
    _listView.contentInset = UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, 1.0f);
    _listView.scrollEnabled = false;
}
-(void)buildWithLimbs:(NSArray*)limbs
{
    menus = limbs;
    NSInteger line = limbs.count/4 + (limbs.count%4==0?0:1);
    _listView.width = AppWindow.width;
    _listView.y = 0;
    CGFloat height = TW*line + line + 1;
    _listView.height =  height;
    self.height = _listView.height;
    _bottomnLine.y = self.height - 1.0f/ScreenScale;
    [_listView reloadData];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return menus.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1.0f;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0f;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(TW, TW);
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopItemCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"item" forIndexPath:indexPath];
    LimbEntity *limb = menus[indexPath.row];
    [cell.iconView sd_setImageWithURL:CRURL(limb.icon.normal_icon ) forState:UIControlStateNormal];
    [cell.iconView sd_setImageWithURL:CRURL(limb.icon.selected_icon) forState:UIControlStateSelected];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_click"]];
    cell.titleView.text = limb.title;
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopItemCollectionCell *cell = (ShopItemCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.iconView setSelected:true];
    
}
-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopItemCollectionCell *cell = (ShopItemCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.iconView setSelected:false];

}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    LimbController *limbCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LimbController"];
    LimbEntity *limb = CRArrayObject(menus, indexPath.row);
    if (limb) {
        [limbCon reloadDataWithLimb:limb];
        [CRRootNavigation() pushViewController:limbCon animated:true];
    }else{
        [CustomToast showMessageOnWindow:@"您访问的内容不存在！"];
    }
}

@end
