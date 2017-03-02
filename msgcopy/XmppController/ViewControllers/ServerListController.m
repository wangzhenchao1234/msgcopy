//
//  ServerListController.m
//  msgcopy
//
//  Created by wngzc on 15/8/7.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ServerListController.h"
#import "ChatServerEntity.h"
#import "ChatMessageEntity.h"
#import "ChatHistoryCell.h"
#import "ChatServerCell.h"
#import "XMContntController.h"
#import "XMServerContentController.h"

@interface ServerListController ()
{
    NSMutableArray *_serverGroups;
    NSMutableArray *_historyDatas;
    UIImageView *_blankView;
    ChatMessageEntity *_masterHistory;
}
@end

@implementation ServerListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNotifications];
    [self configTableView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recciveNewMessage:) name:kChatMessageNotification object:nil];
}

-(void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageNotification object:nil];
}

-(void)recciveNewMessage:(NSNotification*)notification
{
    ChatMessageEntity *message = notification.object;
    if ([message.useagetype isEqualToString:@"service"]&&[message.type isEqualToString:@"chat"]) {
        [self refreshServerData];
    }
}

-(void)dealloc
{
    [self removeNotifications];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id data = [LocalManager objectForKey:@"servers_json"];
    NSDate *ldate =CRUserObj(@"servers_refresh_date");
    NSDate *cdate = [NSDate date];
    NSInteger time = [cdate timeIntervalSinceDate:ldate];
    if (!data||time > 1800||[_serverGroups count]==0) {
        [self.tableView.header beginRefreshing];
    }else{
        [self refreshHistoryData];
    }
}

-(void)configTableView
{
    //config some
    self.title = @"客服";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    CRWeekRef(self);
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [__self refreshServerData];
    }];
    
}

-(void)refreshServerData
{
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIChatServer(kCurAppID) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__self.tableView.header endRefreshing];
        [LocalManager storeObject:data forKey:@"servers_json"];
        CRUserSetObj([NSDate date], @"servers_refresh_date");
        NSMutableArray *groupEntities = [NSMutableArray new];
        for (NSDictionary *json in data) {
            ChatServerEntity *server = [ChatServerEntity buildByinstans:json];
            [groupEntities addObject:server];
        }
        _serverGroups = groupEntities;
        [__self refreshHistoryData];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
        [__self.tableView.header endRefreshing];
    }];

}

-(void)refreshHistoryData
{
    NSMutableArray *newArray = [NSMutableArray new];
    UserEntity *user = kCurUser;
    NSString *username = [NSString convertName:user.userName];
    NSArray *rosersData = [[HistoryContentManager sharedManager] getAllServerHistoryWithRoser:username isServer:true type:@"chat"];
    NSMutableArray *allServers = [NSMutableArray new];
    for (ChatServerEntity *server in _serverGroups) {
        for (ServerEntity *user in server.users) {
            [allServers addObject:user];
        }
    }
    for (ChatMessageEntity *entity in  rosersData) {
        BOOL has = false;
        for (ServerEntity *server in allServers) {
            if ([entity.from isEqualToString:[NSString convertName:user.userName]]&&[entity.to isEqualToString:[NSString convertName:user.userName]]) {
                has = true;
            }else{
                NSString *userName = entity.from;
                NSString *myName = [NSString convertName:user.userName];
                if ([entity.from isEqualToString:myName]) {
                    userName = entity.to;
                }
                if ([server.username isEqualToString:[NSString userName:userName]]) {
                    has = true;
                }
            }
        }
        if (!has) {
            [newArray addObject:entity];
        }
    }
    if (!_historyDatas) {
        _historyDatas = [[NSMutableArray alloc] init];
    }
    [_historyDatas removeAllObjects];
    [_historyDatas addObjectsFromArray:newArray];
    [allServers removeAllObjects];
    allServers = nil;
    [newArray removeAllObjects];
    newArray = nil;
    if (rosersData.count ==0&&_serverGroups.count == 0) {
        self.tableView.backgroundView = _blankView;
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
    NSInteger num = 0;
    if (_historyDatas.count>0) {
        num += 1;
    }
    if (_master) {
        num  += 1;
    }
    return _serverGroups.count + num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0&&_master) {
        if (!_masterHistory) {
            return 0;
        }
        return 1;
    }
    if (section == tableView.numberOfSections - 1&&_historyDatas.count>0) {
        return _historyDatas.count;
    }
    ChatServerEntity *group = CRArrayObject(_serverGroups, section-(_master==nil?0:1));
    return group.users.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_master&&section == 0) {
        return 0;
    }
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    
    static NSString *historyCellIdentfire = @"Cell";
    if (_master&&indexPath.section == 0) {
        ChatHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:(historyCellIdentfire)];
        ChatMessageEntity *message = _masterHistory;
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatHistoryCell" owner:self options:nil] lastObject];
        }
        [cell buildByData:message];
//        cell.title.text = _pubMaster.firstName;
//        message.contact.title = _pubMaster.firstName;
        cell.time.text = @"";
        return cell;
    }
    if (indexPath.section == self.tableView.numberOfSections - 1&&_historyDatas.count>0) {
        ChatHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:historyCellIdentfire];
        if (!cell) {
            cell = [Utility nibWithName:@"ChatHistoryCell" index:0];
        }
        ChatMessageEntity *message = _historyDatas[indexPath.row];
        [cell buildByData:message];
        [self configureCell:cell withMessage:message];
        return cell;
    }
    static NSString *cellIdentfire = @"ServerCell";
    ChatServerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfire];
    ChatServerEntity *group = _serverGroups[indexPath.section-(_master==nil?0:1)];
    ServerEntity *server = group.users[indexPath.row];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ChatServerCell" owner:self options:nil] lastObject];
    }
    [cell buildByData:server];
    [cell setNeedsDisplay];
    return cell;

}

/**
 *  过滤客服用户名
 *  @param tableView
 */
-(void)configureCell:(ChatHistoryCell*)cell withMessage:(ChatMessageEntity *)message{
    UserEntity *user = kCurUser;
    NSString *name = message.from;
    if ([message.from isEqualToString:[NSString convertName:user.userName]]&&[message.to isEqualToString:[NSString convertName:user.userName]]) {
        name = message.from;
    }else{
        name = [message.from isEqualToString:[NSString convertName:user.userName]]?message.to:message.from;
    }
    for (ChatServerEntity *group in _serverGroups) {
        for (ServerEntity *server in group.users) {
            if ([server.username isEqualToString:name]) {
                cell.title.text = server.cs_name;
                break;
            }
        }
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *header = @"header";
    NSString *title = nil;
    if (_master&&section == 0) {
        title = @"";
    }
    if (section == tableView.numberOfSections-1&&_historyDatas.count>0) {
        title = @"接待记录";
    }else{
        ChatServerEntity *server = _serverGroups[section-(_master==nil?0:1)];
        title = server.title;
    }
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
        view.backgroundColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:0.8];
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width-20, 35)];
        lable.tag = 40;
        [view addSubview:lable];
        CGFloat height = 1/[UIScreen mainScreen].scale;
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 35 - height, tableView.frame.size.width, height)];
        line.backgroundColor = [UIColor lightGrayColor];
        [view addSubview:line];
    }
    UILabel *label = (UILabel*)[view viewWithTag:40];
    label.text = title;
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    return view;
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == tableView.numberOfSections - 1&&_historyDatas.count>0) {
        
        return UITableViewCellEditingStyleDelete;
        
    }
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    UserEntity *user = kCurUser;
    if (_historyDatas.count>indexPath.row) {
        ChatMessageEntity *message = _historyDatas[indexPath.row];
        NSString *name = [message.from isEqualToString:[NSString convertName:user.userName]]?message.to:message.from;
        BOOL success = [[HistoryContentManager sharedManager] deleteChatHistryWithRoser:[NSString userName:name] isServer:true type:@"chat"];
        if (success) {
            [_historyDatas removeObjectAtIndex:indexPath.row];
            if (_historyDatas.count == 0) {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
            }else{
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            }
        }
    }
}

/**
 *  点击事件
 *
 *  @param tableView
 *  @param indexPath 索引
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_master&& indexPath.section == 0) {
        XMContntController *XMVC = [XMContntController messagesViewController];
        XMVC.roser = _master;
        XMVC.senderDisplayName = _master;
        [self.navigationController pushViewController:XMVC animated:true];
        return;
    }
    
    /**
     *  如果是最后一组并且接待记录不为0
     */
    if (_historyDatas.count>0&&indexPath.section == tableView.numberOfSections - 1) {
        ChatMessageEntity *entity = _historyDatas[indexPath.row];
        if (entity) {
            XMServerContentController *XMVC = [XMServerContentController messagesViewController];
            XMVC.roser = ([entity.from isEqualToString:[NSString convertName:kCurUser.userName]]?entity.to:entity.from);
            XMVC.senderDisplayName = ([entity.from isEqualToString:[NSString convertName:kCurUser.userName]]?entity.from:entity.nickName);
            [self.navigationController pushViewController:XMVC animated:YES];
        }
        return;
    }
    
    ChatServerEntity *group = _serverGroups[indexPath.section - (_master==nil?0:1)];
    ServerEntity *server = group.users[indexPath.row];
    XMServerContentController *XMVC = [XMServerContentController messagesViewController];
    XMVC.roser = server.username;
    XMVC.senderDisplayName =server.cs_name;
    [self.navigationController pushViewController:XMVC animated:YES];
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
