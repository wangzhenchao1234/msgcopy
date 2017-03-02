//
//  GoodsController.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/3.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import "GoodsController.h"
#import "ProductController.h"
#import "BusinessListCell.h"

@interface GoodsController ()
@property(nonatomic,retain)NSMutableArray *publications;
@end

@implementation GoodsController

- (void)viewDidLoad {
    [super viewDidLoad];
    CRWeekRef(self);
    self.title = _leaf.title;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [__self refreshDataSource];
    }];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [__self loadMoreDataSource];
    }];
    [self.tableView.header beginRefreshing];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)refreshDataSource{
    
    CRWeekRef(self);
    NSInteger filterID = 0;
    [MSGRequestManager Get:kAPIPublications(_leaf.lid, 0, @"0",filterID) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
        NSMutableArray *pubs = [NSMutableArray new];
        NSArray *pubsJson = data;
        [pubsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PubEntity *pub = [PubEntity buildInstanceByJson:obj];
            if ([pub.article.ctype.systitle isEqualToString:@"dianshang"]&&[pub.article.content rangeOfString:@"form_id"].location!=NSNotFound) {
                [pubs addObject:pub];
                
                NSLog(@"%%%%%%%%%%%%%% %@",pubs);
                
            }
        }];
        if (pubsJson.count<20) {
            [[__self.tableView footer] noticeNoMoreData];
        }else{
            [[__self.tableView footer] resetNoMoreData];
        }
        _publications = pubs;
        [[__self.tableView header] endRefreshing];
        [__self.tableView reloadData];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
        [[__self.tableView header] endRefreshing];
        [__self.tableView reloadData];
    }];
    

}

-(void)loadMoreDataSource{
    
    CRWeekRef(self);
    NSInteger filterID = 0;
    PubEntity *last = _publications.lastObject;
    NSDate *date = last.idx;
    NSString *time = @"0";
    if (date) {
        time = [[NSString getDateStringFromeDate:date] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    [MSGRequestManager Get:kAPIPublications(_leaf.lid, 2, time,filterID) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSMutableArray *pubs = [NSMutableArray new];
        NSArray *pubsJson = data;
        [pubsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PubEntity *pub = [PubEntity buildInstanceByJson:obj];
            if ([pub.article.ctype.systitle isEqualToString:@"dianshang"]&&[pub.article.content rangeOfString:@"form_id"].location!=NSNotFound) {
                [pubs addObject:pub];
            }
        }];
        if (pubsJson.count<20) {
            [[__self.tableView footer] noticeNoMoreData];
        }else{
            [[__self.tableView footer] resetNoMoreData];
        }
        [_publications addObjectsFromArray:pubs];
        [[__self.tableView header] endRefreshing];
        [__self.tableView reloadData];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
        [[__self.tableView header] endRefreshing];
        [__self.tableView reloadData];
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    return _publications.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BusinessListCell getCellHeight];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifire = @"BusinessListCell";
    BusinessListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifire];
    if (!cell) {
        cell = [Utility nibWithName:identifire index:0];
    }
    // Configure the cell...
    PubEntity *pub = CRArrayObject(_publications, indexPath.row);
    if (pub) {
        [cell buildWithData:pub];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    PubEntity *pub = CRArrayObject(_publications, indexPath.row);
    if (pub) {
        [self performSegueWithIdentifier:@"ShowProduct" sender:pub];
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].

    ProductController *vc = segue.destinationViewController;
    [vc setValue:@(2) forKey:@"type"];
    [vc setValue:sender forKey:@"pub"];
    CRWeekRef(self);
    vc.completeCallBack = ^(BOOL result){
        [__self.navigationController popViewControllerAnimated:true];
        [__self refreshDataSource];
    };
    
}


@end
