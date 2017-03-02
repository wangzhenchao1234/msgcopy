//
//  ShopLimbCell.m
//  Kaoke
//
//  Created by wngzc on 15/3/18.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "ShopLimbCell.h"
#import "GridBusinessCell.h"

#define PLACE 10
#define CellWidth  ((AppWindow.width - 30)/2.0f)

@implementation ShopLimbCell

- (void)awakeFromNib {
     [super awakeFromNib];
    // Initialization code
    [self.pubsView registerNib:[UINib nibWithNibName:@"GridBusinessCell" bundle:nil] forCellWithReuseIdentifier:@"GridBusinessCell"];
    _toolBarView.width = AppWindow.width;
    _toolBarView.x = 0;
    _toolBarView.y = 0;
    _bottomLine.x = 0;
    _bottomLine.height = 1/ScreenScale;
    self.toolBarBottomLine.height = 1/ScreenScale;
    self.toolBarTopLine.height = 1/ScreenScale;
    _toolBarBottomLine.y = 44 - 1/ScreenScale;
    _toolBarTopLine.y = 0;
    _pubsView.width = AppWindow.width;
    _moreView.x = AppWindow.width - 10 - _moreView.width;
    
}
+(CGFloat)getHeight:(NSArray*)pubs
{
    NSInteger line = pubs.count/2 + (pubs.count%2==0?0:1);
    CGFloat height = 54;
    if (pubs.count>0) {
        PubEntity *pub = pubs[0];
        CGFloat limbHeight = [GridBusinessCell getHeigh:pub];
        height  += (line * limbHeight + (line+1)*10);
    }
    return height;
}
-(void)buildWithData:(StoreLimbEntity*)store;
{
    _toolBarView.width = AppWindow.width;
    _toolBarView.y = 10;
    _toolBarView.height = 44;
    storeData = store;
    
    NSInteger line = storeData.publications.count/2 + (storeData.publications.count%2==0?0:1);
    self.pubsView.height = 0;
    if (store.publications.count>0) {
        PubEntity *pub = storeData.publications[0];
        CGFloat height = [GridBusinessCell getHeigh:pub];
        self.pubsView.height = line * height + (line+1) * 10;
    }
    self.pubsView.y = 54;
    _titleView.text = storeData.title;
    _bottomLine.y = _pubsView.y + _pubsView.height - 1/ScreenScale;
    [self.pubsView reloadData];

}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return storeData.publications.count;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    GridBusinessCell *cell = (GridBusinessCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"GridBusinessCell" forIndexPath:indexPath];
    PubEntity *pub = storeData.publications[indexPath.row];
    [cell buildWithData:pub];
    return cell;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PubEntity *pub = storeData.publications[indexPath.row];
    return CGSizeMake(CellWidth,  [GridBusinessCell getHeigh:pub]);
    
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 10;
    
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 10;
    
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    return CGSizeMake(collectionView.frame.size.width, 10);
    
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(10, 10, 0,10);
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    PubEntity *pub = CRArrayObject( storeData.publications, indexPath.row);
    if (pub) {
        [MSGTansitionManager openPubWithID:pub.pid withParams:nil];
    }
}
- (IBAction)showLimb:(id)sender {
    
    LimbController *limbCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LimbController"];
    LimbEntity *limb = [LimbEntity new];
    limb.lid = storeData.lid;
    limb.title = storeData.title;
    [limbCon reloadDataWithLimb:limb];
    [CRRootNavigation() pushViewController:limbCon animated:true];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
