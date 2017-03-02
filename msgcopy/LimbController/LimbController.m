//
//  LimbController.m
//  msgcopy
//
//  Created by wngzc on 15/4/14.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "LimbController.h"
#import "LeafListView.h"
#import "GridBusinessController.h"
#import "ListBusinessController.h"
#import "DefaultListController.h"
#import "GridPhotoController.h"
#import "ZakerListController.h"
#import <iCarousel/iCarousel.h>
#import "LeafListView.h"
#import "LeafItemCell.h"
#import "LeafSortCell.h"
#import "LeafController.h"
#import "LeafControllerDelegate.h"
#import "CreatPubController.h"
#import "LeafControllerDelegate.h"

#define ContentTag 332
#define SortViewTag 33443

#define TopMenuHeight 40
#define SortMenuHeight 50

static NSString *REDUCE = @"reduce";
static NSString *ADD = @"add";

typedef NS_ENUM(NSUInteger, LeafChangeDirection){
    
    LeafChangeDirectionLeft,
    LeafChangeDirectionRight,
    LeafChangeDirectionTop,
    LeafChangeDirectionBottom
};



@interface LimbController ()<iCarouselDataSource,iCarouselDelegate,LeafListViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    CGFloat _topInset;
    NSArray *_selectedRGB;
    NSArray *_unselectedRGB;
    BOOL shouldScrollToLeaf;
    NSInteger shouldScrollToLeafID;
    NSMutableArray *_appItems;
    
}
@property (nonatomic,retain) iCarousel *carouselView; //复用view
@property (nonatomic,assign) LeafChangeDirection scorollDirection;//复用view
@property (nonatomic,retain) LeafListView *leafMenuView; //二级菜单
@property (nonatomic,assign) NSUInteger curLeafIndex;
@property (nonatomic,retain) NSMutableArray *leafControllers;
@end

@implementation LimbController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configListView];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    LeafEntity *leaf = nil;
    if (_limb.leafs.count>_curLeafIndex) {
        leaf = _limb.leafs[_curLeafIndex];
        [_leafMenuView switchTo:_curLeafIndex];
        [_carouselView scrollToItemAtIndex:_curLeafIndex animated:false];
    }else if(_limb.leafs.count>0){
        leaf = _limb.leafs[0];
        [_carouselView scrollToItemAtIndex:0 animated:false];
        [_leafMenuView switchTo:0];
    }
    if (leaf) {
        [self configNavigationItems:leaf];
    }else{
        if (self.rdv_tabBarController) {
            CenterController *center = (CenterController*)self.rdv_tabBarController;
            center.navigationItem.rightBarButtonItems = @[center.rightBarButtonItem];
        }else{
            self.navigationItem.rightBarButtonItems = nil;
        }
        
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    shouldScrollToLeaf =false;
}
/**
 *  初始化复用列表
 */
-(void)configListView{
    
    _carouselView = [[iCarousel alloc] initWithFrame:self.view.frame];
    _carouselView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _carouselView.dataSource = self;
    _carouselView.delegate = self;
    _carouselView.decelerationRate = 0.7;
    _carouselView.type = iCarouselTypeLinear;
    _carouselView.pagingEnabled = YES;
    _carouselView.edgeRecognition = YES;
    _carouselView.bounceDistance = 0.4;
    _carouselView.clipsToBounds = YES;
    [self.view addSubview:_carouselView];
    
    _topInset = NAV_H;
    self.automaticallyAdjustsScrollViewInsets = false;
    
    //RGB
    NSString *defaultColor = LeafDefaultColor;
    if (kCurApp.menuBar.backgroundColor) {
        defaultColor = kCurApp.sideBar.selected_bgcolor;
    }
    _selectedRGB = [UIColor colorWithHexString:defaultColor];
    _unselectedRGB = @[@(0),@(0),@(0)];
}
-(UICollectionView*)buildSortView
{
    //config some
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *sortView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, -SortMenuHeight, self.view.width, SortMenuHeight) collectionViewLayout:flow];
    sortView.bounces = false;
    sortView.backgroundColor = CRCOLOR_WHITE;
    sortView.delegate = self;
    sortView.dataSource = self;
    [sortView registerNib:[UINib nibWithNibName:@"LeafSortCell" bundle:nil]  forCellWithReuseIdentifier:@"Sort"];
    return sortView;
}

/**
 *  初始化二级菜单
 */
-(void)configLeafListView
{
    _leafMenuView = [Utility nibWithName:@"LeafListView" index:0];
    _leafMenuView.frame = CGRectMake(0, NAV_H, self.view.width,TopMenuHeight);
    _leafMenuView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    _leafMenuView.delegate = self;
    [self.view addSubview:_leafMenuView];
    
}
/**
 *  获取以及频道
 *
 *  @param leafID leafID
 */

-(void)reloadDataWithLeafID:(NSInteger)leafID
{
    shouldScrollToLeaf = true;
    shouldScrollToLeafID = leafID;
    [self getLimbWithLeafID:leafID];
}
/**
 *  刷新一级数据
 *
 *  @param limb;
 */
-(void)reloadDataWithLimb:(LimbEntity*)limb;
{
    if (limb.lid == _limb.lid) {
        return;
    }
    _limb = limb;
    [self reloadDataWithLimbID:_limb.lid];

}
/**
 *  刷新一级数据
 *
 *  @param limb;
 */
-(void)reloadDataWithLimbID:(NSInteger)limbID;
{
    [_leafControllers removeAllObjects];
    [_carouselView reloadData];
    [self getAllLeafsWith:limbID];
    
}
/**
 *  获取一级
 */

-(void)getLimbWithLeafID:(NSInteger)leafid{
    
    CRWeekRef(self);
    MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        [AppWindow addSubview:hud];
    }
    [hud show:true];
    CRWeekRef(hud);
    [MSGRequestManager Get:kAPIleafWithoutPub(leafid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if (CRJSONIsDictionary(data)) {
            [LocalManager storeObject:data forKey:CRString(@"leaf_limb_json_%d",leafid)];
            CRUserSetObj([NSDate date], CRString(@"leaf%d_limb_date",leafid));
            
            NSDictionary *limbJson = [Utility dictionaryValue:data forKey:@"limb"];
            if (!_limb) {
                _limb = [LimbEntity buildInstanceByJson:limbJson];
            }
            [__self getAllLeafsWith:_limb.lid];
            
        }else{
            msg = NetWorkAlert;
            [CustomToast showMessageOnWindow:msg];
        }
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__hud hide:true];
        NSDictionary *json = [LocalManager objectForKey:CRString(@"leaf_limb_json_%d",leafid)];
        if (json) {
            NSDictionary *limbJson = [Utility dictionaryValue:json forKey:@"limb"];
            if (!_limb) {
                _limb = [LimbEntity buildInstanceByJson:limbJson];
            }
            [__self getAllLeafsWith:_limb.lid];
        }else{
            msg = NetWorkAlert;
            [CustomToast showMessageOnWindow:msg];
        }
    }];
}


/**
 *  获取所有二级
 */
-(void)getAllLeafsWith:(NSInteger)lid
{
    CRWeekRef(self);
    MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        [AppWindow addSubview:hud];
    }
    if (!hud.isHidden) {
        [hud show:true];
    }
    [MSGRequestManager Get:kAPIGetLimb(lid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        if (CRJSONIsDictionary(data)) {
            if (!_limb) {
                _limb = [LimbEntity buildInstanceByJson:data];
            }
            NSArray *leafsJson = data[@"leafs"];
        
            
            
            [LocalManager storeObject:leafsJson forKey:CRString(@"json_leafs_limb%d",_limb.lid)];
            NSMutableArray *leafs = [NSMutableArray new];
            for (int i = 0; i<leafsJson.count;i++ ) {
                LeafEntity *leaf =[LeafEntity buildInstanceByJson:leafsJson[i]];
                leaf.filterID = [FilterManager curFilterId];
                if (shouldScrollToLeaf&&leaf.lid == shouldScrollToLeafID) {
                    _curLeafIndex = i;
                }
                [[PermissonManager  sharedManager] permissionForLeaf:leaf];
                if (!leaf.hiddeen) {
                    [leafs addObject:leaf];
                }
            }
            if (!_limb.leafs) {
                _limb.leafs = [NSMutableArray new];
            }
            [_limb.leafs removeAllObjects];
            [leafs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LeafEntity *leaf = obj;
                [_limb addLeaf:leaf];
            }];
            if (_limb.leafs.count>1) {
                _topInset = NAV_H + TopMenuHeight;
                [__self configLeafListView];
                [_leafMenuView reloadMenuWithLeafs:_limb.leafs];
            }
            [__self createLeafReusableViews];
            [leafs removeAllObjects];
        }else{
            [CustomToast showMessageOnWindow:@"加载失败请检查网络"];
        }
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        NSMutableArray *leafs = [__self leafCacheforLimb];
        if (leafs.count>0) {
            _limb.leafs = leafs;
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
-(NSMutableArray*)leafCacheforLimb{
    
    NSArray *jsonLeafs = [LocalManager objectForKey:CRString(@"json_leafs_limb%d",_limb.lid)];
    
    NSMutableArray *leafs = [NSMutableArray new];
    if (CRJSONIsArray(jsonLeafs)) {
        [jsonLeafs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (CRJSONIsDictionary(obj)) {
                LeafEntity *leaf = [LeafEntity buildInstanceByJson:obj];
                leaf.filterID = [FilterManager curFilterId];
                if (shouldScrollToLeaf&&leaf.lid == shouldScrollToLeafID) {
                    _curLeafIndex = idx;
                }
                [[PermissonManager  sharedManager] permissionForLeaf:leaf];
                leaf.limb = _limb;
                if (!leaf.hiddeen) {
                    [leafs addObject:leaf];
                }
            }
        }];
    }
    return leafs;
}
/**
 *  创建复用二级列表
 */
-(void)createLeafReusableViews
{
    _leafControllers = [NSMutableArray new];
    [_limb.leafs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        LeafEntity *leaf = obj;
        if ([leaf.ctype.systitle isEqualToString:@"dianshang2"]) {
            GridBusinessController *grid = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ListBusinessController"];
            grid.leaf = obj;
            [_leafControllers addObject:grid];
            [self addChildViewController:grid];

        }else  if([leaf.ctype.systitle isEqualToString:@"dianshang1"]){
            ListBusinessController *list = [Utility controllerInStoryboard:@"Main" withIdentifier:@"GridBusinessController"];
            list.leaf = obj;
            [_leafControllers addObject:list];
            [self addChildViewController:list];


        }else  if([leaf.ctype.systitle isEqualToString:@"jiugong"]){
            GridPhotoController *photo = [Utility controllerInStoryboard:@"Main" withIdentifier:@"GridPhotoController"];
            photo.leaf = obj;
            [_leafControllers addObject:photo];
            [self addChildViewController:photo];

        }else  if([leaf.ctype.systitle isEqualToString:@"chuchuang"]){
            ZakerListController *zakerlist = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ZakerListController"];
            zakerlist.leaf = obj;
            [_leafControllers addObject:zakerlist];
            [self addChildViewController:zakerlist];

        }else{
            DefaultListController *defaultList = [Utility controllerInStoryboard:@"Main" withIdentifier:@"DefaultListController"];
            defaultList.leaf = obj;
            [_leafControllers addObject:defaultList];
            [self addChildViewController:defaultList];
        }
        
    }];
    [_carouselView reloadData];
    LeafEntity *leaf = nil;
    if (_limb.leafs.count>_curLeafIndex) {
        leaf = _limb.leafs[_curLeafIndex];
        [_leafMenuView switchTo:_curLeafIndex];
        [_carouselView scrollToItemAtIndex:_curLeafIndex animated:false];
    }else if(_limb.leafs.count>0){
        leaf = _limb.leafs[0];
        [_carouselView scrollToItemAtIndex:0 animated:false];
        [_leafMenuView switchTo:0];
    }
    if (leaf) {
        [self configNavigationItems:leaf];
    }else{
        if (self.rdv_tabBarController) {
            CenterController *center = (CenterController*)self.rdv_tabBarController;
            center.navigationItem.rightBarButtonItems = @[center.rightBarButtonItem];
        }else{
            self.navigationItem.rightBarButtonItems = nil;
        }

    }
}
#pragma mark iCarousel methods
/**
 *  view的总数
 *
 *  @param carousel carouselView
 *
 *  @return view的数目
 */
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return _limb.leafs.count;
}
/**
 *  复用的view
 *
 *  @param carousel carouselView
 *  @param index    index
 *  @param view     view
 *
 *  @return view
 */
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    LeafEntity *leaf = CRArrayObject(_limb.leafs, index);
    CGFloat _contentInset = _topInset;
    UIView *contentView = [view viewWithTag:ContentTag];
    [contentView removeFromSuperview];
    
    if (leaf.req_permission) {
        
        view.bounds = CGRectMake(0, -_contentInset, carousel.width, carousel.height);
        BlankView  *_blankView = [BlankView blanViewWith:[UIImage imageNamed:@"ic_permission"] descr:@"对不起，您无权限查看该频道内容!" actionTitle:@"申请权限" target:self selector:@selector(requestPermissin:)];

        _blankView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blankView.frame = CGRectMake(0,0, view.width, view.bounds.size.height - _contentInset);
        _blankView.tag = ContentTag;
        [view addSubview:_blankView];
        return view;
        
    }
    UICollectionView *sortView = (UICollectionView*)[view viewWithTag:SortViewTag];
    if ([self sortValid:CRArrayObject(_limb.leafs, index)]) {
        _contentInset  = _topInset + SortMenuHeight;
    }
    [sortView reloadData];
    view.bounds = CGRectMake(0, -_contentInset, carousel.width, carousel.height);
    GridBusinessController *contentController = CRArrayObject(_leafControllers, index);
    contentController.leaf =CRArrayObject(_limb.leafs, index);
    if (contentController) {
        contentController.view.tag = ContentTag;
        [view addSubview:contentController.view];
        contentController.view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        contentController.view.frame = CGRectMake(0,0, view.width, view.bounds.size.height - _contentInset);
    }
    if ([self sortValid:CRArrayObject(_limb.leafs, index)]) {
        if (!sortView) {
            sortView = [self buildSortView];
            sortView.tag = SortViewTag;
            [view addSubview:sortView];
        }
    }
    return view;
}
/**
 *  切换view是调用
 *
 *  @param carousel  carouselView
 */
-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    
    _curLeafIndex = carousel.currentItemIndex;
    [_leafMenuView switchTo:_curLeafIndex];
    LeafEntity *leaf = _limb.leafs[_curLeafIndex];
    [self configNavigationItems:leaf];
    id<LeafControllerDelegate> leafVC = CRArrayObject(_leafControllers, _curLeafIndex);
    [LeafController leafController:leafVC listViewLoadData:[leafVC listView]];
}

-(void)configNavigationItems:(LeafEntity*)leaf
{
    self.navigationItem.title = _limb.title;
    NSArray *leafApps = [self validWebApps:leaf];
    
    if (leafApps.count == 0) {
        if (self.rdv_tabBarController) {
            CenterController *center = (CenterController*)self.rdv_tabBarController;
            center.navigationItem.rightBarButtonItems = @[center.rightBarButtonItem];
            
        }else{
            self.navigationItem.rightBarButtonItems = nil;
        }
        return;
    }
    _appItems = [NSMutableArray new];
    for (WebAppEntity *app in leafApps) {
        KxMenuItem *item = [KxMenuItem menuItem:app.title image:CRImageNamed(app.dropIcon.selected_icon) target:self action:@selector(appClicked:)];
        [_appItems addObject:item];
    }
    if (!leaf.readonly) {
        KxMenuItem *item = [KxMenuItem menuItem:@"投稿" image:[UIImage imageNamed:@"create_publication"] target:self action:@selector(createPub:)];
        [_appItems addObject:item];
    }
    if (_appItems.count == 1) {
        WebAppEntity *app = leafApps[0];
        UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *cach_image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:app.icon.selected_icon];
        if (cach_image) {
            [listButton setImage:[cach_image imageWithTintColor:[UIColor blackColor]] forState:UIControlStateNormal];
        }else{
            __weak UIButton *button = listButton;
            UIImage *dropImage = CRImageNamed(app.dropIcon.selected_icon);
            if (dropImage) {
                [listButton setImage:dropImage forState:UIControlStateNormal];
            }else{
                [listButton sd_setImageWithURL:CRURL(app.dropIcon.selected_icon) forState:UIControlStateNormal placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL *url) {
                    UIImage *newImage = [image imageWithTintColor:[UIColor blackColor]];
                    if (!newImage) {
                        newImage = [UIImage imageNamed:@"app_default"];
                    }
                    [button setImage:newImage forState:UIControlStateNormal];
                    image = nil;
                    newImage = Nil;
                }];
            }
        }
        listButton.frame = CGRectMake(0, 0, 27, 27);
        listButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        [listButton addTarget:self action:@selector(showApps:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *webList = [[UIBarButtonItem alloc] initWithCustomView:listButton];
        WebAppEntity *filter = CRWebAppTitle(@"tagfilter");
        if (self.rdv_tabBarController) {
            CenterController *center = (CenterController*)self.rdv_tabBarController;
            if (filter) {
                UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
                filterButton.tag = 13547;
                [filterButton setImage:[UIImage imageNamed:filter.dropIcon.normal_icon] forState:UIControlStateNormal];
                filterButton.frame = CGRectMake(0, 0, 23, 23);
                [filterButton addTarget:self action:@selector(showApps:) forControlEvents:UIControlEventTouchUpInside];
                UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
                center.navigationItem.rightBarButtonItems = @[center.rightBarButtonItem,webList,filterItem];
            }else{
                center.navigationItem.rightBarButtonItems = @[center.rightBarButtonItem,webList];
            }
        }else{
            if (filter) {
                UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
                filterButton.tag = 13547;
                [filterButton setImage:[UIImage imageNamed:filter.dropIcon.normal_icon] forState:UIControlStateNormal];
                filterButton.frame = CGRectMake(0, 0, 23, 23);
                [filterButton addTarget:self action:@selector(showApps:) forControlEvents:UIControlEventTouchUpInside];
                UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
                self.navigationItem.rightBarButtonItems = @[webList,filterItem];
            }else{
                self.navigationItem.rightBarButtonItem = webList;
            }
        }
    }else{
        
        UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [listButton setImage:[UIImage imageNamed:@"ic_applist"] forState:UIControlStateNormal];
        listButton.frame = CGRectMake(0, 0, 23, 23);
        [listButton addTarget:self action:@selector(showApps:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *webList = [[UIBarButtonItem alloc] initWithCustomView:listButton];
        WebAppEntity *filter = CRWebAppTitle(@"tagfilter");
        if (self.rdv_tabBarController) {
            CenterController *center = (CenterController*)self.rdv_tabBarController;
            if (filter) {
                UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
                filterButton.tag = 13547;
                [filterButton setImage:[UIImage imageNamed:filter.dropIcon.normal_icon] forState:UIControlStateNormal];
                filterButton.frame = CGRectMake(0, 0, 23, 23);
                [filterButton addTarget:self action:@selector(showApps:) forControlEvents:UIControlEventTouchUpInside];
                UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
                center.navigationItem.rightBarButtonItems = @[center.rightBarButtonItem,webList,filterItem];
            }else{
                center.navigationItem.rightBarButtonItems = @[center.rightBarButtonItem,webList];
            }
        }else{
            if (filter) {
                UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [filterButton setImage:[UIImage imageNamed:filter.dropIcon.normal_icon] forState:UIControlStateNormal];
                filterButton.tag = 13547;
                filterButton.frame = CGRectMake(0, 0, 23, 23);
                [filterButton addTarget:self action:@selector(showApps:) forControlEvents:UIControlEventTouchUpInside];
                UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
                self.navigationItem.rightBarButtonItems = @[webList,filterItem];
            }else{
                self.navigationItem.rightBarButtonItem = webList;
            }
        }
    }
}
# pragma mark - webapp列表

-(void)showApps:(UIButton*)sender{
    
    LeafEntity *leaf = _limb.leafs[_curLeafIndex];
    if (sender.tag == 13547) {
        WebAppEntity *app = CRWebAppTitle(@"tagfilter");
        NSString *initData = [NSString stringWithFormat:@"{\"leaf_id\":%d,\"leaf_type\":\"%@\"}",leaf.lid,leaf.ctype.systitle];
        NSDictionary *params = @{
                                 @"init_data":initData?initData:@"{}"
                                 };
        [MSGTansitionManager openWebApp:app withParams:params goBack:nil callBack:nil];
        return;
    }
    NSArray *leafApps = [self validWebApps:leaf];
    if (_appItems.count == 1) {
       WebAppEntity *app = leafApps[0];
        NSString *initData = [NSString stringWithFormat:@"{\"leaf_id\":%d,\"leaf_type\":\"%@\"}",leaf.lid,leaf.ctype.systitle];
        NSDictionary *params = @{
                                 @"init_data":initData?initData:@"{}"
                                 };
        [MSGTansitionManager openWebApp:app withParams:params goBack:nil callBack:nil];
        return;
    }
    CGRect frame = [sender.superview convertRect:sender.frame toView:AppWindow];
    [KxMenu showMenuInView:AppWindow fromRect:frame menuItems:_appItems];
    
}
# pragma mark - 打开webapp

-(void)appClicked:(KxMenuItem*)sender{
    //do something
    LeafEntity *leaf = _limb.leafs[_curLeafIndex];
    NSArray *apps = [self validWebApps:leaf];
    NSInteger index = [_appItems indexOfObject:sender];
    WebAppEntity *app = CRArrayObject(apps, index);
    NSString *initData = [NSString stringWithFormat:@"{\"leaf_id\":%d,\"leaf_type\":\"%@\"}",leaf.lid,leaf.ctype.systitle];
    NSDictionary *params = @{
                             @"init_data":initData?initData:@"{}"
                             };
    [MSGTansitionManager openWebApp:app withParams:params goBack:nil callBack:nil];
}
/**
 *  投稿
 *
 *  @param sender
 */
-(void)createPub:(id)sender{
    
    CRWeekRef(self);
    if (!LoginState) {
        [LoginHandler showLoginControllerFromController:CRRootNavigation() complete:^(BOOL loginState) {
            if (LoginState) {
                [__self createPub:sender];
            }
        }];
        return;
    }
    CreatPubController *creat = [Utility controllerInStoryboard:@"Main" withIdentifier:@"CreatPubController"];
    creat.groupDicts = nil;
    creat.createFinished = ^(BOOL result,id data){
        if (result) {
            ArticleEntity *article = data[@"article"];
            NSDictionary *pointInfo = data[@"point"];
            LeafEntity *leaf = __self.limb.leafs[__self.curLeafIndex];
            NSDictionary *params = @{
                                     @"article":CRString(@"%d",article.mid),
                                     @"leaf":CRString(@"%d",leaf.lid),
                                     @"app":CRString(@"%d",kCurApp.aid),
                                     @"approve":@"0"
                                     };
            [MSGRequestManager Post:kAPICreatePub params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                PubEntity *pub = [PubEntity buildInstanceByJson:data];
                
//                NSLog(@"data&&&&&&&& - %@",data);
                
                NSInteger filterID = [FilterManager curFilterId];
                NSDictionary *params = @{@"gfilterstructural":CRString(@"%d",filterID)};
                [MSGRequestManager MKUpdate:kAPIBindFilterID(pub.pid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                
                }];
                if (pointInfo) {
                    [__self doPointMessage:pointInfo];
                    
                }
                [CRRootNavigation() popViewControllerAnimated:true];
                id<LeafControllerDelegate> leaf = CRArrayObject(__self.leafControllers, _curLeafIndex);
                [leaf insert:pub];
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [CustomToast showMessageOnWindow:msg];
            }];

        }
    };
    [CRRootNavigation() pushViewController:creat animated:true];
    
}
-(void)doPointMessage:(NSDictionary*)pointInfo{
    if (pointInfo) {
        
        
        [ScoreUserActionManager doUserAction:USER_PUB_ACTION user:kCurUser.userName currentStatus:true success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            if (!msg) {
                
                NSInteger point = [pointInfo[@"point"] integerValue];
                NSString *type = pointInfo[@"point_type"];
                
//                NSLog(@"==================%d",point);
                
                if ([type isEqualToString:REDUCE]) {
                    [CustomToast showMessageOnWindow:CRString(@"积分减少！您当前积分为：%d",point)];
                }else{
                    [CustomToast showMessageOnWindow:CRString(@"积分增加！您当前积分为：%d",point)];
                }
            }
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            CRLog(@"%@",msg);
        }];
        
        
    }
    
    
    
}

//TODO:获取所有webApp
-(NSArray*)validWebApps:(LeafEntity*)leaf{
    
    if (leaf.req_permission&&leaf.hiddeen == false) {
        return nil;
    }
    NSArray *listApp = CRWebAppOptype(1);
    NSMutableArray *showApps = [NSMutableArray new];
    for (WebAppEntity *app in listApp) {
        if ([app.systitle isEqualToString:@"map"])
        {
            if ([leaf.ctype.systitle isEqualToString:@"dianshang2"]||[leaf.ctype.systitle isEqualToString:@"dianshang1"]||[leaf.ctype.systitle isEqualToString:@"liebiao"]) {
                if (![app.systitle isEqualToString:@"tagfilter"]) {
                    [showApps addObject:app];
                }
            }
            continue;
        }
        if (![app.systitle isEqualToString:@"tagfilter"]) {
            [showApps addObject:app];
        }
    }
    return showApps;
}
-(BOOL)sortValid:(LeafEntity*)leaf{
    
    __block BOOL result = false;
    WebAppEntity *sort = CRWebAppTitle(@"pub_sort");
    if (([leaf.ctype.systitle isEqualToString:@"dianshang2"]||[leaf.ctype.systitle isEqualToString:@"liebiao"])&&sort) {
        result = true;
    }
    return result;
}
/**
 *  点击index的view触发的事件
 *
 *  @param carousel carouselView
 *  @param index    index
 */
-(void)requestPermissin:(id)sender{
    
    LeafEntity *leaf   = CRArrayObject(_limb.leafs, _curLeafIndex);
    if (!leaf) {
        [CustomToast showMessageOnWindow:@"发生未知错误"];
        return;
    }
    if (!leaf.req_permission) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        [AppWindow addSubview:hud];
    }
    if (!hud.isHidden) {
        [hud show:true];
    }
    CRWeekRef(hud);
    NSDictionary *params = @{
                             @"title":@"申请权限",
                             @"content":CRString(@"该用户向您申请查看%@的权限",leaf.title)
                             };
    [MSGRequestManager MKPost:kAPILeafPermission params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__hud hide:true];
        [CustomToast showMessageOnWindow:@"发送成功"];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}
-(void)carousel:(iCarousel *)carousel panGestureRecognizer:(UIPanGestureRecognizer *)sender
{
   CGPoint pt = [sender velocityInView:carousel];
    if (pt.x > 0) {
        _scorollDirection = LeafChangeDirectionLeft;
    }else{
        _scorollDirection = LeafChangeDirectionRight;
    }
}
/**
 *  滚动过程中标题改变大小和颜色
 *
 *  @param carousel 滚动视图
 */
-(void)carouselDidScroll:(iCarousel *)carousel{
    
    CGFloat offsite = carousel.scrollOffset;
    NSInteger index = floor(offsite);
    CGFloat absScale = (offsite - index)*2/10.00f;
    if ((int)offsite == offsite) {
        return;
    }
    CGFloat absR = [_selectedRGB[0] floatValue] - [_unselectedRGB[0] floatValue];
    CGFloat absG = [_selectedRGB[1] floatValue] - [_unselectedRGB[1] floatValue];
    CGFloat absB = [_selectedRGB[2] floatValue] - [_unselectedRGB[2] floatValue];
    
    CGFloat absColor = offsite - index;
    if (_scorollDirection == LeafChangeDirectionRight) {
        
        NSInteger leafItemIndex = index + 1;
        LeafItemCell *curLeafItem = (LeafItemCell*)[_leafMenuView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        LeafItemCell *nextLeafItem = (LeafItemCell*)[_leafMenuView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:leafItemIndex inSection:0]];
        curLeafItem.titleView.transform = CGAffineTransformMakeScale(LeafMenuScale - absScale,LeafMenuScale - absScale);
        nextLeafItem.titleView.transform = CGAffineTransformMakeScale( 1.0f + absScale,1.0f + absScale);
        nextLeafItem.titleView.textColor = [UIColor colorWithRed:([_unselectedRGB[0] floatValue]+absR*absColor)/255.0f green:([_unselectedRGB[1] floatValue]+absG*absColor)/255.0f blue:([_unselectedRGB[2] floatValue]+absB*absColor)/255.0f alpha:1];
        curLeafItem.titleView.textColor = [UIColor colorWithRed:([_unselectedRGB[0] floatValue]+absR*(1-absColor))/255.0f green:([_unselectedRGB[1] floatValue]+absG*(1-absColor))/255.0f blue:([_unselectedRGB[2] floatValue]+absB*(1-absColor))/255.0f alpha:1];
        
    }else{
        
        NSInteger leafItemIndex = index + 1;
        LeafItemCell *curLeafItem = (LeafItemCell*)[_leafMenuView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:leafItemIndex inSection:0]];
        LeafItemCell *lastLeafItem = (LeafItemCell*)[_leafMenuView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        curLeafItem.titleView.transform = CGAffineTransformMakeScale(1.0f + absScale,1.0f + absScale);
        lastLeafItem.titleView.transform = CGAffineTransformMakeScale(LeafMenuScale - absScale,LeafMenuScale - absScale);
        curLeafItem.titleView.textColor = [UIColor colorWithRed:([_unselectedRGB[0] floatValue]+absR*absColor)/255.0f green:([_unselectedRGB[1] floatValue]+absG*absColor)/255.0f blue:([_unselectedRGB[2] floatValue]+absB*absColor)/255.0f alpha:1];
        lastLeafItem.titleView.textColor = [UIColor colorWithRed:([_unselectedRGB[0] floatValue]+absR*(1-absColor))/255.0f green:([_unselectedRGB[1] floatValue]+absG*(1-absColor))/255.0f blue:([_unselectedRGB[2] floatValue]+absB*(1-absColor))/255.0f alpha:1];

    }
}

-(void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate{
    
    
    
}

-(void)carouselWillBeginDragging:(iCarousel *)carousel{
    
    
}

-(void)carouselDidEndDecelerating:(iCarousel *)carousel{
    
    
}

-(void)changeToItem:(NSInteger)index
{
    [_carouselView scrollToItemAtIndex:index animated:false];
    
}

# pragma mark - sortDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(floor((collectionView.width - 30)/2), 30);
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LeafSortCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Sort" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.titleView.text = @"默认排序";
    }else{
        cell.titleView.text = @"离我最近";
    }    
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    id<LeafControllerDelegate>leafVC = CRArrayObject(_leafControllers,_carouselView.currentItemIndex);
    if (leafVC) {
        switch (indexPath.row) {
            case 0:
            {
                //默认排序

                [leafVC sort:SORT_NORMAL];
                
            }
                break;
            case 1:
            {
                //距离排序
                [leafVC sort:SORT_GPS];

            }
                break;
            default:
                break;
        }

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
