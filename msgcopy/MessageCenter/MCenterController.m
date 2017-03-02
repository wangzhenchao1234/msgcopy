//
//  MCenterController.m
//  msgcopy
//
//  Created by Gavin on 15/7/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MCenterController.h"
#import "MContentController.h"
#import "MCenterCell.h"

static NSString *cellIdentifire = @"MCenterCell";

@interface MCenterController ()
{
    NSInteger curPage;
    BlankView *blankView;
}
@property(nonatomic,retain)NSDateFormatter *formmater;
@property(nonatomic,retain)NSMutableArray *groups;
@end

@implementation MCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
    [self intilizedDataSource];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
-(void)intilizedDataSource{
    //intilizedDataSource
    self.title = @"消息中心";
    _formmater = [[NSDateFormatter alloc] init];
    _formmater = [[NSDateFormatter alloc] init];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    [_formmater setDateFormat:@"yyyy年MM月dd日"];
   
}
-(void)configTableView
{
    //config some
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor colorFromHexRGB:@"f8f8f8"];
    CRWeekRef(self);
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [__self refreshMessages];
    } dateKey:@"date_message"];
    [self.tableView addLegendFooterWithRefreshingBlock:^{
        [__self loadMoreMessage];
    }];
    [self.tableView.header performSelector:@selector(beginRefreshing) withObject:nil afterDelay:.5];
    
}
# pragma mark - 刷新列表

-(void)refreshMessages
{
    curPage = 1;
    [self loadMessagesForPage:curPage];
}
# pragma mark - 加载更多

-(void)loadMoreMessage
{
    ++curPage;
    [self loadMessagesForPage:curPage];
}
# pragma mark - 加载制定页

-(void)loadMessagesForPage:(NSInteger)page
{
    
    NSArray *messages = [[MCenterManager sharedManager] messagesForPage:curPage];
    if (messages.count>0) {
        __block NSString *lastDate = @"0";
        self.groups = [[NSMutableArray alloc] init];
        __block NSMutableArray *newGroup = [NSMutableArray new];
        [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MessageEntity *curMessage = obj;
            NSString *curDate = [_formmater stringFromDate:curMessage.cTime];
            if (![curDate isEqualToString:lastDate]) {
                lastDate = curDate;
                newGroup = [[NSMutableArray alloc] init];
                [_groups addObject:newGroup];
                [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    MessageEntity *enumMessage = obj;
                    NSString *curDate = [_formmater stringFromDate:enumMessage.cTime];
                    if ([curDate isEqualToString:lastDate]) {
                        [newGroup addObject:enumMessage];
                    }
                }];
            }
        }];
    }
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    if (messages.count<20) {
        [[self.tableView footer] noticeNoMoreData];
    }else{
        [[self.tableView footer] resetNoMoreData];
    }
    if (_groups.count == 0) {
        if (!blankView) {
            blankView = [BlankView blanViewWith:[UIImage imageNamed:@"message_blank"] descr:@"您暂时还没有消息" actionTitle:nil target:nil selector:nil];
            blankView.actionView.hidden = true;
        }
        self.tableView.backgroundView = blankView;
    }else{
        self.tableView.backgroundView = nil;
    }
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return _groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    NSArray *groupData = CRArrayObject(_groups, section);
    if (CRJSONIsArray(groupData)) {
        return groupData.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"title"];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"title"];
        headerView.textLabel.font = MSGFont(12);
        headerView.textLabel.textColor = [UIColor colorFromHexRGB:@"aaaaaa"];
        headerView.textLabel.textAlignment = NSTextAlignmentLeft;
        headerView.backgroundColor = [UIColor colorFromHexRGB:@"ecebea"];
    }
    NSArray *groupData = CRArrayObject(_groups, section);
    if (groupData.count>0) {
        MessageEntity *message = CRArrayObject(groupData, 0);
        NSString *date = [_formmater stringFromDate:message.cTime];
        headerView.textLabel.text = date;
    }
    return headerView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 82;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCenterCell *cell = (MCenterCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifire];
    // Configure the cell...
    if (!cell) {
        cell = [Utility nibWithName:@"MCenterCell" index:0];
    }
    NSArray *groupData = CRArrayObject(_groups, indexPath.section);
    if (groupData) {
        MessageEntity *message = CRArrayObject(groupData, indexPath.row);
        [cell buildWithData:message];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSArray *groupData = CRArrayObject(_groups, indexPath.section);
    if (groupData.count>0) {
        MessageEntity *message = CRArrayObject(groupData, indexPath.row);
        if (message) {
            BOOL result = [[MCenterManager sharedManager] readMessageWithID:message.mid];
            if (result) {
                message.isRead = true;
            }
            MContentController *content = [[MContentController alloc] init];
            content.message = message;
            [self.navigationController pushViewController:content animated:true];
        }
    }
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *groupData = CRArrayObject(_groups, indexPath.section);
    if (groupData.count>0) {
        MessageEntity *message = CRArrayObject(groupData, indexPath.row);
        if (message) {
           BOOL result = [[MCenterManager sharedManager] deleteMessageWithID:message.mid];
            if (result) {
                [groupData removeObject:message];
                [tableView reloadData];
            }
        }
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
