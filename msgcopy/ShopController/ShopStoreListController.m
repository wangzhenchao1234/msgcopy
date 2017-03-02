//
//  ShopStoreListController.m
//  Kaoke
//
//  Created by wngzc on 15/3/10.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "ShopStoreListController.h"
#import "ShopViewController.h"
#import "ShopStoreCell.h"
#import "ShopStoreEntity.h"

@interface ShopStoreListController ()<UISearchBarDelegate>
@property(nonatomic,retain)NSMutableArray *shops;
@property(nonatomic,retain)NSMutableArray *searchResult;

@end

@implementation ShopStoreListController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configTableView];
    [self loadCache];
    if (_shops.count == 0) {
//        [self performSelector:@selector(startPullDownRefreshing) withObject:nil afterDelay:1];
    }
}
-(void)configTableView
{
    WebAppEntity *app = CRWebAppTitle(@"shopstore");
    self.title = CRString(@"%@列表",app.title);
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    CRWeekRef(self);
    [self.tableView addHeaderWithCallback:^{
        [__self loadDataSource];
    }];
    [self.tableView.header performSelector:@selector(beginRefreshing) withObject:nil afterDelay:.5];
    
}
-(void)loadCache{
    
    NSArray *json = [LocalManager objectForKey:@"shoplist_json"];
    NSMutableArray *stores = [NSMutableArray new];
    [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *item = obj;
        ShopStoreEntity *entity = [ShopStoreEntity buildWithJson:item];
        [stores addObject:entity];
    }];
    _shops = nil;
    _shops = stores;
    [self.tableView reloadData];
    if (_shops.count == 0) {
        UILabel *blank = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        blank.textColor = [UIColor colorFromHexRGB:@"9a9a9a"];
        blank.textAlignment = NSTextAlignmentCenter;
        blank.backgroundColor = [UIColor clearColor];
        blank.text = @"店铺列表为空";
        self.tableView.backgroundView = blank;
    }else{
        self.tableView.backgroundView = nil;
    }

}
-(void)loadDataSource{
    
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIShops params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSMutableArray *stores = [NSMutableArray new];
        NSArray *json = data;
        [LocalManager storeObject:json forKey:@"shoplist_json"];
        [json enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *item = obj;
            ShopStoreEntity *entity = [ShopStoreEntity buildWithJson:item];
            [stores addObject:entity];
        }];
        _shops = nil;
        _shops = stores;
        [__self.tableView reloadData];
        if (_shops.count == 0) {
            UILabel *blank = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
            blank.textColor = [UIColor colorFromHexRGB:@"9a9a9a"];
            blank.textAlignment = NSTextAlignmentCenter;
            blank.backgroundColor = [UIColor clearColor];
            blank.text = @"店铺列表为空";
            __self.tableView.backgroundView = blank;
        }else{
            __self.tableView.backgroundView = nil;
        }
        [__self.tableView.header endRefreshing];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__self.tableView.header endRefreshing];
        [CustomToast showMessageOnWindow:msg];
    }];
    
    [MSGRequestManager Get:GetChannel params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSArray*array = data;
        for (NSDictionary*dic in array) {
            if ([dic[@"platform_id"] intValue]==4) {
                NSString* channel = dic[@"title"];
                [[NSUserDefaults standardUserDefaults] setObject:channel forKey:KsaveChannelID];
            }
        }
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
    }];

    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return _shops.count;
    }
    return _searchResult.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShopStoreCell *cell = (ShopStoreCell*)[self.tableView dequeueReusableCellWithIdentifier:@"Shop"];
    if (!cell) {
        cell = [Utility nibWithName:@"ShopStoreCell" index:0];
    }
    ShopStoreEntity *entity = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        entity = _searchResult[indexPath.row];
    }else{
        entity = _shops[indexPath.row];
    }
    [cell buildWithData:entity];
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    ShopStoreEntity *entity = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        entity = _searchResult[indexPath.row];
    }else{
        entity = _shops[indexPath.row];
    }
    if (self.searchDisplayController.isActive) {
        [self.searchDisplayController setActive:false animated:false];
        while (self.searchDisplayController.isActive) {
            sleep(1);
        }
    }
//    ShopViewController *shop = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ShopViewController"];
//    shop.shopData = entity;
    WebAppController *webAppCon = [Utility controllerInStoryboard:@"Main" withIdentifier:@"WebAppController"];
    webAppCon.sid = entity.sid;
    webAppCon.sharetitle = entity.title;
    webAppCon.desr = entity.descr;
    webAppCon.imgUrl = entity.thumbnail.turl;
    webAppCon.channel = [[NSUserDefaults standardUserDefaults]objectForKey:KsaveChannelID];
    webAppCon.shoplist = 1;
    //[CRRootNavigation() pushViewController:webAppCon animated:true];
    [self.navigationController pushViewController:webAppCon animated:true];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - searchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *text = searchBar.text;
    NSMutableArray *result = [NSMutableArray new];
    [_shops enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ShopStoreEntity *shop = obj;
        if ([shop.title containsString:text]||[shop.descr containsString:text]) {
            [result addObject:obj];
        }
    }];
    if (!_searchResult) {
        _searchResult = [NSMutableArray new];
    }
    [_searchResult removeAllObjects];
    [_searchResult addObjectsFromArray:result];
    [result removeAllObjects];
    [self.searchDisplayController.searchResultsTableView reloadData];
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
