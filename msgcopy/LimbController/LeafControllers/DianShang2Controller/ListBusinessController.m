//
//  ListBusinessController.m
//  msgcopy
//
//  Created by wngzc on 15/4/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ListBusinessController.h"
#import "BusinessListCell.h"
#import "LeafController.h"

@interface ListBusinessController ()
{
    BOOL _shouldAnimation;
    NSInteger lastRow;
}
@end

@implementation ListBusinessController
@synthesize leaf = _leaf,publications = _publications, leafTops = _leafTops, regulation = _regulation, sortPublications = _sortPublications;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDataSource];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)loadDataSource
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    CRWeekRef(self);
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [__self refreshPublications];
    }];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [__self morePublications];
    }];
    
    [LeafController leafController:self listViewLoadData:(UITableView*)self.tableView];
}
# pragma mark - actions

-(void)refreshPublications
{
    if (self.regulation == SORT_GPS) {
        [LeafController leafController:self listView:(UITableView*)self.tableView sortWithRegulation:SORT_GPS];
    }else{
        [LeafController leafController:self listViewRefresh:(UITableView*)self.tableView];
    }
}
-(void)morePublications
{
    [LeafController leafController:self listViewloadMore:(UITableView*)self.tableView];
}

-(void)sort:(SortRegulation)regulation
{
    _regulation = regulation;
    if (regulation == SORT_GPS&&_sortPublications.count == 0) {
        [self.tableView.header beginRefreshing];
    }else{
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (_regulation == SORT_GPS) {
        return _sortPublications.count;
    }
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
    PubEntity *pub = nil;
    if (_regulation == SORT_GPS) {
        pub = CRArrayObject(self.sortPublications, indexPath.row);
    }else{
        pub = CRArrayObject(_publications, indexPath.row);
    }
    if (pub) {
        [cell buildWithData:pub];
    }
    
    return cell;
}
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
//    }
//    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
//    }
//    if (indexPath.row>lastRow) {
//        CGFloat y = cell.y;
//        cell.y += cell.height;
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:1];
//        cell.y = y;
//        [UIView commitAnimations];
//    }
//    lastRow = indexPath.row;
//
//}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    PubEntity *pub = nil;
    if (_regulation == SORT_GPS) {
        pub = CRArrayObject(self.sortPublications, indexPath.row);
    }else{
        pub = CRArrayObject(_publications, indexPath.row);
    }
    if (pub) {
        NSLog(@"电商- %@",pub);
        [MSGTansitionManager openPub:pub withParams:nil];
        
    }
}
-(UITableView*)listView
{
    return self.tableView;
}
-(void)insert:(PubEntity *)pub
{
    if (pub) {
        [_publications insertObject:pub atIndex:0];
        [self.tableView reloadData];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
