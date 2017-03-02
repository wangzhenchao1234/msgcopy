//
//  LeafListView.m
//  msgcopy
//
//  Created by wngzc on 15/4/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "LeafListView.h"
#import "LeafItemCell.h"

#define MoveBarW 40

@interface LeafListView()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,retain) NSArray *iTitles;
@property(nonatomic,retain) UILabel *moveBar;
@end


@implementation LeafListView

-(void)awakeFromNib
{
    [_collectionView registerNib:[UINib nibWithNibName:@"LeafItemCell" bundle:nil] forCellWithReuseIdentifier:@"LeafItemCell"];
//    _moveBar = [[UILabel alloc] initWithFrame:CGRectMake(0, App3xScale(70) - 2, MoveBarW, 2)];
//    _moveBar.backgroundColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
//    [self addSubview:_moveBar];
}
/**
 *  跳转到对应的菜单
 *
 *  @param index index
 */
-(void)switchTo:(NSInteger)index
{
    if (index < _iTitles.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [_collectionView selectItemAtIndexPath:indexPath animated:true scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}
/**
 *  刷新数据
 *
 *  @param titles titles
 */
-(void)reloadMenuWithLeafs:(NSArray *)leafs{
    
    NSMutableArray *titles = [NSMutableArray new];
    [leafs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LeafEntity *leaf = obj;
        [titles addObject:leaf.title];
    }];
    _iTitles = titles;
    [_collectionView reloadData];
}

#pragma mark - collectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _iTitles.count;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = _iTitles.count > 4?(AppWindow.width/4.0f):(AppWindow.width/_iTitles.count*1.0f);
    if (_iTitles.count>=4) {
        return CGSizeMake([LeafItemCell getWidth:_iTitles[indexPath.row]],App3xScale(collectionView.height));
    }
    return CGSizeMake(cellWidth,App3xScale(collectionView.height));
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LeafItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LeafItemCell" forIndexPath:indexPath];
    cell.titleView.text = _iTitles[indexPath.row];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    [UIView animateWithDuration:.35 animations:^{
//        CGFloat x = cell.center.x;
//        CGPoint ct = _moveBar.center;
//        ct.x = x;
//        _moveBar.center = ct;
//    }];
    if ([self.delegate respondsToSelector:@selector(changeToItem:)]) {
        [self.delegate changeToItem:indexPath.row];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
