//
//  ZakerListController.m
//  msgcopy
//
//  Created by wngzc on 15/5/5.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ZakerListController.h"
#import "ZakerGridCell.h"
#import "ZakerPicCell.h"
#import "LeafController.h"
#import "UICollectionViewController+LeafTop.h"
#import "CollectionLeafTopView.h"

#define PLACE 10

@interface ZakerListController ()<UICollectionViewDelegateFlowLayout>
@end

@implementation ZakerListController
@synthesize leaf = _leaf,publications = _publications, leafTops = _leafTops, regulation = _regulation, sortPublications = _sortPublications;


static NSString * const reuseIdentifier1 = @"ZakerGridCell";
static NSString * const reuseIdentifier2 = @"ZakerPicCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"ZakerGridCell" bundle:nil] forCellWithReuseIdentifier:@"ZakerGridCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ZakerPicCell" bundle:nil] forCellWithReuseIdentifier:@"ZakerPicCell"];
    [self.collectionView registerClass:[CollectionLeafTopView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionTop"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionBlankHeader"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionBlankFooter"];
    CRWeekRef(self);
    [self.collectionView addLegendHeaderWithRefreshingBlock:^{
        [__self refreshPublications];
    }];
    [self.collectionView addLegendFooterWithRefreshingBlock:^{
        [__self morePublications];
    }];

    [LeafController leafController:self listViewLoadData:(UITableView*)self.collectionView];
    
    // Do any additional setup after loading the view.
}
# pragma mark - actions

-(void)refreshPublications
{
    if (self.regulation == SORT_GPS) {
        [LeafController leafController:self listView:(UITableView*)self.collectionView sortWithRegulation:SORT_GPS];
    }else{
        [LeafController leafController:self listViewRefresh:(UITableView*)self.collectionView];
    }
}
-(void)morePublications
{
    [LeafController leafController:self listViewloadMore:(UITableView*)self.collectionView];
}

-(void)sort:(SortRegulation)regulation
{
    _regulation = regulation;
    if (regulation == SORT_GPS&&_sortPublications.count == 0) {
        [self.collectionView.header beginRefreshing];
    }else{
        [self.collectionView reloadData];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_regulation == SORT_GPS) {
        return _sortPublications.count;
    }
    return _publications.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PubEntity *pub = nil;
    if (_regulation == SORT_GPS) {
        pub = CRArrayObject(self.sortPublications, indexPath.row);
    }else{
        pub = CRArrayObject(_publications, indexPath.row);
    }
    if ((indexPath.row+1)%5 == 0) {
        ZakerPicCell *cell = (ZakerPicCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ZakerPicCell" forIndexPath:indexPath];
        cell.titleView.text = pub.article.title;
        [cell.thumbnailView sd_setImageWithURL:CRURL(pub.article.thumbnail.turl) placeholderImage:ThumbnailPlaceImage];
        return cell;
    }
    
    ZakerGridCell *cell = (ZakerGridCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ZakerGridCell" forIndexPath:indexPath];
    cell.titleView.text = pub.article.title;
    cell.sourceView.text = pub.article.source;
    return cell;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row+1)%5 == 0) {
        return CGSizeMake(collectionView.width -2 ,  App3xScale(360));
    }
    return CGSizeMake(((collectionView.width - 3)/2.0f),  App3xScale(180));
    
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 1;
    
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 1;
    
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    return CGSizeMake(collectionView.frame.size.width, 10);
    
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 1, 0, 1);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    PubEntity *pub = nil;
    if (_regulation == SORT_GPS) {
        pub = CRArrayObject(self.sortPublications, indexPath.row);
    }else{
        pub = CRArrayObject(_publications, indexPath.row);
    }
    if (pub) {
        [MSGTansitionManager openPub:pub withParams:nil];
    }
}
-(UITableView*)listView
{
    return (UITableView*)self.collectionView;
}
-(void)insert:(PubEntity *)pub
{
    if (pub) {
        [_publications insertObject:pub atIndex:0];
        [self.collectionView reloadData];
    }
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
