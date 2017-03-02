//
//  OrderManagerController.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/16.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "OrderManagerController.h"
#import "TopMenuCell.h"
#import "OrderController.h"
#import <iCarousel/iCarousel.h>

@interface OrderManagerController ()<iCarouselDataSource,iCarouselDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    NSArray *controllers;
    NSArray *identities;
}
@property (weak, nonatomic) IBOutlet iCarousel *caroselView;
@property (weak, nonatomic) IBOutlet UIToolbar *topBackGroundView;
@property (weak, nonatomic) IBOutlet UICollectionView *topBarVoew;

@property (retain, nonatomic) OrderController *allController;
@property (retain, nonatomic) OrderController *pointsController;

@end

@implementation OrderManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    _caroselView.pagingEnabled = true;
    _caroselView.bounces = false;
    _caroselView.clipsToBounds = true;
    self.title = @"订单管理";
    
    _allController = [Utility controllerInStoryboard:@"Main" withIdentifier:@"OrderController"];
    _allController.orderType = OrderTypeAll;
    _allController.shop = _shop;
    [self addChildViewController:_allController];
    
    _pointsController = [Utility controllerInStoryboard:@"Main" withIdentifier:@"OrderController"];
    _pointsController.orderType = OrderTypePoints;
    _pointsController.shop = _shop;
    [self addChildViewController:_pointsController];
    
    controllers = @[_allController,_pointsController];
    identities = @[@"all",@"POINTS"];
    
    [_topBackGroundView setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionTop];
    [_topBackGroundView setTintColor:[UIColor colorWithWhite:0.8 alpha:1]];
    
    [_topBarVoew selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:false scrollPosition:UICollectionViewScrollPositionNone];
    
    [self.topBarVoew registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    [self.topBarVoew registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];

    // Do any additional setup after loading the view.

}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}
-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        return  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        
    }
    return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
}

-(NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 2;
}
-(UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (!view) {
        view = [[UIView alloc] initWithFrame:self.view.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        view.backgroundColor = CRCOLOR_RED;
    }
    UIView *lastView = [view viewWithTag:1000];
    [lastView removeFromSuperview];
    OrderController *order = CRArrayObject(controllers, index);
    UIView *mainView = order.view;
    mainView.tag = 1000;
    mainView.frame = view.bounds;
    [view addSubview:mainView];
    order.view.autoresizingMask =  UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;;
    return view;
    
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(floor(collectionView.width/2.0f), 44);
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identity = CRArrayObject(identities, indexPath.row);
    TopMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identity forIndexPath:indexPath];
    OrderController *order = CRArrayObject(controllers, indexPath.row);
    order.titleLabel = cell.titleView;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < controllers.count) {
        [_caroselView scrollToItemAtIndex:indexPath.row animated:false];
    }
}
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    NSInteger index = carousel.currentItemIndex;
    if (index<controllers.count) {
        [_topBarVoew selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:true scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
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

@end
