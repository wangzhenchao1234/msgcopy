//
//  AddCommentFooterView.m
//  msgcopy
//
//  Created by wngzc on 15/7/1.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "AddCommentFooterView.h"
#import "CommentMediaCell.h"
//为了使用下面的KaokeImage对象
@class KaokeImageSet;
@implementation AddCommentFooterView
-(void)awakeFromNib
{
    _collectionView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [_collectionView registerNib:[UINib nibWithNibName:@"CommentMediaCell" bundle:nil] forCellWithReuseIdentifier:@"CommentMediaCell"];
}
-(void)reloadWithAttachs:(NSMutableArray *)attachs
{
    _attachs = attachs;
    NSLog(@"===%@",attachs);
    [_collectionView reloadData];
}
-(void)deleteItem:(NSDictionary*)attach
{
    NSInteger index = [_attachs indexOfObject:attach];
    NSLog(@"%@",attach);
    if (index!= NSNotFound) {
        [_attachs removeObject:attach];
        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        //他添加这个的用意是想把图片的用户评论上传的照片名字传给上一级，
        KaokeImage * image = [[KaokeImage alloc] init];
        image.otitle = attach[@"name"];
      //  image.isDelete = YES;
        
    }
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _attachs.count;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat size = (AppWindow.width-10)/3.0f;
    return CGSizeMake(size, size);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CommentMediaCell *cell = (CommentMediaCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CommentMediaCell" forIndexPath:indexPath];
    NSDictionary *item = CRArrayObject(_attachs, indexPath.row);
    if (item) {
        [cell buildWithData:item target:self];
    }
    return cell;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
