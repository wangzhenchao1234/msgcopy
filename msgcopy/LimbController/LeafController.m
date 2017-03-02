//
//  LeafController.m
//  msgcopy
//
//  Created by wngzc on 15/7/23.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "LeafController.h"
#import "CollectionLeafTopView.h"
#import "TableViewLeafTopView.h"
#import "LeafTopView.h"

@implementation LeafController


+(void)leafController:(id<LeafControllerDelegate>)controller listViewLoadData:(UITableView *)tableView
{
    LeafEntity *leaf = controller.leaf;
    NSInteger leafFilterID = [CRUserObj(CRString(@"leaf%d_filter",leaf.lid)) integerValue]; //永久保存数据
    NSDate *curDate = [NSDate date]; //当前时间
    NSDate *lastDate = CRUserObj(CRString(@"leaf%d_date",leaf.lid));
    NSTimeInterval time = [curDate timeIntervalSinceDate:lastDate]; //返回当前对象时间与参数传递的对象时间的相隔秒数，
    if (!lastDate||time>300||leafFilterID!=[FilterManager curFilterId]) {
        [tableView.header performSelector:@selector(beginRefreshing) withObject:nil afterDelay:1.0];
        CRLog(@"网络请求");
    }else{
        CRLog(@"加载缓存");
        if ([controller.publications count]>0) {
            return;
        }
        NSArray *topsJson = [LocalManager objectForKey:CRString(@"top_leaf%d_json",leaf.lid)];
        NSMutableArray*_leafTops = controller.leafTops;
        if (!_leafTops) {
            _leafTops = [NSMutableArray new];
        }
        NSMutableArray *newLeafTops = [NSMutableArray new];
        [topsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LeafTop *top = [LeafTop buildInstanceByJson:obj];
            [newLeafTops addObject:top];
        }];
        controller.leaf.leafTops = newLeafTops;
        if (newLeafTops.count > 0) {
            
            if ([tableView isKindOfClass:[UITableView class]]) {
                
                TableViewLeafTopView *headerView = (TableViewLeafTopView*)tableView.tableHeaderView;
                [headerView stopAnimation];
                headerView = nil;
                TableViewLeafTopView *newHeader = [[TableViewLeafTopView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, tableView.width *9/16) leaf:controller.leaf];
                tableView.tableHeaderView = newHeader;
                [newHeader startAnimation];
            }
        }
        NSArray *publications = [LocalManager objectForKey:CRString(@"data_leaf%d_json",leaf.lid)];
        NSMutableArray *pubs = [NSMutableArray new];
        NSArray *pubsJson = publications;
        [pubsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PubEntity *pub = [PubEntity buildInstanceByJson:obj];
            [pubs addObject:pub];
        }];
        controller.publications = pubs;
        [tableView reloadData];
    }
}


+(void)leafController:(id<LeafControllerDelegate>)controller listViewRefresh:(UITableView *)tableView
{
    CRWeekRef(controller);
    CRWeekRef(tableView);
    [MSGRequestManager Get:kAPILeafTop(controller.leaf.lid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if (CRJSONIsArray(data)) {
            [LocalManager storeObject:data forKey:CRString(@"top_leaf%d_json",__controller.leaf.lid)];
        }
        NSMutableArray*_leafTops = controller.leafTops;
        if (!_leafTops) {
            _leafTops = [NSMutableArray new];
        }
        NSArray *topsJson = data;
        NSMutableArray *newLeafTops = [NSMutableArray new];
        [topsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LeafTop *top = [LeafTop buildInstanceByJson:obj];
            [newLeafTops addObject:top];
        }];
        __controller.leaf.leafTops = newLeafTops;
        if (newLeafTops.count > 0) {
            
            if ([tableView isKindOfClass:[UITableView class]]) {
                LeafTopView *headerView = (LeafTopView*)tableView.tableHeaderView;
                [headerView stopAnimation];
                LeafTopView *newHeader = [[LeafTopView alloc ]initWithFrame:CGRectMake(0, 0, tableView.width, tableView.width *9/16) leaf:__controller.leaf];
                tableView.tableHeaderView = newHeader;
                [newHeader begainAnimation];
            }
        }
        
        NSInteger filterID = [FilterManager curFilterId];
        CRUserSetObj(CRString(@"%d",filterID),CRString(@"leaf%d_filter",controller.leaf.lid));
        __controller.leafTops = newLeafTops;
        [MSGRequestManager Get:kAPIPublications(controller.leaf.lid, 0, @"0",filterID) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            if (CRJSONIsArray(data)) {
                [LocalManager storeObject:data forKey:CRString(@"data_leaf%d_json",__controller.leaf.lid)];
                CRUserSetObj([NSDate date],CRString(@"leaf%d_date",__controller.leaf.lid));
            }
            NSMutableArray *pubs = [NSMutableArray new];
            NSArray *pubsJson = data;
            [pubsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PubEntity *pub = [PubEntity buildInstanceByJson:obj];
               
                    [pubs addObject:pub];
            
            }];
            if (pubs.count<20) {
                [[__tableView footer] noticeNoMoreData];
            }else{
                [[__tableView footer] resetNoMoreData];
            }
            __controller.publications = pubs;
            [[__tableView header] endRefreshing];
            [__tableView reloadData];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [CustomToast showMessageOnWindow:msg];
            [[__tableView header] endRefreshing];
            [__tableView reloadData];
        }];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
        [[__tableView header] endRefreshing];
    }];

}
+(void)leafController:(id<LeafControllerDelegate>)controller listViewloadMore:(UITableView *)tableView
{
    if (!controller.leaf) {
        [tableView.footer endRefreshing];
        return;
    }
    NSArray *publications = controller.publications;
    if (publications.count == 0) {
        [[tableView footer] endRefreshing];
        return;
    }
    
    PubEntity *last = publications.lastObject;
    NSDate *date = last.idx;
    NSString *time = @"0";
    if (date) {
        time = [[NSString getDateStringFromeDate:date] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    CRWeekRef(controller);
    CRWeekRef(tableView);
    NSInteger filterID = [FilterManager curFilterId];
    [MSGRequestManager Get:kAPIPublications(controller.leaf.lid,2,time,filterID) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSMutableArray *pubs = [NSMutableArray new];
        NSArray *pubsJson = data;
        [pubsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PubEntity *pub = [PubEntity buildInstanceByJson:obj];
            
            
            
            [pubs addObject:pub];
        }];
        if (pubs.count<20) {
            [[__tableView footer] noticeNoMoreData];
        }
        [__controller.publications addObjectsFromArray:pubs];
        [[__tableView footer] endRefreshing];
        [__tableView reloadData];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
        [[__tableView footer] endRefreshing];
    }];

}
+(void)leafController:(id<LeafControllerDelegate>)controller listView:(UITableView*)listView sortWithRegulation:(SortRegulation)regulation
{
    if (regulation == SORT_GPS) {
        CRWeekRef(controller);
        CRWeekRef(listView);
        if (!controller.sortPublications) {
            controller.sortPublications = [NSMutableArray new];
        }
        NSInteger filterID = [FilterManager curFilterId];
        [MSGRequestManager Get:kAPISortPub(controller.leaf.lid, filterID) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            NSMutableArray *sortArray = [NSMutableArray new];
            if (CRJSONIsArray(data)) {
                [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    PubEntity *pub = [PubEntity buildInstanceByJson:obj];
                    [sortArray addObject:pub];
                }];
                NSArray *result = [sortArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [LeafController comparePubLocation:obj1 with:obj2];
                }];
                [__controller.sortPublications removeAllObjects];
                [__controller.sortPublications addObjectsFromArray:result];
                [__listView reloadData];
            }else{

                [CustomToast showMessageOnWindow:NetWorkAlert];
            }
            [[__listView header] endRefreshing];
            [[__listView footer] noticeNoMoreData];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [[__listView header] endRefreshing];
            [CustomToast showMessageOnWindow:msg];
        }];
    }
}
+ (NSComparisonResult)comparePubLocation:(PubEntity*)pub1 with:(PubEntity*)pub2{
    
    if (!pub1.article.location) {
        return NSOrderedDescending;
    }
    if (!pub2.article.location) {
        return NSOrderedAscending;
    }
    CLLocation *location1 = pub1.article.location;
    CLLocation *myLocation = [LocationManager sharedManager].baiduLocation;
    CLLocationDistance dis1 = [myLocation distanceFromLocation:location1];
    CLLocation *location2 = pub2.article.location;
    CLLocationDistance dis2 = [myLocation distanceFromLocation:location2];
    NSComparisonResult result = NSOrderedSame;
    CRLog(@"%f::%f",dis1,dis2);
    if (dis2 > dis1) {
        result = NSOrderedAscending;
    }else if(dis2 < dis1){
        result = NSOrderedDescending;
    }else{
        result = NSOrderedSame;
    }
    return result;
    
}
@end
