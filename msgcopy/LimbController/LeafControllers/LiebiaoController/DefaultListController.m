//
//  ListBusinessController.m
//  msgcopy
//
//  Created by Gavin on 15/4/15.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "DefaultListController.h"
#import "DefaultListCell.h"
#import "DefaultListNoThumbnailCell.h"
#import "LeafController.h"

@interface DefaultListController ()
{
    BOOL _shouldAnimation;
    NSInteger lastRow;
}
@end

@implementation DefaultListController
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
    if (regulation == SORT_GPS&&self.sortPublications.count == 0) {
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_regulation == SORT_GPS) {
        return _sortPublications.count;
    }
    return _publications.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PubEntity *pub = nil;
    if (_regulation == SORT_GPS) {
        pub = CRArrayObject(self.sortPublications, indexPath.row);
    }else{
        pub = CRArrayObject(_publications, indexPath.row);
    }
    if (pub&&[pub.article.thumbnail.turl length]>0) {
        return [DefaultListNoThumbnailCell getCellHeight];
    }
    return [DefaultListCell getCellHeight];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifire1 = @"DefaultListCell";
    static NSString *identifire2 = @"DefaultListNoThumbnailCell";
    PubEntity *pub = nil;
    if (_regulation == SORT_GPS) {
        pub = CRArrayObject(self.sortPublications, indexPath.row);
    }else{
        pub = CRArrayObject(_publications, indexPath.row);
    }
    if (pub) {
        if ([pub.article.thumbnail.turl length]>0) {
            DefaultListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifire1];
            if (!cell) {
                cell = [Utility nibWithName:identifire1 index:0];
            }
            [cell buildWithData:pub];
            return cell;

        }else{
            DefaultListNoThumbnailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifire2];
            if (!cell) {
                cell = [Utility nibWithName:identifire2 index:0];
            }
            [cell buildWithData:pub];
            return cell;

        }
    }else{
        DefaultListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifire1];
        if (!cell) {
            cell = [Utility nibWithName:identifire1 index:0];
        }
        return cell;
    }
        // Configure the cell...
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
