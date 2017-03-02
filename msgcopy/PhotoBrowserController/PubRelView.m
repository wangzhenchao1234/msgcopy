//
//  KKPubRelView.m
//  Kaoke
//
//  Created by xiaogu on 14-9-24.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "PubRelView.h"
#import "PubRelCell.h"
#define TopPandding  10

@implementation PubRelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        _listView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0 ,width,height) collectionViewLayout:layout];
        _listView.contentInset = UIEdgeInsetsMake(TopPandding + NAV_H, 10, 40, 10);
        [_listView registerClass:[PubRelCell class] forCellWithReuseIdentifier:@"CollectionCell"];
        _listView.delegate = self;
        _listView.pagingEnabled = true;
        _listView.alwaysBounceVertical = false;
        _listView.alwaysBounceHorizontal = false;
        _listView.dataSource = self;
        _listView.alwaysBounceVertical = YES;
        _listView.backgroundColor = [UIColor clearColor];
        [self addSubview:_listView];
        
    }
    return self;
}
/**
 *  delegate
 */
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return _datas.count;
 
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PubEntity *pub = _datas[indexPath.row];
    PubRelCell *cell = (PubRelCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    [cell buildWithPub:pub];
    [cell setNeedsDisplay];
    return cell;
    
}
#pragma -mark delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.width-30)/2.0f;
    return CGSizeMake(width ,width + 20);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    PubEntity *pub = CRArrayObject(_datas, indexPath.row);
    [MSGTansitionManager openPub:pub withParams:nil];
    
}
-(void)dealloc{
    
    layout = nil;
    _listView = nil;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
