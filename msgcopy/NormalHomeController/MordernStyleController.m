//
//  MordernStyleDeskTopViewController.m
//  Kaoke
//
//  Created by xiaogu on 14-6-5.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//
#define PLACE 5
#define ITEM_SIZE (self.view.frame.size.width - 15)/2

#import "MordernStyleController.h"
#import "MorderCell.h"
#import "LineLayout.h"
#import "AppBannerView.h"
#import "BannerCell.h"

@interface MordernStyleController ()<MBProgressHUDDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    
    UICollectionView *_mainView;
    NSMutableArray *_leafs;
    NSMutableArray *_limbs;
    AppBannerView *_bannerView;
    __block NSUInteger         _completCount;
    __block NSUInteger         _failureCount;
    
}
@property(nonatomic,retain)MBProgressHUD *hud;

@end

@implementation MordernStyleController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)showHud:(NSString*)hint{
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.delegate = self;
        _hud.labelText = hint;
    }
    [self.view addSubview:_hud];
    [_hud show:true];
    
}
-(void)hiddenHud{
    [_hud hide:true];
    [_hud removeFromSuperview];
}

-(void)viewWillDisappear:(BOOL)animated{
    [_bannerView stopAnimation];
}
-(void)viewWillAppear:(BOOL)animated{
    [_bannerView startAnimation];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getLeafsWithAllLimb];
    [self intilizedData];
    [self getLeafsWithAllLimb];

    // Do any additional setup after loading the view.
}
-(void)getLeafsWithAllLimb{
    _completCount = 0;
    _failureCount = 0;
    _limbs = [PermissonManager sharedManager].authLimbs;
    if (_limbs.count > 0) {
        [self showHud:nil];
    }
    [_limbs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self getAllLeafsWithLimb:obj];
    }];
    
}
/**
 *  获取所有二级
 */
-(void)getAllLeafsWithLimb:(LimbEntity*)limb
{
    CRWeekRef(self);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    [AppWindow addSubview:hud];
    [hud show:true];
    [MSGRequestManager Get:kAPIGetLimb(limb.lid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        _completCount++;
        if (CRJSONIsDictionary(data)) {
            NSArray *leafsJson = data[@"leafs"];
            [LocalManager storeObject:leafsJson forKey:CRString(@"json_leafs_limb%d",limb.lid)];
            NSMutableArray *leafs = [NSMutableArray new];
            for (int i = 0; i<leafsJson.count;i++ ) {
                LeafEntity *leaf =[LeafEntity buildInstanceByJson:leafsJson[i]];
                //leaf.filterID = [[FilterManager sharedManager].curID integerValue];
                [[PermissonManager  sharedManager] permissionForLeaf:leaf];
                if (!leaf.hiddeen) {
                    [leafs addObject:leaf];
                }
            }
            if (!limb.leafs) {
                limb.leafs = [NSMutableArray new];
            }
            [limb.leafs removeAllObjects];
            [leafs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LeafEntity *leaf = obj;
                [limb addLeaf:leaf];
                
            }];
            [leafs removeAllObjects];
            if (_completCount == _limbs.count) {
                [self intilizedData];
                [self hiddenHud];
            }
        }else{
            [CustomToast showMessageOnWindow:@"加载失败请检查网络"];
        }
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        _failureCount++;
        NSMutableArray *leafs = [__self leafCacheforLimb:limb];
        if (leafs) {
            limb.leafs = leafs;
        }else{
            [CustomToast showMessageOnWindow:msg];
        }
    }];
}
/**
 *  加载缓存
 *
 *  @return 缓存二级列表数据
 */
-(NSMutableArray*)leafCacheforLimb:(LimbEntity*)limb{
    
    NSArray *jsonLeafs = [LocalManager objectForKey:CRString(@"json_leafs_limb%d",limb.lid)];
    NSMutableArray *leafs = [NSMutableArray new];
    if (CRJSONIsArray(jsonLeafs)) {
        [jsonLeafs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (CRJSONIsDictionary(obj)) {
                LeafEntity *leaf = [LeafEntity buildInstanceByJson:obj];
                //                leaf.filterID = [[FilterManager sharedManager].curID integerValue];
                [[PermissonManager  sharedManager] permissionForLeaf:leaf];
                leaf.limb = limb;
                if (!leaf.hiddeen) {
                    [leafs addObject:leaf];
                }
            }
        }];
    }
    return leafs;
}

/**
 *  初始化数据
 */
-(void)intilizedData{
   
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _mainView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_mainView registerClass:[MorderCell class] forCellWithReuseIdentifier:@"CollectionCell"];
    [_mainView registerClass:[BannerCell class] forCellWithReuseIdentifier:@"BannerCell"];
    _mainView.delegate = self;
    _mainView.dataSource = self;
    _mainView.alwaysBounceVertical = YES;
    _mainView.backgroundColor = [UIColor whiteColor];
    _mainView.contentInset = UIEdgeInsetsMake(TAB_H + 5, 5, NAV_H + 5, 5);
    [self.view addSubview:_mainView];
    
    
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
//    if ([[KaokeWebAppManager getInstans] getAppBySystitle:@"carousel"])
//    {
//        AppBannerEntity *banner = [[AppBannerManager sharedManager] bannerForType:@"desktop"];
//        if (banner&&banner.items.count>0)
//        {
//            return _leafs.count+1;
//        }
//    }
    return _leafs.count;
    
}
/**
 *  是否显示轮播图
 *
 *  @return
 */
-(BOOL)hasBanner{
    
    if (CRWebAppTitle(@"carousel"))
    {
        AppBannerEntity *banner = CRBannerForTitle(AppBannerTypeDeskTop);
        if (banner&&banner.items.count>0)
        {
            return true;
        }
    }
    return false;
    
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self hasBanner]&&indexPath.row == 0) {
        MorderCell *cell = (MorderCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"BannerCell" forIndexPath:indexPath];
        if (!_bannerView) {
            AppBannerEntity *banner = CRBannerForTitle(AppBannerTypeDeskTop);
            AppBannerView *top = [AppBannerView buildInatanceByBanner:banner target:self frame:CGRectMake(0, 0, self.view.frame.size.width - 2 * PLACE, 0)];
            _bannerView = top;
            [cell.contentView addSubview:top];
        }
        return cell;
    }
    NSInteger index = indexPath.row;
    if ([self hasBanner]) {
        index = indexPath.row - 1;
    }
    LeafEntity *leaf = _leafs[index];
    MorderCell *cell = (MorderCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    NSArray *urls = [self getImageUrlsFromLeaf:leaf];
    NSString *url = nil;
    if (urls.count>0) {
        url = urls[0];
    }
    [cell.itemView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
    cell.titleLable.text = leaf.title;
    return cell;
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self hasBanner]&&indexPath.row == 0) {
        AppBannerEntity *banner = CRBannerForTitle(AppBannerTypeDeskTop);
        return CGSizeMake(self.view.frame.size.width - 10, banner.height);
    }
    return CGSizeMake(ITEM_SIZE, ITEM_SIZE);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self hasBanner]&&indexPath.row == 0) {
        
        return;
    }
    NSInteger index = indexPath.row;
    if ([self hasBanner]) {
        index = indexPath.row - 1;
    }
//    LeafEntity *leaf = _leafs[index];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self clickCount:leaf];
//    });
//    KaokeListMenuViewController *vc = [[KaokeListMenuViewController alloc] init];
//    vc.leaf                  = leaf;
//    vc.isHome                = NO;
//    vc.shownType             = LEAF_LIST_TYPE;
//    vc.titleView.text        = leaf.limb.title;
//    UINavigationController *nav = CRNavigation(self.view);
//    if (!nav) {
//        nav = [SliderViewController sharedSliderController].navigationController;
//    }
//    [nav pushViewController:vc animated:YES];

}
-(NSMutableArray *)getImageUrlsFromLeaf:(LeafEntity*)leaf{
    
    NSMutableArray *imageUrls = [NSMutableArray new];
    for (PubEntity *item in leaf.homePubs) {

        NSString *url;
        if (leaf.placeholder.imageUrl!=nil) {
            url = leaf.placeholder.imageUrl;
            [imageUrls addObject:url];
            break;
        }else{
            if (item.article.thumbnail.turl!=nil ) {
                url = item.article.thumbnail.turl;
            }else{
                if (item.images.count>0) {
                    KaokeImage *img= item.images[0];
                    url = img.ourl;
                }else{
                    url = @"";
                }
            }
        }
        [imageUrls addObject:url];
    }
    return imageUrls;
    
}
-(void)reloadData{
    
    [self getLeafsWithAllLimb];
    [_mainView reloadData];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [_bannerView stopAnimation];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
