//
//  ShopViewController.m
//  Kaoke
//
//  Created by wngzc on 15/3/12.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "ShopViewController.h"
#import "ShopItemView.h"
#import "ShopLimbCell.h"
#import "ShopAddrCell.h"

#define PLACE 10
#define CellWidth (AppWindow.width - 30)/2

#define LoginSize 100

#define HeaderH (40+App3xScale(LoginSize)+5+10+App3xfont(16)+2 + App3xfont(14)+2 + 10)


#define TW AppWindow.width/4

#define TH 16

#define IW 25
#define IH 25

#define TP 10
#define BP 10

#define SP 5



@interface ShopViewController()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel *shopDescrView;
    UILabel *shopTitle;
    UIImageView *shopLogoView;
    UIImageView *shopBgImageView;
    BOOL _isAllLoaded;
}

@property (retain, nonatomic) UIView *shopHeaderView;
@property (retain, nonatomic) UITableView *listView;
@property(nonatomic,assign) NSInteger curPage;
@property(nonatomic,retain)NSMutableArray *limbs;
@property(nonatomic,retain)NSMutableArray *pubDatas;
@property (retain, nonatomic)ShopItemView *headerView;
@property (retain, nonatomic) UIImageView *headerCoverView;
@property (nonatomic,retain) UILabel *headerLine;
@end

@implementation ShopViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configTableView];
    [self configHeaderView];
    [self performSelector:@selector(loadDataSource) withObject:nil afterDelay:0.5];
    // Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavBarTransParent];
    NSInteger vcCount = self.navigationController.viewControllers.count;
    UIViewController *backVc = self.navigationController.viewControllers[vcCount - 2];
    [Utility setController:backVc backTitle:nil image:WhiteBackImage color:CRCOLOR_WHITE];

}
-(void)viewDidAppear:(BOOL)animated
{
    CGPoint pt = _listView.contentOffset;
    _listView.contentOffset = pt;
}
-(void)setNavBarTransParent
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [Utility setTransparentNavigation:CRRootNavigation() navBarTransparent:TransParentNavBg];

}
-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [Utility setDefaultNavigation:CRRootNavigation()];
    
}
/**
 *  配置headerView
 */
-(void)configHeaderView{
    
    _headerView = [Utility nibWithName:@"ShopItemView" index:0];
    /**
     shopHeader
     :returns:
     */
    _shopHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, HeaderH)];
    [self.view addSubview:_shopHeaderView];
    _shopHeaderView.backgroundColor = CRCOLOR_WHITE;
    _shopHeaderView.clipsToBounds = true;
    
    shopBgImageView = [[UIImageView alloc] initWithFrame:_shopHeaderView.bounds];
    shopBgImageView.backgroundColor = [UIColor colorFromHexRGB:@"dedede"];
    [_shopHeaderView addSubview:shopBgImageView];
    
    shopLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, App3xScale(LoginSize),App3xScale(LoginSize))];
    shopLogoView.center = CGPointMake(_shopHeaderView.width/2.0f, 40 + App3xScale(LoginSize/2.0f));
    shopLogoView.layer.cornerRadius = shopLogoView.height/2.0f;
    shopLogoView.clipsToBounds = true;
    [_shopHeaderView addSubview:shopLogoView];
    
    shopTitle = [[UILabel alloc] initWithFrame:CGRectMake(10 ,shopLogoView.y + shopLogoView.height + 5 , self.view.width - 20,App3xfont(16)+2)];
    shopTitle.text = _shopData.title;
    shopTitle.font = MSGYHFont(16);
    shopTitle.textAlignment = NSTextAlignmentCenter;
    shopTitle.textColor = CRCOLOR_WHITE;
    
    shopDescrView = [[UILabel alloc] initWithFrame:CGRectMake(10 ,shopTitle.y + shopTitle.height + 10 , self.view.width - 20,App3xfont(14)+2)];
    shopDescrView.font = MSGYHFont(14);
    shopDescrView.textAlignment = NSTextAlignmentCenter;
    shopDescrView.textColor = CRCOLOR_WHITE;
    shopDescrView.text = _shopData.descr;
    
    _headerLine = [[UILabel alloc] initWithFrame:CGRectMake(0, HeaderH - 1.0f/ScreenScale, _shopHeaderView.width, 1.0f/ScreenScale)];
    _headerLine.backgroundColor = [UIColor lightGrayColor];
    _headerLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _headerLine.alpha = 0;
    
    [_shopHeaderView addSubview:shopTitle];
    [_shopHeaderView addSubview:shopDescrView];
    
    
    _headerCoverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, HeaderH)];
    _headerCoverView.backgroundColor = [UIColor colorWithWhite:1 alpha:.95];
    _headerCoverView.alpha = 0;
    [_shopHeaderView addSubview:_headerCoverView];
    
    [_shopHeaderView addSubview:_headerLine];

    UIImage *cachLogo = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_shopData.thumbnail.turl];
    if (!_shopData.thumbnail.turl) {
        return;
    }
    if (!cachLogo) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(_shopData.thumbnail.turl) options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            shopLogoView.image = image;
            UIImage *newImage = [image applyTintEffectWithColor:[UIColor colorWithWhite:0 alpha:.02]];
            shopBgImageView.image = newImage;
        }];
    }else{
        shopLogoView.image = cachLogo;
        UIImage *newImage = [cachLogo applyTintEffectWithColor:[UIColor colorWithWhite:0.4 alpha:.05]];
        shopBgImageView.image = newImage;
    }
    
}
/**
 *  配置TableView
 */
-(void)configTableView
{
    self.automaticallyAdjustsScrollViewInsets = false;
    _listView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.contentInset = UIEdgeInsetsMake(HeaderH, 0, 0, 0);
    [self.view addSubview:_listView];
    _listView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listView.backgroundColor = [UIColor colorFromHexRGB:@"f8f8f8"];
    [_listView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}
/**
 *  lisenteTableview
 *
 *  @param scrollView tableView
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (![keyPath isEqualToString:@"contentOffset"]|| CRRootNavigation().visibleViewController != self) {
        return;
    }
    shopTitle.textColor = [UIColor whiteColor];
    CGFloat beginTitle = shopLogoView.y + shopLogoView.height + 5;
    CGFloat absTitle = beginTitle - 20 - (44-shopTitle.height)/2.0f ;
    CGFloat absScr = HeaderH;
    CGFloat absAlph = 1;
    CGFloat y = _listView.contentOffset.y;
    CGFloat shopHeaderHight = absScr;
    CGFloat absHeaderHight = absScr  - NAV_H;
    if (y<0&&y>=-HeaderH) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        if (shopTitle.superview == _shopHeaderView&&y > -HeaderH) {
            CGRect frame = [_shopHeaderView convertRect:shopTitle.frame toView:self.view];
            [self.view addSubview:shopTitle];
            shopTitle.frame = frame;
        }
        
        CGFloat alpha = absAlph - ABS(y)/HeaderH;
        _headerCoverView.alpha = alpha;
        shopLogoView.alpha = absAlph - alpha;
        shopDescrView.alpha = absAlph - alpha;
        _headerLine.alpha = 0;
        
        CGFloat titleMove = beginTitle - absTitle + absTitle*ABS(y)/absScr;
        shopTitle.y = titleMove;
        _shopHeaderView.height = shopHeaderHight -  absHeaderHight*(absScr-ABS(y))/shopHeaderHight;
        NSInteger vcCount = self.navigationController.viewControllers.count;
        UIViewController *backVc = self.navigationController.viewControllers[vcCount - 2];
        [Utility setController:backVc backTitle:nil image:WhiteBackImage color:CRCOLOR_WHITE];
    }
    if (y<=-HeaderH) {
        _headerCoverView.alpha = 0;
        _headerLine.alpha = 0;
        shopTitle.y = beginTitle;
        CGRect frame = [self.view convertRect:shopTitle.frame toView:_shopHeaderView];
        [_shopHeaderView addSubview:shopTitle];
        shopTitle.frame = frame;
        _shopHeaderView.height = shopHeaderHight;
        
    }
    if (y >= 0) {
        NSInteger vcCount = self.navigationController.viewControllers.count;
        UIViewController *backVc = self.navigationController.viewControllers[vcCount - 2];
        [Utility setController:backVc backTitle:nil image:BlackBackImage color:CRCOLOR_BLACK];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        shopTitle.y = 20 + 44/2.0f - shopTitle.height/2.0f;
        _headerCoverView.alpha = 1;
        _headerLine.alpha = 1;
        _shopHeaderView.height = NAV_H;
        shopTitle.textColor = [UIColor blackColor];
    }
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat y = scrollView.contentOffset.y;
    if (y<=-HeaderH) {
        scrollView.contentOffset = CGPointMake(0, -HeaderH);
    }
}
/**
 *  loadDatadsource
 */
-(void)loadDataSource
{
    
    MBProgressHUD *hudView= [[MBProgressHUD alloc] initWithWindow:AppWindow];
    [AppWindow addSubview:hudView];
    [hudView show:true];
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIShopLimbs(_shopData.sid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hudView hide:true];
        if (!_limbs) {
            _limbs = [NSMutableArray new];
        }
        NSArray *limbsJson = data;
        [limbsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LimbEntity *limb = [LimbEntity buildInstanceByJson:obj];
            [_limbs addObject:limb];
        }];
        if (_limbs.count>0) {
            [_headerView buildWithLimbs:_limbs];
            _listView.tableHeaderView = _headerView;
        }else{
            _listView.tableHeaderView  = nil;
        }
        [__self getPubData:0];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hudView hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}
/**
 *  加载投稿
 *
 *  @param page 页数
 */
-(void)getPubData:(NSInteger)page{
    
    [MSGRequestManager Get:kAPIShopPubs(_shopData.sid,page) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if (!_pubDatas) {
            _pubDatas = [NSMutableArray new];
        }
        if ([data count] >0) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                StoreLimbEntity *entity = [StoreLimbEntity buildWithJson:obj];
                [_pubDatas addObject:entity];
            }];
            [_listView reloadData];
        }else{
            _isAllLoaded = true;
        }
        if (_pubDatas.count == 0) {
            UILabel *blank = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
            blank.textColor = [UIColor colorFromHexRGB:@"9a9a9a"];
            blank.textAlignment = NSTextAlignmentCenter;
            blank.backgroundColor = [UIColor clearColor];
            blank.text = @"不好意思小店还没开张!";
            _listView.backgroundView = blank;
        }else{
            _listView.backgroundView = nil;
        }
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
    }];

}
-(void)dealloc{
    
    [_listView removeObserver:self forKeyPath:@"contentOffset"];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
#pragma mark - tableviewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_shopData.streetaddr&&indexPath.section == 0) {
        return 54;
    }
    StoreLimbEntity *store = _pubDatas[indexPath.row];
    NSArray *pubs = store.publications;
    CGFloat height = [ShopLimbCell getHeight:pubs];
    return height;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_shopData.streetaddr) {
        return 2;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_shopData.streetaddr&&section == 0) {
        return 1;
    }
    return _pubDatas.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (_shopData.streetaddr&&indexPath.section == 0) {
        static NSString *addrCell = @"ShopAddrCell";
        ShopAddrCell *cell = [tableView dequeueReusableCellWithIdentifier:addrCell];
        if (!cell) {
            cell = [Utility nibWithName:addrCell index:0];
        }
        NSString *addrStr = CRString(@"%@%@%@%@",_shopData.streetaddr[@"prov"],_shopData.streetaddr[@"city"],_shopData.streetaddr[@"dist"],_shopData.streetaddr[@"street"]);
        cell.addrView.text = addrStr;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    StoreLimbEntity *store = _pubDatas[indexPath.row];
    ShopLimbCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LimbCell"];
    if (!cell) {
        cell = [Utility nibWithName:@"ShopLimbCell" index:0];
    }
    [cell buildWithData:store];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (_shopData.lat&&_shopData.lng&&indexPath.section == 0) {
        WebAppEntity *app = CRWebAppTitle(@"map/route");
        NSString *appDataStr = CRString(@"{\"x\":%@,\"y\":%@}",_shopData.lng,_shopData.lat);
        NSDictionary *params = @{@"init_data":appDataStr};
        [MSGTansitionManager openWebApp:app withParams:params goBack:nil callBack:nil];
    }
}

@end
