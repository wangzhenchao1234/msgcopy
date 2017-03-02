//
//  ShopManagerController.m
//  msgcopy
//
//  Created by Hackintosh on 15/10/29.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import "MyShopStores.h"
#import "BlankView.h"

@interface MyShopStores ()<UICollectionViewDelegateFlowLayout>
{
    
    NSArray *adminShops;
    BlankView *blank;
    
}
@end

@implementation MyShopStores

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    
    WebAppEntity *app = CRWebAppTitle(@"myshopstore");
    self.title = app.title;
    blank = [BlankView blanViewWith:nil descr:@"您没有可管理的店铺" actionTitle:nil target:nil selector:nil];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];

    CRWeekRef(self);
    [self.collectionView addLegendHeaderWithRefreshingBlock:^{
        [__self getAdminShopStore];
    }];
    [self.collectionView.header beginRefreshing];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
    
}
-(void)getAdminShopStore{
    
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIShops params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSMutableArray *shops = [NSMutableArray new];
        [__self.collectionView.header endRefreshing];

        [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ShopStoreEntity *shop = [ShopStoreEntity buildWithJson:obj];
            if ([shop.master.userName isEqualToString:kCurUser.userName]||[kCurApp.master.userName isEqualToString:kCurUser.userName]) {
                [shops addObject:shop];
            }
        }];
        if (shops.count == 0) {
            [GVAlertView showAlert:@"提示" message:@"您没有任何店铺可以管理" confirmButton:@"确定" action:^{
                [__self.navigationController popViewControllerAnimated:true];
            } cancelTitle:nil action:nil];
        }else{
            
            adminShops = shops;
            
        }
        if ([adminShops count]<=0) {
            __self.collectionView.backgroundView = blank;
        }else{
            __self.collectionView.backgroundView = nil;
        }
        [__self.collectionView reloadData];


    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__self.collectionView.header endRefreshing];
        [CustomToast showMessageOnWindow:msg];
    }];

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
//#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of items
    return adminShops.count;
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
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 145;
    CGFloat width = collectionView.width - 80;
    return CGSizeMake(width, height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    UILabel *titleView = (UILabel*)[cell.contentView viewWithTag:200];
    UIImageView *thumbnail = (UIImageView*)[cell.contentView viewWithTag:100];
    ShopStoreEntity *shop = CRArrayObject(adminShops, indexPath.row);
    // Configure the cell
    titleView.text = shop.title;
    [thumbnail sd_setImageWithURL:CRURL(shop.thumbnail.turl)];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    ShopStoreEntity *shop = CRArrayObject(adminShops, indexPath.row);
    [self performSegueWithIdentifier:@"ShowShop" sender:shop];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setValue:sender forKey:@"shop"];
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
