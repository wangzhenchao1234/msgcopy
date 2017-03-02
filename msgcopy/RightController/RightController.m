//
//  RightController.m
//  msgcopy
//
//  Created by wngzc on 15/5/7.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "RightController.h"
#import "RightCell.h"
#import "UserHeaderView.h"
#import "XMTabBarController.h"
#import "UserInfoController.h"
#import "QRCodeController.h"
#import "MsgController.h"
#import "MCenterController.h"
#import "VirtualPayController.h"
#import "MSGTabBarItem.h"
#import "ContactController.h"
#import "SignView.h"
#import "ChangePwdController.h"
#import "UserHelperController.h"
#define TopInset 240


#define UserHeadSize Tab_Scale*75

#define TopHeaderHeight Tab_Scale*TopInset

static NSString *CellIdentifire = @"SettingCell";

#import <RDVTabBarController/RDVTabBarItem.h>


//static NSString *reuseridenfire = @"RightCell";

@interface RightController ()<RDVTabBarDelegate>
{
    NSMutableArray *_allMenus;
    NSMutableArray *_apps;
    NSMutableArray *_baseApps;
    NSMutableArray *_others;
    
    UIImage *_darkSetting;
    UIImage *_lightSetting;
    UIViewController *_backVc;
    NSArray *_backgroundColors;
    
    UIImage *settingImage;
    UIButton *settingButton;
    NSInteger chatMessageUnreadCount;
    NSInteger serverChatMessageUnreadCount;
    
    RDVTabBarItem *messageItem;
    //设置变量
    NSArray *countSettings;
    NSArray *functionSettings;
    NSMutableArray *about;
    BOOL hasUserHelper;
    
}
@property (nonatomic,retain) RDVTabBar *menuBar;
@property (nonatomic,retain) UIImageView *headerImageView;
@property (nonatomic,retain) UserHeaderView *userImageView;
@property (nonatomic,retain) UILabel *nickView;
@property (nonatomic,retain) UILabel *modView;
@property(nonatomic,strong)UILabel*userNameLabel;
@end

@implementation RightController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self configNavigationItem];
    [self configTableView];
    [self configHeaderView];
    [self configmenuBar];
    [self intilizedDataSource];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollViewDidScroll:self.tableView];
    [self.tableView reloadData];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateMessages:nil];
    //    [self updateChatMessages:nil];
    NSInteger vcCount = self.navigationController.viewControllers.count;
    _backVc = self.navigationController.viewControllers[vcCount - 2];
    [Utility setController:_backVc backTitle:nil image:WhiteBackImage color:CRCOLOR_WHITE];
    [self renderHeaderViews];
    
    if (LoginState) {
        countSettings = @[@[@"修改密码"],@[[UIImage imageNamed:@"modify_pwd"]]];
    }else{
        countSettings = @[];
    }
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [Utility setController:_backVc backTitle:nil image:BlackBackImage color:CRCOLOR_BLACK];
    [Utility setDefaultNavigation:CRRootNavigation()];
}

/**
 *  配置导航栏菜单
 */

-(void)configNavigationItem
{
    //    settingImage = [[UIImage imageNamed:@"ic_setting"] imageWithTintColor:CRCOLOR_WHITE];
    //    settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    settingButton.frame = CGRectMake(0, 0, 27, 27);
    //    settingButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    //    [settingButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *setting = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    //    self.navigationItem.rightBarButtonItem = setting;
}

/**
 *  配置列表
 */
-(void)configTableView
{
    self.automaticallyAdjustsScrollViewInsets = false;
    self.tableView.separatorColor = [UIColor colorFromHexRGB:@"eaeaea"];
    CGFloat leftInset = 29 + 30;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, leftInset, 0,0)];
    }
    self.tableView.contentInset = UIEdgeInsetsMake(TopHeaderHeight, 0, 0, 0);
    
    [self setPersonalSettingMethod];
}
//个人设置table配置
-(void)setPersonalSettingMethod{
   
    if (LoginState) {
        countSettings = @[@[@"修改密码"],@[[UIImage imageNamed:@"modify_pwd"]]];
    }else{
        countSettings = @[];
    }
    functionSettings = @[@[@"好友推荐",@"清除缓存"],@[[UIImage imageNamed:@"recommand"],[UIImage imageNamed:@"clear"]]];
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/welcome.bundle/"];
    NSArray *imageNames = CRFilesForType(path, @"png");
    if (imageNames.count>0) {
        hasUserHelper = true;
    }
    about = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableArray *aboutTitles = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableArray *aboutIcons = [[NSMutableArray alloc] initWithCapacity:2];
    
    [about addObject:aboutTitles];
    [about addObject:aboutIcons];
    if (hasUserHelper) {
        [aboutTitles addObject:@"新手帮助"];
        [aboutIcons addObject:[UIImage imageNamed:@"help"]];
    }
    [aboutTitles addObject:@"关于我们"];
    [aboutIcons addObject:[UIImage imageNamed:@"info"]];
    
    
}
/**
 *  初始化背景图
 */
-(void)configHeaderView{
    
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, - TopHeaderHeight, self.view.width, TopHeaderHeight+10)];
    _headerImageView.clipsToBounds = true;
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.tableView addSubview:_headerImageView];
    _userImageView = [[UserHeaderView alloc] initWithFrame:CGRectMake(0, 0, UserHeadSize,UserHeadSize)];
    _userImageView.center = CGPointMake(self.view.width/2.0f, - TopHeaderHeight/2.0f - 20);
    [_userImageView addTarget:self action:@selector(headClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:_userImageView];
    [_userImageView setNeedsDisplay];
    _nickView = [[UILabel alloc] initWithFrame:CGRectMake(10, _userImageView.y + _userImageView.height + 10, self.view.width - 20, App3xfont(15)+2)];
    _nickView.textAlignment = NSTextAlignmentCenter;
    _nickView.font = MSGYHFont(15);
    _nickView.textColor = CRCOLOR_WHITE;
    [_nickView setShadowColor:CRCOLOR_BLACK];
    _nickView.shadowOffset = CGSizeMake(1, 1);
    [self.tableView addSubview:_nickView];
    
    _modView = [[UILabel alloc] initWithFrame:CGRectMake(10, _nickView.y + _nickView.height + 5, self.view.width - 20, App3xfont(12)+2)];
    _modView.font = MSGYHFont(12);
    _modView.textAlignment = NSTextAlignmentCenter;
    _modView.textColor = CRCOLOR_WHITE;
    [_modView setShadowColor:CRCOLOR_BLACK];
    _modView.shadowOffset = CGSizeMake(1, 1);
    [self.tableView addSubview:_modView];
    
}
/**
 *  渲染视图
 */
-(void)renderHeaderViews{
    
    UIImage *cachHead = nil;
    if (!LoginState) {
        cachHead = UserPlaceImage;
    }else{
        cachHead = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:kCurUser.head100];
        NSLog(@"kCurUser.head100==%@",kCurUser.head100);
    }
    if (!cachHead) {
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:CRURL(kCurUser.head100) options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            UIImage *newImage = [image applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.000 alpha:0.100] saturationDeltaFactor:1.0 maskImage:nil];
            _headerImageView.image = newImage;
            [_userImageView setImage:image forState:UIControlStateNormal];
            [[SDImageCache sharedImageCache] storeImage:image forKey:kCurUser.head100];
        }];
    }else{
        UIImage *newImage = [cachHead applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:0.000 alpha:0.100] saturationDeltaFactor:1.0 maskImage:nil];
        _headerImageView.image = newImage;
        [_userImageView setImage:cachHead forState:UIControlStateNormal];
    }
    if (LoginState) {
        _nickView.text = kCurUser.firstName;
        _modView.text = kCurUser.mood;
    }else{
        _nickView.text = @"";
        _modView.text = @"";
    }
    
}
/**
 *  配置功能栏菜单
 */
-(void)configmenuBar
{
    
    UIImage *backImage = [UIImage imageNamed:@"bg_nav_transparent"];
    UIImage *effect = [backImage applyBlurWithRadius:10 tintColor:[UIColor colorWithWhite:0.000 alpha:0.100] saturationDeltaFactor:1.8 maskImage:nil];
    UIImage *msg = [UIImage imageNamed:@"ic_article"];
    UIImage *message = [UIImage imageNamed:@"ic_message"];
    UIImage *refresh = [UIImage imageNamed:@"ic_refresh"];
    UIImage *qrcode = [UIImage imageNamed:@"ic_qr"];
    UIImage *contact = [UIImage imageNamed:@"ic_batch"];
    
    _menuBar = [[RDVTabBar alloc] initWithFrame:CGRectMake(0, - 50,self.view.width , 60)];
    _menuBar.backgroundView = [[UIImageView alloc] initWithImage:effect];
    _menuBar.backgroundColor = CRCOLOR_CLEAR;
    
    RDVTabBarItem *msgItem = [[RDVTabBarItem alloc] init];
    msgItem.titlePositionAdjustment = UIOffsetMake(0, 3);
    [msgItem setFinishedSelectedImage:[msg imageWithTintColor:[UIColor grayColor]] withFinishedUnselectedImage:[msg imageWithTintColor:[UIColor whiteColor]]];
    [msgItem setTitle:@"我的收藏"];
    msgItem.selectedTitleAttributes = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor grayColor]};
    msgItem.unselectedTitleAttributes = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    messageItem = [[RDVTabBarItem alloc] init];
    messageItem.badgePositionAdjustment = UIOffsetMake(0, 6);
    messageItem.titlePositionAdjustment = UIOffsetMake(0, 3);
    [messageItem setFinishedSelectedImage:[message imageWithTintColor:[UIColor grayColor]] withFinishedUnselectedImage:[message imageWithTintColor:[UIColor whiteColor]]];
    [messageItem setTitle:@"消息中心"];
    messageItem.selectedTitleAttributes = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor grayColor]};
    messageItem.unselectedTitleAttributes = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    RDVTabBarItem *contactItem = [[RDVTabBarItem alloc] init];
    contactItem.titlePositionAdjustment = UIOffsetMake(0, 3);
    [contactItem setFinishedSelectedImage:[msg imageWithTintColor:[UIColor grayColor]] withFinishedUnselectedImage:[contact imageWithTintColor:[UIColor whiteColor]]];
    [contactItem setTitle:@"通讯录"];
    contactItem.selectedTitleAttributes = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor grayColor]};
    contactItem.unselectedTitleAttributes = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor whiteColor]};
    

    RDVTabBarItem *refreshItem = [[RDVTabBarItem alloc] init];
    refreshItem.titlePositionAdjustment = UIOffsetMake(0, 3);
    
    [refreshItem setFinishedSelectedImage:[refresh imageWithTintColor:[UIColor grayColor]] withFinishedUnselectedImage:[refresh imageWithTintColor:[UIColor whiteColor]]];
    [refreshItem setTitle:@"刷新"];
    
    refreshItem.selectedTitleAttributes = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor grayColor]};
    refreshItem.unselectedTitleAttributes = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    RDVTabBarItem *qrItem = [[RDVTabBarItem alloc] init];
    qrItem.titlePositionAdjustment = UIOffsetMake(0, 3);
    
    [qrItem setFinishedSelectedImage:[qrcode imageWithTintColor:[UIColor grayColor]] withFinishedUnselectedImage:[qrcode imageWithTintColor:[UIColor whiteColor]]];
    [qrItem setTitle:@"扫一扫"];
    qrItem.selectedTitleAttributes = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor grayColor]};
    qrItem.unselectedTitleAttributes = @{NSFontAttributeName:MSGFont(9),NSForegroundColorAttributeName:[UIColor whiteColor]};
      _menuBar.items = @[msgItem,messageItem,contactItem,refreshItem,qrItem];
    _menuBar.delegate = self;
    [self.tableView addSubview:_menuBar];
    
    messageItem.badgeBackgroundColor = CRCOLOR_RED;
    messageItem.badgeTextFont = MSGFont(10);
    
}

/**
 *  初始化数据
 */
-(void)intilizedDataSource
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessages:) name:kMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatMessages:) name:kChatMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renderHeaderViews) name:KheadImageComed object:nil];
    
    //optype 为2的webapp
    _backgroundColors = @[@"8b85bf", @"7cacd7", @"70c6ca", @"92c871", @"ddce72", @"e7a572", @"d96f6f"];
    _allMenus = [NSMutableArray new];
    _apps = (NSMutableArray*)CRWebAppOptype(2);
    
    if (!kCurApp.showShop||!CRWebAppTitle(@"shopstore")) {
        WebAppEntity *shopmanagerapp = CRWebAppTitle(@"myshopstore");
        [_apps removeObject:shopmanagerapp];
    }
    if (_apps.count > 0) {
        [_allMenus addObject:_apps];
    }
    //本地实现的webapp
    WebAppEntity *chat = CRWebAppTitle(BaseAppNameChatRoom);
    WebAppEntity *Groupchat = CRWebAppTitle(BaseAppNameGroupChat);
    WebAppEntity *service = CRWebAppTitle(BaseAppNameService);
    WebAppEntity *sign = CRWebAppTitle(BaseAppNameSignin);   //签到
    _baseApps = [NSMutableArray new];
    if (chat||Groupchat) {
        if (chat&&Groupchat) {
            WebAppEntity *app = [[WebAppEntity alloc] init];
            app.title_client = chat.title_client;
            app.aid = chat.aid;
            app.systitle = BaseAppNameChatRoom;
            app.icon = chat.icon;
            [_baseApps addObject:app];
        }else{
            [_baseApps addObject:chat?chat:Groupchat];
        }
    }
    if (service) {
        [_baseApps addObject:service];
    }
    if (sign) {
        [_baseApps addObject:sign];
    }
    
    //其他的功能
    _others = [NSMutableArray new];
    NSArray *contact = @[@"通讯录",[UIImage imageNamed:@"ic_contact"]];
    [_others addObject:contact];
    
    [_allMenus addObject:_baseApps];
    [_allMenus addObject:_others];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (self != CRRootNavigation().visibleViewController) {
        return;
    }
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < -(TopHeaderHeight)) {
        CGRect f = _headerImageView.frame;
        f.origin.y = yOffset;
        f.size.height =  -yOffset + 10;
        _headerImageView.frame = f;
    }
    if (yOffset >= 0) {
        [Utility setController:_backVc backTitle:nil image:BlackBackImage color:CRCOLOR_BLACK];
        settingImage = [[UIImage imageNamed:@"ic_setting"] imageWithTintColor:CRCOLOR_BLACK];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        [Utility setDefaultNavigation:CRRootNavigation()];

    }else{
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [Utility setController:_backVc backTitle:nil image:WhiteBackImage color:CRCOLOR_WHITE];
        settingImage = [[UIImage imageNamed:@"ic_setting"] imageWithTintColor:CRCOLOR_WHITE];
        [Utility setTransparentNavigation:CRRootNavigation() navBarTransparent:TransParentNavBg];
    }
    [settingButton setImage:settingImage forState:UIControlStateNormal];

}
#pragma mark - tabBarDelegate

-(BOOL)tabBar:(RDVTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index
{
    return true;
}

- (void)tabBar:(RDVTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index{
    // called when a new view is selected by the user (but not programatically)
    RDVTabBarItem *item = tabBar.items[index];
    [item setSelected:false];
    
    /**
     *  index
     *  0:收藏
     *  1:消息中心
     *  2:全局刷新
     *  3:扫描二维码
     */
    
    switch (index) {
        case 0:{
            [self showArticle];
        }
            break;
        case 1:{
            [self showMessages];
        }
            break;
        case 2:{
            [self showContactCon];
        }
            break;
        case 3:{
            [self refreshAll];
        }
            break;
        case 4:{
            [self showQR];
        }
            break;
        default:
            break;
    }
    
}
/**
 *  收藏
 */
-(void)showArticle{
    
    if (!LoginState) {
        [LoginHandler showLoginControllerFromController:self complete:nil];
        return;
    }
    MsgController*msg = [Utility controllerInStoryboard:@"Main" withIdentifier:@"MsgController"];
    [self.navigationController pushViewController:msg animated:true];
    
}
/**
 *  消息中心
 */
-(void)showMessages{
    
    MCenterController *center = [Utility controllerInStoryboard:@"Main" withIdentifier:@"MCenterController"];
    [self.navigationController pushViewController:center animated:true];
    
}
/**
 *  全局刷新
 */
-(void)refreshAll{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    [AppWindow addSubview:hud];
    hud.removeFromSuperViewOnHide = true;
    CRWeekRef(self);
    CRWeekRef(hud);
    [hud show:true];
    [AppDataManager refreshData:^(BOOL result) {
        [__hud hide:true];
        if (result) {
            [__self refreshRootUI];
        }else{
            [CustomToast showMessageOnWindow:@"刷新失败"];
        }
    }];
    
}

-(void)refreshRootUI
{
    GSliderViewController *slider = (GSliderViewController*)CRRootNavigation().viewControllers[0];
    UINavigationController *rootNav = (UINavigationController*)slider.centerViewController;
    CenterController *_rootCenter = (CenterController*)rootNav.viewControllers[0];
    [_rootCenter tabBar:_rootCenter.tabBar didSelectItemAtIndex:0];
    /**
     *  判断左栏是否显示
     *
     *  @param kCurSidBarKind 客户端功能栏状态
     *
     *  @return
     */
    if (kCurSidBarKind == SidBarKindLeft) {
        [slider enablePanGestrue];
        [slider enableTapGestrue];
    }else{
        /**
         *  无左栏禁用手势
         */
        [slider disablePanGestrue];
        [slider disableTapGestrue];
    }
    
    NSArray *viewControllers = [AppDataManager intilizedViewControllers];
    NSArray *tabItems = [AppDataManager intilizedTabBarItems:_rootCenter];
    [_rootCenter setViewControllers:viewControllers tabBarItems:tabItems];
    __block MSGTabBarItem *homeItem = nil;
    [tabItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MSGTabBarItem *item = obj;
        [item setSelected:false];
        if (item.isHome) {
            homeItem = item;
            *stop = true;
        }
    }];
    if (homeItem) {
        [homeItem setSelected:true];
        if (homeItem.action) {
            homeItem.action(kCurApp.home);
        }
    }
    
    if (kCurSidBarKind == SidBarKindLeft||kCurSidBarKind == SidBarKindNone) {
        [_rootCenter setTabBarHidden:true];
    }else{
        [_rootCenter setTabBarHidden:false];
    }
    [self.navigationController popViewControllerAnimated:true];
    [_rootCenter filterCheck];
}


/**
 *  二维码
 */
-(void)showQR{
    
    QRCodeController *qrCode = [[QRCodeController alloc] init];
    [self.navigationController pushViewController:qrCode animated:true];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    // return _allMenus.count;
    if (LoginState) {
        return 3;
   
    }else{
    
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //    NSArray *_subMenus = _allMenus[section];
    //    return _subMenus;
    if (LoginState) {
        switch (section) {
            case 0:
                return countSettings.count-1;
                break;
            case 1:
                return functionSettings.count;
                break;
            case 2:
            {
                NSArray *titles = about[0];
                return titles.count;
            }
                break;
                
            default:return 0;
                break;
        }
 
    }else{
    
        switch (section) {
            case 0:
                return functionSettings.count;
                break;
            case 1:{
                NSArray *titles = about[0];
                return titles.count;
                   }
                break;
            default:return 0;
                break;
        }

    }
    return 0;
    
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return Cell Height
//    return 48;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    RightCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseridenfire];
    //    if (!cell) {
    //        cell = [Utility nibWithName:@"RightCell" index:0];
    //    }
    //    NSInteger index = 0;
    //    NSString *backgroundColor = _backgroundColors[0];
    //    switch (indexPath.section) {
    //        case 0:
    //        {
    //            index = indexPath.row%7;
    //            if (_apps.count>0) {
    //                WebAppEntity *app = _apps[indexPath.row];
    //                [cell.iconView sd_setImageWithURL:CRURL(app.icon.selected_icon) placeholderImage:nil];
    //                cell.titleView.text = app.title_client;
    //                break;
    //            }else if(_baseApps.count>0){
    //                WebAppEntity *app = _baseApps[indexPath.row];
    //                [cell.iconView sd_setImageWithURL:CRURL(app.icon.selected_icon) placeholderImage:nil];
    //                cell.titleView.text = app.title_client;
    //                if ([app.systitle isEqualToString:@"chatroom"]&&chatMessageUnreadCount>0) {
    //                    cell.badgeView.text = CRString(@"%d",chatMessageUnreadCount);
    //                    cell.badgeView.hidden = false;
    //                }else if ([app.systitle isEqualToString:@"customerservice"]&&serverChatMessageUnreadCount>0) {
    //                    cell.badgeView.text = CRString(@"%d",serverChatMessageUnreadCount);
    //                    cell.badgeView.hidden = false;
    //                }else{
    //                    cell.badgeView.hidden = true;
    //                }
    //
    //                break;
    //            }else{
    //                NSArray *_item = _others[indexPath.row];
    //                cell.iconView.image = _item[1];
    //                cell.titleView.text = _item[0];
    //                break;
    //            }
    //
    //        }
    //            break;
    //        case 1:
    //        {
    //            index = (indexPath.row + _apps.count)%7;
    //            if(_baseApps.count>0){
    //                WebAppEntity *app = _baseApps[indexPath.row];
    //                [cell.iconView sd_setImageWithURL:CRURL(app.icon.selected_icon) placeholderImage:nil];
    //                cell.titleView.text = app.title_client;
    //                if ([app.systitle isEqualToString:@"chatroom"]&&chatMessageUnreadCount>0) {
    //                    cell.badgeView.text = CRString(@"%d",chatMessageUnreadCount);
    //                    cell.badgeView.hidden = false;
    //                }else if ([app.systitle isEqualToString:@"customerservice"]&&serverChatMessageUnreadCount>0) {
    //                    cell.badgeView.text = CRString(@"%d",serverChatMessageUnreadCount);
    //                    cell.badgeView.hidden = false;
    //                }else{
    //                    cell.badgeView.hidden = true;
    //                }
    //
    //                break;
    //            }else{
    //                NSArray *_item = _others[indexPath.row];
    //                cell.iconView.image = _item[1];
    //                cell.titleView.text = _item[0];
    //                break;
    //            }
    //            break;
    //        }
    //            break;
    //        case 2:
    //        {
    //            index = (indexPath.row + _apps.count + _baseApps.count)%7;
    //            NSArray *_item = _others[indexPath.row];
    //            cell.iconView.image = _item[1];
    //            cell.titleView.text = _item[0];
    //        }
    //            break;
    //
    //        default:
    //            break;
    //    }
    //    backgroundColor = _backgroundColors[index];
    //    cell.iconView.backgroundColor = [UIColor colorFromHexRGB:backgroundColor];
    //    // Configure the cell...
    //    return cell;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifire];
    }
    NSArray *sectionItem = nil;
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (LoginState) {
        switch (indexPath.section) {
            case 0:
                sectionItem = countSettings;
                //            if(indexPath.row == 0)
                //                if (LoginState) {
                //                    if (!_userNameLabel) {
                //
                //                        _userNameLabel = [[UILabel alloc]init];
                //
                //                    }
                //                    _userNameLabel.frame = CGRectMake(cell.contentView.bounds.size.width-120, 0, 120, cell.bounds.size.height);
                //                    _userNameLabel.textAlignment = NSTextAlignmentCenter;
                //
                //                    _userNameLabel.textColor = [UIColor lightGrayColor];
                //                    _userNameLabel.font = [UIFont systemFontOfSize:13];
                //                    [cell.contentView addSubview:_userNameLabel];
                //
                //                    _userNameLabel.text = kCurUser.userName;
                //                    //                    cell.detailTextLabel.text = kCurUser.userName;
                //                }else{
                //                    if (!_userNameLabel) {
                //
                //                        _userNameLabel = [[UILabel alloc]init];
                //
                //                    }
                //                    _userNameLabel.frame = CGRectMake(cell.contentView.bounds.size.width-120, 0, 120, cell.bounds.size.height);
                //                    _userNameLabel.textAlignment = NSTextAlignmentCenter;
                //
                //                    _userNameLabel.textColor = [UIColor lightGrayColor];
                //                    _userNameLabel.font = [UIFont systemFontOfSize:13];
                //                    [cell.contentView addSubview:_userNameLabel];
                //                    _userNameLabel.text = @"未登录";
                //                    //cell.detailTextLabel.text = @"未登录";
                //                }
                //                else
                //                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_arrow_right"]];
                break;
            case 1:
                sectionItem = functionSettings;
                break;
            case 2:
                sectionItem = about;
                break;
                
            default:
                break;
        }
    }else{
    
        switch (indexPath.section) {
            case 0:
                sectionItem = functionSettings;
                break;
            case 1:
                sectionItem = about;
                break;
            default:
                break;
        }
    
    }
   
    NSArray *icons = CRArrayObject(sectionItem, 1);
    NSArray *titles = CRArrayObject(sectionItem, 0);
    cell.textLabel.font = MSGFont(13);
    cell.detailTextLabel.font = MSGFont(13);
    cell.textLabel.textColor = [UIColor colorFromHexRGB:@"4d4d4d"];
    cell.textLabel.text = CRArrayObject(titles, indexPath.row);
    cell.imageView.image = CRArrayObject(icons, indexPath.row);
    // Configure the cell...
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    [tableView deselectRowAtIndexPath:indexPath animated:true];
    //    switch (indexPath.section) {
    //        case 0:
    //        {
    //            if (_apps.count>0) {
    //                WebAppEntity *app = _apps[indexPath.row];
    //                [MSGTansitionManager openWebApp:app withParams:nil goBack:nil callBack:nil];
    //                break;
    //            }else if(_baseApps.count>0){
    //                WebAppEntity *app = _baseApps[indexPath.row];
    //                [MSGTansitionManager openWebApp:app withParams:nil goBack:nil callBack:nil];
    //                break;
    //            }else{
    //                NSArray *_item = _others[indexPath.row];
    //                if([_item[0] isEqualToString:@"通讯录"]){
    //                    [self showContactCon];
    //                }
    //                break;
    //            }
    //
    //        }
    //            break;
    //        case 1:
    //        {
    //            if(_baseApps.count>0){
    //                WebAppEntity *app = _baseApps[indexPath.row];
    //                [MSGTansitionManager openWebApp:app withParams:nil goBack:nil callBack:nil];
    //                break;
    //            }else{
    //                NSArray *_item = _others[indexPath.row];
    //                if([_item[0] isEqualToString:@"通讯录"]){
    //                    [self showContactCon];
    //                }
    //                break;
    //            }
    //            break;
    //        }
    //            break;
    //        case 2:
    //        {
    //            NSArray *_item = _others[indexPath.row];
    //            if([_item[0] isEqualToString:@"通讯录"]){
    //                [self showContactCon];
    //            }
    //        }
    //            break;
    //
    //        default:
    //            break;
    //    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSArray *sectionItem = nil;
    if (LoginState) {
        switch (indexPath.section) {
            case 0:
                sectionItem = countSettings;
                break;
            case 1:
                sectionItem = functionSettings;
                break;
            case 2:
                sectionItem = about;
                break;
                
            default:
                break;
        }
 
    }else{
    
        switch (indexPath.section) {
            case 0:
                sectionItem = functionSettings;
                break;
            case 1:
                sectionItem = about;
                break;
            default:
                break;
        }

    }
    NSArray *titles = CRArrayObject(sectionItem, 0);
    NSString *title = CRArrayObject(titles, indexPath.row);
    
    if ([title isEqualToString:@"修改密码"]) {
        //修改密码
        [self modifyPwd:nil];
        
    }else if([title isEqualToString:@"好友推荐"]){
        //好友推荐
        [self recommandFriends:nil];
        
    }else if([title isEqualToString:@"清除缓存"]){
        //清除缓存
        [self clearCache:nil];
        
    }else if([title isEqualToString:@"新手帮助"]){
        //新手帮助
        [self userHelper:nil];
        
    }else if([title isEqualToString:@"关于我们"]){
        //关于我们
        [self aboutUs:nil];
    }
    
}
#pragma mark -actions

/**
 *  显示设置
 */

-(void)showSetting:(id)sender{
    UITableViewController *setting = [Utility controllerInStoryboard:@"Main" withIdentifier:@"SettingController"];
    [CRRootNavigation() pushViewController:setting animated:true];
}

/**
 *  显示收到分享
 */

-(void)showShareCon{
    
}
/**
 *  显示通讯录
 */
-(void)showContactCon{
    
    if (!LoginState) {
        //已登录显示个人中心
        CRWeekRef(self);
        [LoginHandler showLoginControllerFromController:self complete:^(BOOL loginState) {
            if (LoginState) {
                [__self showContactCon];
            }
        }];
        return;
    }
    
    ContactController *contact = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ContactController"];
    [self.navigationController pushViewController:contact animated:true];
}

/**
 *  点击头像
 *
 *  @param sender sender
 */
-(void)headClicked:(id)sender{
    if (LoginState) {
        //已登录显示个人中心
        UserInfoController *user = [Utility controllerInStoryboard:@"Main" withIdentifier:@"UserInfoController"];
        [self.navigationController pushViewController:user animated:true];
        return;
    }
    //未登录弹出登录提示
    LoginController *loginVC = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LoginController"];
    loginVC.loginCallBack = nil;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [CRRootNavigation() presentViewController:nav animated:true completion:nil];
}
-(void)updateMessages:(id)sender{
    
    NSInteger unreadMesCount = [[[MCenterManager sharedManager] unReadMessages] count];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:chatMessageUnreadCount + unreadMesCount];
    if (unreadMesCount>0) {
        if (unreadMesCount>=100) {
            messageItem.badgeValue = @"99+";
        }else{
            messageItem.badgeValue = CRString(@"%d",unreadMesCount);
        }
    }else{
        messageItem.badgeValue = nil;
    }
}
-(void)updateChatMessages:(id)sender{
    
    NSInteger unreadMesCount = [[[MCenterManager sharedManager] unReadMessages] count];
    NSInteger unreadGroupChatMesCount = [[ContentManager sharedManager] getUserUnreadCountType:@"groupchat"];
    NSInteger unreadChatMesCount = [[ContentManager sharedManager] getUserUnreadCountType:@"chat"];
    chatMessageUnreadCount = unreadGroupChatMesCount + unreadChatMesCount;
    serverChatMessageUnreadCount = [[ContentManager sharedManager] getServerUnreadCount];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:chatMessageUnreadCount + unreadMesCount];
    [self.tableView reloadData];
}
# pragma mark - 修改密码

-(void)modifyPwd:(id)sender{
    //do something
    if (!LoginState) {
        [CustomToast showMessageOnWindow:@"尚未登录"];
        return;
    }
    ChangePwdController *pwd = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ChangePwdController"];
    [CRRootNavigation() pushViewController:pwd animated:true];
    
}
# pragma mark - 好友推荐

-(void)recommandFriends:(id)sender{
    //do something
    BaseTabItemEntity *base = [[BaseTabItemEntity alloc] initWithType:@"recommend" title:nil icon:nil];
    [base doAction];
}
# pragma mark - 清理缓存

-(void)clearCache:(id)sender{
    //do something
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    CGFloat fileSize =  [self folderSizeAtPath:path];
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    NSArray *contents = [fm contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        [fm removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL];
    }
    [fm removeItemAtPath:path error:nil];
    [CustomToast showMessageOnWindow:[NSString stringWithFormat:@"成功清理%.02fM缓存",fileSize]];
    fileSize = 0;
}
/**
 *  缓存大小
 *
 *  @param folderPath 缓存路径
 *
 *  @return 缓存大小（M）
 */
- (float )folderSizeAtPath:(NSString*) folderPath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}
/**
 *  缓存大小
 *
 *  @param folderPath 缓存路径
 *
 *  @return 缓存大小（M）
 */
- (long long) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
    
}
# pragma mark - 用户帮助

-(void)userHelper:(id)sender{
    //do something
    UserHelperController *helper = [[UserHelperController alloc] init];
    helper.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [CRRootNavigation() presentViewController:helper animated:true completion:nil];
    
}
# pragma mark - 关于我们

-(void)aboutUs:(id)sender{
    //do something
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CRString(@"关于%@",CRAppDisplayName) message:CRAppVersionShort delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageNotification object:nil];
    
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
