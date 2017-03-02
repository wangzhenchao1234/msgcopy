//
//  StandDeskTopViewController.m
//  Kaoke
//
//  Created by xiaogu on 14-6-5.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "StandStyleController.h"
#import <UIKit/UIKit.h>
#import "DeskTopItem.h"
#import "DeskTopItemModaul.h"
#import "AppBannerView.h"

@interface StandStyleController ()<UIScrollViewDelegate,MBProgressHUDDelegate>{
    
    NSMutableArray            * _limbs;
    UIScrollView              * _mainView;
    NSMutableArray            * _modauls;
    NSMutableArray            * _topItems;
    UIBarButtonItem           * titleItem;
    UILabel                   * _totalView;
    UILabel                   * _todayView;
    __block NSUInteger         _completCount;
    __block NSUInteger         _failureCount;
    BOOL                      _isRefreshing;
}
@property(nonatomic,retain)NSMutableArray *leafs;
@property(nonatomic,retain)MBProgressHUD *hud;

@end

@implementation StandStyleController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(AppBannerView*)bannerView{
    return _bannerView;
}
-(void)reloadData{
    [self getLeafsWithAllLimb];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    CRWeekRef(self);
    [__self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AppBannerView class]]) {
            AppBannerView *banner = obj;
            [banner stopAnimation];
        }
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    CRWeekRef(self);
    [__self.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AppBannerView class]]) {
            AppBannerView *banner = obj;
            [banner startAnimation];
        }
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadData];
    // Do any additional setup after loading the view.
}
/**
 *  初始化数据
 */
-(void)intilizedData{
    if (!_topItems) {
        _topItems = [NSMutableArray new];
    }
    if (!_leafs) {
        _leafs = [NSMutableArray new];
    }
    if (!_modauls) {
        _modauls = [NSMutableArray new];
    }
    [_leafs removeAllObjects];
    [_modauls removeAllObjects];
    _limbs = [PermissonManager sharedManager].authLimbs;
    for (LimbEntity *limb in _limbs) {
        for (LeafEntity *leaf in limb.leafs) {
            [_leafs addObject:leaf];
        }
    }
    [self createModauls];
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

//TODO:转换模型
-(void)clearLastModels{
    
    [_modauls removeAllObjects];
    for (int i = 0;i<_topItems.count;i++) {
        DeskTopItem *item = _topItems[i];
        [item removeFromSuperview];
        item = nil;
    }
    [_mainView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = obj;
        [view removeFromSuperview];
    }];
    [_topItems removeAllObjects];
    
}
/**
 *  创建模型
 */
-(void)createModauls{
    
    [self clearLastModels];
    for (int i = 0; i< _leafs.count;i++) {
        LeafEntity *leaf = _leafs[i];
        DeskTopItemModaul *modaul = [[DeskTopItemModaul alloc] init];
        modaul.imageUrls = [self getImageUrlsFromLeaf:leaf];
        modaul.subTitles = [self getSubTitlesFromeLeaf:leaf];
        modaul.title = leaf.title;
//        if (i == 0) {
//            modaul.size = 0;
//            [_modauls addObject:modaul];
//            DeskTopItem *item = [[DeskTopItem alloc] initWithData:modaul];
//            [_topItems addObject:item];
//            continue;
//        }
        if(i < _leafs.count-1){
            switch ((i+1)%15) {
                case 1:
                    modaul.size = 1;
                    break;
                case 5:
                    modaul.size = 2;
                    break;
                case 12:
                    modaul.size = 4;
                    break;
                default:
                    modaul.size = 3;
                    break;
            }
        }
        if (i == _leafs.count-1) {
            
            switch (i%15) {
                case 0:
                    modaul.size = 1;
                    break;
                case 1:
                    modaul.size = 1;
                    break;
                case 2:
                    modaul.size = 2;
                    break;
                case 3:
                    modaul.size = 3;
                    break;
                case 4:
                    modaul.size = 1;
                    break;
                case 5:
                    modaul.size = 3;
                    break;
                case 6:
                    modaul.size = 1;
                    break;
                case 7:
                    modaul.size = 2;
                    break;
                case 8:
                    modaul.size = 3;
                    break;
                case 9:
                    modaul.size = 1;
                    break;
                case 10:
                    modaul.size = 2;
                    break;
                case 11:
                    modaul.size = 4;
                    break;
                case 12:
                    modaul.size = 1;
                    break;
                case 13:
                    modaul.size = 1;
                    break;
                case 14:
                    modaul.size = 2;
                    break;
                default:
                    modaul.size = 3;
                    break;
            }
        }
        [_modauls addObject:modaul];
        DeskTopItem *item = [[DeskTopItem alloc] initWithData:modaul];
        [_topItems addObject:item];
    }
    [self buildMainView];
    
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



/**
 *  创建主view
 */
-(void)buildMainView{
    
    CGFloat height = 0;
    if (_mainView == nil) {
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        _mainView = [[UIScrollView alloc] initWithFrame:frame];
        _mainView.alwaysBounceVertical= YES;
        _mainView.delegate = self;
        _mainView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_mainView];
        _mainView.contentInset = UIEdgeInsetsMake(NAV_H, 0, 0, 0); //提供一个下拉刷新的时候顶部的停留
        
        if (kCurApp.sideBar.kind == SidBarKindBottom) {    //底部菜单栏
            _mainView.contentInset = UIEdgeInsetsMake(NAV_H, 0, TAB_H, 0);
        }
        if ([self hasBanner]) {   //有轮播图
            AppBannerEntity *banner = CRBannerForTitle(AppBannerTypeDeskTop);//首页级别
            _bannerView = [AppBannerView buildInatanceByBanner:banner target:self frame:CGRectMake(0, 0, self.view.frame.size.width, height)];
            _bannerView.layer.borderColor = [[UIColor colorWithWhite:0.95 alpha:0.9] CGColor];
            _bannerView.layer.borderWidth = 2.5;
            [_mainView addSubview:_bannerView];
        }
    }
    
    //主页不为空
    if ([self hasBanner]) {
        AppBannerEntity *banner = CRBannerForTitle(AppBannerTypeDeskTop);
        height = banner.height;
    }
    for (int i = 0; i<_topItems.count; i++) {
        DeskTopItem *item = _topItems[i];
        item.clickView.tag = 1000000+i;
        [item.clickView addTarget:self action:@selector(clickLeaf:) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame = item.frame;
        if (i == 0) {
            frame.origin.y = height;
            item.frame = frame;
            [_mainView addSubview:item];
        }else{
            DeskTopItem *lItem = _topItems[i-1];
            switch ((i+1)%15) {
                case 11:
                {
                    if (i == _topItems.count-1) {
                        frame.origin.x = lItem.frame.origin.x +lItem.frame.size.width;
                        frame.origin.y = lItem.frame.origin.y;
                        if (lItem.frame.origin.x+lItem.frame.size.width >= self.view.frame.size.width) {
                            frame.origin.x = 0;
                            frame.origin.y = lItem.frame.origin.y+lItem.frame.size.height;
                        }
                        item.frame = frame;
                    }else{
                        frame.origin.x = 0;
                        frame.origin.y =lItem.frame.origin.y+lItem.frame.size.height;
                        item.frame = frame;
                    }
                    
                }
                    break;
                case 12:
                {
                    frame.origin.x = lItem.frame.size.width;
                    frame.origin.y = lItem.frame.origin.y - lItem.frame.size.height;
                    item.frame = frame;                 }
                    
                    break;
                default:
                {
                    frame.origin.x = lItem.frame.origin.x +lItem.frame.size.width;
                    frame.origin.y = lItem.frame.origin.y;
                    if (lItem.frame.origin.x+lItem.frame.size.width >= self.view.frame.size.width) {
                        frame.origin.x = 0;
                        frame.origin.y = lItem.frame.origin.y+lItem.frame.size.height;
                    }
                    item.frame = frame;
                }
                    break;
            }
        }
        [_mainView addSubview:item];
        if (i == _topItems.count - 1) {
            _mainView.contentSize = item.frame.origin.y+item.frame.size.height>self.view.frame.size.height?CGSizeMake(self.view.frame.size.width,item.frame.origin.y+item.frame.size.height): CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        }
    }
    
//    //首页显示今日浏览量和总浏览量
//    
//    bool isShow = false;      //是否显示访问量
//    
//    if (isShow) {
//        int totalPV = 100; //总浏览量
//        int todayPV = 34; //今日浏览量
//        
//        //total
//        _totalView = [[UILabel alloc] initWithFrame:CGRectMake(0, _mainView.frame.size.height - 50, _mainView.frame.size.width/2, 50)];
//        _totalView.backgroundColor = [UIColor redColor];
//        _totalView.text = [NSString stringWithFormat:@"总浏览量：%d",totalPV];
//        [_mainView addSubview:_totalView];
//        
//        //today
//        _todayView = [[UILabel alloc] initWithFrame:CGRectMake(_mainView.frame.size.width/2, _mainView.frame.size.height - 50, _mainView.frame.size.width/2, 50)];
//        _todayView.backgroundColor = [UIColor greenColor];
//        _todayView.text = [NSString stringWithFormat:@"今日浏览量：%d",todayPV];
//        [_mainView addSubview:_todayView];
//    }
    

}
/**
 *  点击显示二级频道
 *
 *  @param sender
 */
-(void)clickLeaf:(UIButton*)sender{
    
    LeafEntity *leaf    = _leafs[sender.tag - 1000000];
    [MSGTansitionManager openLeafWithID:leaf.lid withParams:nil];
}
/**
 *  获取占位图
 *
 *  @param leaf
 *
 *  @return
 */
-(NSMutableArray *)getImageUrlsFromLeaf:(LeafEntity*)leaf{
    NSMutableArray *imageUrls = [NSMutableArray new];
    if (leaf.placeholder.imageUrl) {
        NSString *url = leaf.placeholder.imageUrl;
        [imageUrls addObject:url];
        return imageUrls;
    }
    for (PubEntity *item in leaf.homePubs) {
        NSString *url;
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
        [imageUrls addObject:url];
    }
    return imageUrls;
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

/**
 *  获取二级显示标题子标题
 *
 *  @param leaf 二级
 *
 *  @return 标题
 */
-(NSMutableArray *)getSubTitlesFromeLeaf:(LeafEntity*)leaf{
    if (leaf.placeholder.imageUrl||leaf.homePubs.count==0) {
        return  nil;
    }
    NSMutableArray *subTitles = [NSMutableArray new];
    for (PubEntity *item in leaf.homePubs) {
        NSString *title = item.article.title;
        [subTitles addObject:title];
    }
    return subTitles;
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
