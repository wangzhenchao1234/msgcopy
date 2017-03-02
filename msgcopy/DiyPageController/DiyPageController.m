//
//  DiyPageController.m
//  msgcopy
//
//  Created by wngzc on 15/4/14.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "DiyPageController.h"
#import "KKDiyGridSingleItemView.h"
#import "KKDiyModule2View.h"
#import "KKDiyGridMultyItemView.h"
#import "KKdiyBannerView.h"
#import "KKDiyListView.h"
#import "BaseTabItemEntity.h"

@interface DiyPageController ()
@property(nonatomic,retain)UIScrollView *customView;
@property(nonatomic,retain)DiyPageEntity *page;
@property(nonatomic,retain)UILabel * todayLabel;
@property(nonatomic,retain)UILabel * totalLabel;
@end

@implementation DiyPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self intilizedDataSource];
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_customView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KKdiyBannerView class]]) {
            KKdiyBannerView *banner = obj;
            [banner stopAnimation];
        }
    }];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_customView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[KKdiyBannerView class]]) {
            KKdiyBannerView *banner = obj;
            [banner startAnimation];
        }
    }];
    
}
-(void)intilizedDataSource{
    //intilizedDataSource
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    [AppWindow addSubview:hud];
    CRWeekRef(hud);
    CRWeekRef(self);
    hud.removeFromSuperViewOnHide = true;
    [MSGRequestManager Get:kAPIDP(_pageID) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__hud hide:true];
        _page = [DiyPageEntity buildByJson:data];
        self.title = _page.text;
        [__self loadCustomView];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
    
}

-(void)loadCustomView{
    self.automaticallyAdjustsScrollViewInsets = false;
    [_customView removeFromSuperview];
    for (UIView *view in _customView.subviews) {
        [view removeFromSuperview];
    }
    if (kCurApp.sideBar.kind != SidBarKindLeft) {
        if (_page.isShowTotal || _page.isShowToday) {
          
             _customView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAV_H, self.view.frame.size.width, CRScreenBounds(false).size.height - (NAV_H)-50)];
        }else{
        
         _customView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAV_H, self.view.frame.size.width, CRScreenBounds(false).size.height - (NAV_H))];
        
        }
        
    }else{
    
        _customView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAV_H, self.view.frame.size.width, CRScreenBounds(false).size.height - (NAV_H))];
    }
   
    _customView.alwaysBounceVertical = true;
    CRWeekRef(self);
  
   _page.controls  =  (NSMutableArray*)[_page.controls reverseObjectEnumerator];
    
   
    for (id obj in _page.controls) {
  
        if ([obj isMemberOfClass:[DiyBannerEntity class]]) {
            
            DiyBannerEntity *entity = obj;
            KKdiyBannerView *banner = [[KKdiyBannerView alloc] initWithFrame:CGRectMake([[entity.position valueForKey:@"left"] integerValue]*SQR(_page.column), [[entity.position valueForKey:@"top"] integerValue]*SQR(_page.column),[[entity.position valueForKey:@"width"] integerValue]*SQR(_page.column), [[entity.position valueForKey:@"height"] integerValue]*SQR(_page.column))];
            [banner buildByData:entity page:_page action:^(id data) {
                [__self clickAction:data];
            }];
            [_customView addSubview:banner];
            [banner startAnimation];
            [self adjustContentSize:banner];
            
        }else if([obj isMemberOfClass:[DiySingleGridEntity class]]){
            
            DiySingleGridEntity *entity = obj;

            KKDiyGridSingleItemView *gridView = [[KKDiyGridSingleItemView alloc] initWithFrame:CGRectMake([[entity.position valueForKey:@"left"] integerValue]*SQR(_page.column), [[entity.position valueForKey:@"top"] integerValue]*SQR(_page.column),[[entity.position valueForKey:@"width"] integerValue]*SQR(_page.column), [[entity.position valueForKey:@"height"] integerValue]*SQR(_page.column))];
            [gridView buildByData:entity page:_page action:^(id data) {
                [__self clickAction:data];
            }];
            [_customView addSubview:gridView];
            [self adjustContentSize:gridView];
            
        }else if([obj isMemberOfClass:[DiyMultyGridEntiy class]]){
            DiyMultyGridEntiy *entity = obj;
            KKDiyGridMultyItemView *gridView = [[KKDiyGridMultyItemView alloc] initWithFrame:CGRectMake([[entity.position valueForKey:@"left"] integerValue]*SQR(_page.column), [[entity.position valueForKey:@"top"] integerValue]*SQR(_page.column),[[entity.position valueForKey:@"width"] integerValue]*SQR(_page.column), [[entity.position valueForKey:@"height"] integerValue]*SQR(_page.column))];
            [gridView buildByData:entity page:_page action:^(id data) {
                [__self clickAction:data];
            }];
            [_customView addSubview:gridView];
            [self adjustContentSize:gridView];
            
        }else if([obj isMemberOfClass:[DiyModule2Entity class]]){
            
            DiyModule2Entity*entity = obj;
            KKDiyModule2View *listView = [[KKDiyModule2View alloc] initWithFrame:CGRectMake([[entity.grid_position valueForKey:@"left"] integerValue]*SQR(_page.column), [[entity.grid_position valueForKey:@"top"] integerValue]*SQR(_page.column),[[entity.grid_position valueForKey:@"width"] integerValue]*SQR(_page.column), [[entity.grid_position valueForKey:@"height"] integerValue]*SQR(_page.column))];
            [listView buildByData:entity page:_page action:^(id data) {
                [__self clickAction:data];
            }];
            [_customView addSubview:listView];
            [self adjustContentSize:listView];
            
        }
        /*else if([obj isMemberOfClass:[DiyLeafContentEntity class]]){
         
         DiyLeafContentEntity *entity = obj;
         KaokeLeafEntity *leaf = entity.leaf;
         NSInteger filterID = [[FilterManager sharedManager].curID integerValue];
         [KKRequestManager Get:kAPILeafPubs(leaf.lid, 0, @"0",filterID) params:nil complete:^(NSString *msg, id data, NSString *requestURL) {
         if (!msg) {
         NSArray *publications = data;
         for (NSDictionary *pub in publications) {
         KaokePublicationEntity *entity = [KaokePublicationEntity buildInstanceByJson:pub forCache:false];
         [leaf.publications addObject:entity];
         }
         UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
         KKDiyListView *listView = [KKDiyListView buildByLeaf:leaf frame:CGRectMake(WIDTH(gridData.columns)*[[gridData.position valueForKey:@"left"] floatValue], WIDTH(gridData.rows)*[[gridData.position valueForKey:@"top"] floatValue],WIDTH(gridData.columns)*[[gridData.position valueForKey:@"width"] floatValue], HEIGHT(gridData.rows)*[[gridData.position valueForKey:@"height"] floatValue] ) inset:inset];
         [_customView addSubview:listView];
         }
         }];
         }*/
    }
    
       if (_page.backgroundColor.length == 7) {
        _customView.backgroundColor = [UIColor colorFromHexRGB:[_page.backgroundColor substringFromIndex:1]];
    }
    [_customView sizeToFit];
    [self.view addSubview:_customView];
    
    //首页显示今日浏览量和总浏览量
    
    //是否显示今日访问量
    if (_page.isShowToday) {
        
        int todayPV = _page.todayPV; //今日浏览量
        //today
        if (_page.isShowTotal) {
            
            
             _todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(_customView.bounds.size.width/2, _customView.contentSize.height-50, _customView.frame.size.width/2, 50)];
            
            _todayLabel.layer.borderWidth = 0.7;
            _todayLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }else{
            _todayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _customView.contentSize.height-50, _customView.frame.size.width, 50)];
        }
        
//        _todayLabel.backgroundColor = [UIColor greenColor];
        _todayLabel.text = [NSString stringWithFormat:@"今日浏览量：%d",todayPV];
        _todayLabel.textAlignment = UITextAlignmentCenter;
        _todayLabel.font = [UIFont systemFontOfSize:14];
        [_customView addSubview:_todayLabel];
        
    }
    
    if (_page.isShowTotal) {
        int totalPV = _page.totalPV; //总浏览量
        //total
      
        if (_page.isShowToday) {
            
            _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _customView.contentSize.height-50, _customView.bounds.size.width/2, 50)];            
            _totalLabel.layer.borderWidth = 0.7;
            _totalLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;

        }else{
            _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _customView.contentSize.height -50, _customView.bounds.size.width, 50)];
            
        }
        
//        _todayLabel.backgroundColor = [UIColor redColor];
        _totalLabel.text = [NSString stringWithFormat:@"总浏览量：%d",totalPV];
        _totalLabel.textAlignment = UITextAlignmentCenter;
        _totalLabel.font = [UIFont systemFontOfSize:14];
        [_customView addSubview:_totalLabel];
        
    }
    
    
    
//    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, _customView.bounds.size.height, _customView.frame.size.width, 1)];
//    line.backgroundColor = [UIColor blackColor];
//    [_customView addSubview:line];
//    
    
    
}

-(void)reloadData{
    [self loadCustomView];
}

-(void)adjustContentSize:(UIView *)view{
    CGFloat tabbarHeight = 0;
    if (_page.isHome) {
        tabbarHeight = TAB_H;
    }
    CGFloat height = MAX(view.frame.origin.y + view.frame.size.height+tabbarHeight, _customView.contentSize.height);
    _customView.contentSize = CGSizeMake(_customView.frame.size.width,height );
}
-(void)clickAction:(id)data{
    
    NSString *value = [data valueForKey:@"value"];
    if ([[data valueForKey:@"click"] isEqualToString:@"open_pub"]) {
        [MSGTansitionManager openPubWithID:[value integerValue] withParams:nil];
    }else if([[data valueForKey:@"click"] isEqualToString:@"open_web_app"]){
        NSString *appData = [data valueForKey:@"arg"];
        NSDictionary *params = nil;
        if (!appData) {
            appData = @"{}";
        }
        params = @{@"init_data":appData};
        [MSGTansitionManager openWebappWithID:[value integerValue] withParams:params goBack:nil callBack:nil];
    }else if([[data valueForKey:@"click"] isEqualToString:@"open_leaf"]){
        [MSGTansitionManager openLeafWithID:[value integerValue] withParams:nil];
    }else if([[data valueForKey:@"click"] isEqualToString:@"open_diy_page"]){
        [MSGTansitionManager openDiyPageWithID:[value integerValue] withParams:nil];
    }else if([[data valueForKey:@"click"] isEqualToString:@"open_link"]){
        [MSGTansitionManager openLink:value];
    }else if([[data valueForKey:@"click"] isEqualToString:@"open_base"]){
        BaseTabItemEntity *tab = [[BaseTabItemEntity alloc] initWithType:value title:nil icon:nil];
        [tab doAction];
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
