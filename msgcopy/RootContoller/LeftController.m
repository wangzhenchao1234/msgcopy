//
//  LeftViewController.m
//  msgcopy
//
//  Created by Gavin on 15/4/10.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "LeftController.h"
#import "LeftCell.h"
#import "FilterController.h"

#define  TopMar MSGAppHeightScale(640, 140)
#define  BottomMar MSGAppHeightScale(640, 140)

@interface LeftController ()<UITableViewDataSource,UITableViewDelegate>
{
    CenterController *_rootCenter;
}
@property (retain, nonatomic) UITableView *tableView;
@property (retain,nonatomic) UIImageView *backgroindImageView;
@property (retain,nonatomic) UIButton *filterButton;
@end

@implementation LeftController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationController *nav =(UINavigationController*)self.g_sliderViewController.centerViewController;
    _rootCenter = nav.viewControllers[0];
    [self configTableView];
    [self configfilterView];
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /**
     *  可以点击全局过滤按钮
     */
    CRRootNavigation().navigationBar.userInteractionEnabled = false;
    [self.tableView reloadData];
    [self renderTableView];
    [self configfilterView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
/**
 *  configfilterView
*/
-(void)configfilterView
{
    [_filterButton removeFromSuperview];
    if (![FilterManager isValid]) {
        return;
    };
    _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _filterButton.frame = CGRectMake(App3xScale(65),App3xScale(60), 60, App3xScale(42));
    _filterButton.backgroundColor = [UIColor colorWithWhite:1 alpha:.4];
    _filterButton.layer.cornerRadius = App3xScale(42)/2.0;
    _filterButton.titleLabel.font = MSGYHFont(14);
    [_filterButton addTarget:self action:@selector(filterClick:) forControlEvents:UIControlEventTouchUpInside];
    [_filterButton setImage:[UIImage imageNamed:@"ic_position"] forState:UIControlStateNormal];
    [self.view addSubview:_filterButton];
    [self refreshFilterButton];
}
/**
 *  refreshFilterButton
 */
-(void)refreshFilterButton
{
    [_filterButton setTitle:CRString(@" %@ ",[FilterManager curFilterName]) forState:UIControlStateNormal];
    [_filterButton setTitleColor:CRCOLOR_WHITE forState:UIControlStateNormal];
    [_filterButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_filterButton sizeToFit];
    _filterButton.height = App3xScale(46);
    _filterButton.width += 15;
    
}
/**
 *  配置tableView
 */
-(void)configTableView
{
   
    _backgroindImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroindImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_backgroindImageView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TopMar, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - BottomMar - TopMar)];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = CRCOLOR_CLEAR;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
}

-(void)renderTableView
{
    NSString *_headUrl = kCurUser.head320;
    if (_headUrl) {
        __block UIImage *_cachImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_headUrl];
        if (!_cachImage) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(_headUrl) options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (image) {
                    UIImage *newImage = [image applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.000 alpha:0.100] saturationDeltaFactor:1.0 maskImage:nil];
                    _backgroindImageView.image = newImage;
                }
            }];
        }else{
            _backgroindImageView.image = [_cachImage applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.000 alpha:0.100] saturationDeltaFactor:1.0 maskImage:nil];
        }
    }else{
        _backgroindImageView.image = effectUserImage;
    };

}

# pragma mark - actions
/**
 *  点击显示右栏
 *
 *  @param sender 按钮
 */
-(void)filterClick:(id)sender
{
    FilterController *filter = [Utility controllerInStoryboard:@"Main" withIdentifier:@"FilterController"];
    WebAppEntity *app = CRWebAppTitle(@"globalfilter");
    filter.title = app.title;
    filter.conditions = [FilterManager filterData];
    [CRRootNavigation() pushViewController:filter animated:true];
    
}



#pragma mark - tableviewDelegate or datasuorce

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return kCurCustomBarItems.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return  MSGAppHeightScale(640, 88);
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifire = @"LeftCell";
    LeftCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifire];
    if (!cell) {
        cell = [Utility nibWithName:@"LeftCell" index:0];
    }
    id data = CRArrayObject(kCurCustomBarItems, indexPath.row);
    if(data)
        [cell buidWithData:kCurCustomBarItems[indexPath.row]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CRWeekRef(self);
    id data = CRArrayObject(kCurCustomBarItems, indexPath.row);
    if (data){
        [self.g_sliderViewController showCenterWithAnimation:true complete:^(BOOL finished) {
            
            if ([data isMemberOfClass:[HomeConfigEntity class]]) {
                /**
                 * 指向首页
                 */
                [__self HomeClicked:data];
            }else if ([data isMemberOfClass:[LimbEntity class]]) {
                /**
                 *  指向以及频道
                 *
                 *  @param LimbEntity 一级
                 *
                 */
                LimbEntity *limb = data;
                [MSGTansitionManager openLimbWithID:limb.lid withParams:nil];
                
            }else if([data isMemberOfClass:[WebAppEntity class]]){
                /**
                 *  指向webapp
                 *
                 *  @param WebAppEntity
                 *
                 */
                WebAppEntity *app = data;
                [MSGTansitionManager openWebappWithID:app.aid withParams:nil goBack:nil callBack:nil];
            }else if([data isMemberOfClass:[DiyPageEntity class]]){
                /**
                 *  指向自定义页面
                 *
                 *  @param DiyPageEntity
                 *
                 */
                DiyPageEntity *page = data;
                [MSGTansitionManager openDiyPageWithID:page.dpid withParams:nil];
                
            }else if([data isMemberOfClass:[ArticleEntity class]]){
                /**
                 *  指向各种类型的收藏
                 *
                 *  @param ArticleEntity
                 *
                 */
//                ArticleEntity *msg = (ArticleEntity*)data;
                
            }else if([data isMemberOfClass:[PubEntity class]]){
                /**
                 * 只想各种类型收藏
                 *
                 *  @param PubEntity
                 *
                 */
                PubEntity *pub = data;
                [MSGTansitionManager openPubWithID:pub.pid withParams:nil];
                
            }else if([data isMemberOfClass:[BaseTabItemEntity class]]){
                
                /**
                 *  指向基础功能
                 *
                 *  @param BaseTabItemEntity
                 *
                 */
                BaseTabItemEntity *tab = (BaseTabItemEntity*)data;
                [tab doAction];
                
            }else if([data isMemberOfClass:[LeafEntity class]]){
                
                LeafEntity *leaf = (LeafEntity*)data;
                [MSGTansitionManager openLeafWithID:leaf.lid withParams:nil];
                
            }
        }];
    }
}

#pragma mark - 打开首页
/**
 *  打开首页
 *
 *  @param  sender 内容
 */
-(void)HomeClicked:(HomeConfigEntity*)home
{
    if (home.kind == AppHomeKindLimb) {
        /**
         *  如果首页指向一级频道
         */
        [_rootCenter setSelectedIndex:1];
        LimbEntity *limb = [[LimbEntity alloc] init];
        limb.title = home.title;
        limb.lid = home.addr;
        LimbController *limbCon = _rootCenter.viewControllers[1];
        [limbCon reloadDataWithLimb:limb];
        [_rootCenter showTitleView];
    }else{
        /**
         *  如果首页指向其他首页类型
         */
        [_rootCenter setSelectedIndex:0];
        [_rootCenter showTitleView];
    }
}

#pragma mark - 打开一级
/**
 *  打开一级
 *
 *  @param limb 一级entity
 */
-(void)limbClicked:(LimbEntity*)limb
{
    [_rootCenter setSelectedIndex:1];
    LimbController *limbCon = _rootCenter.viewControllers[1];
    [limbCon reloadDataWithLimb:limb];
    [_rootCenter setTitle:limb.title];

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
