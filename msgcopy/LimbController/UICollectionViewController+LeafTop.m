//
//  UICollectionViewController+LeafTop.m
//  msgcopy
//
//  Created by Gavin on 15/7/31.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "UICollectionViewController+LeafTop.h"
#import "CollectionLeafTopView.h"

@implementation UICollectionViewController (LeafTop)
-(UITableView*)listView
{
    return (UITableView*)self.collectionView;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.leaf.leafTops.count == 0) {
        return CGSizeZero;
    }
    return CGSizeMake(collectionView.width, collectionView.width*9/16);
}
-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        return  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionBlankFooter" forIndexPath:indexPath];

    }
    if (self.leaf.leafTops.count == 0) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionBlankHeader" forIndexPath:indexPath];
        return view;
    }
    CollectionLeafTopView *top = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionTop" forIndexPath:indexPath];
    if (!top.leaf) {
        [top setLeaf:self.leaf];
    }
    return top;
}

@end
