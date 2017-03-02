//
//  XMRommListController.m
//  msgcopy
//
//  Created by Gavin on 15/5/28.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "XMRoomListController.h"
#import "ChatMessageEntity.h"
#import "RoomChatEntity.h"
#import "RoomListCell.h"
#import "XMMUCController.h"
#import "RoomsViewController.h"

static NSString *CellIdentifire = @"RoomListCell";

@interface XMRoomListController ()<UITableViewDataSource,UITableViewDelegate>
{
    BlankView *blankView;
}
@property (weak, nonatomic)IBOutlet UITableView *listView;
@property (nonatomic,retain)NSMutableArray *datas;
@end

@implementation XMRoomListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNotifications];
    [self configTableView];
    [self loadDataSource];

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configNavigationItem];
    [self reloadData];
}
-(void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recciveNewMessage:) name:kChatMessageNotification object:nil];
}
-(void)dealloc
{
    [self removeNotifications];
}
-(void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageNotification object:nil];
}
-(void)recciveNewMessage:(NSNotification*)notification
{
    ChatMessageEntity *message = notification.object;
    if ([message.useagetype isEqualToString:@"service"]||[message.type isEqualToString:@"chat"]) {
        return;
    }
    [self reloadData];
}
/**
 *  configTableView
 */
-(void)configTableView
{
    _listView.contentInset = UIEdgeInsetsMake(NAV_H, 0, 0, 0);
    CRWeekRef(self);
    [_listView addLegendHeaderWithRefreshingBlock:^{

        [[HistoryContentManager sharedManager] getAllRoomsComplete:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__self.listView.header endRefreshing];
            [__self reloadData];
        }];
    
    }];
}

-(void)configNavigationItem
{
    //config some
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 27, 27);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [button setImage:[UIImage imageNamed:@"msg_group_new"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(joinRoom:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.tabBarController.navigationItem.rightBarButtonItem = add;
}
-(void)joinRoom:(id)sender{
    
    RoomsViewController *rooms = [[RoomsViewController alloc] init];
    [self.navigationController pushViewController:rooms animated:true];

}
/**
 *  loadDataSource
 */
-(void)loadDataSource
{
    _datas = [NSMutableArray new];
}

/**
 *  刷新
 */
-(void)reloadData{
    
    [self.datas removeAllObjects];
    NSArray *rosersData = [[HistoryContentManager sharedManager] getAllhistoryWithRoser:kCurUserName isServer:false type:@"groupchat"];
    NSArray *rooms = [HistoryContentManager sharedManager].rooms;
    CRWeekRef(self);
    [rosersData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ChatMessageEntity *entity = obj;
        NSString *name = entity.to;
        [rooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            RoomChatEntity *room = obj;
            if ([room.roomname isEqualToString:name]&&[room.groupstatus isEqualToString:@"已加群"]) {
                [__self.datas addObject:entity];
                *stop = true;
            }
        }];
    }];
    if (_datas.count == 0) {
        if (!blankView) {
            blankView = [BlankView blanViewWith:[UIImage imageNamed:@"message_blank"] descr:@"您暂时还没有聊天消息" actionTitle:nil target:nil selector:nil];
            blankView.actionView.hidden = true;
        }
        self.listView.backgroundView = blankView;
    }else{
        self.listView.backgroundView = nil;
    }
    [self.listView reloadData];
}
#pragma mark - tableViewDeleagate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire];
    if (!cell) {
        cell = [Utility nibWithName:CellIdentifire index:0];
    }
    ChatMessageEntity *message = CRArrayObject(_datas, indexPath.row);
    NSArray *rooms = [HistoryContentManager sharedManager].rooms;
   [rooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       RoomChatEntity *room = obj;
       if ([room.roomname isEqualToString:message.to]||[room.roomname isEqualToString:message.from]) {
           [cell.iconView sd_setImageWithURL:CRURL(room.headphoto)];
           *stop = true;
       }
   }];
    [cell buildByData:message];
    return cell;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMessageEntity *message = CRArrayObject(_datas, indexPath.row);
    if (message) {
        NSString *roser = [message.from isEqualToString:kCurUserName]?message.to:message.from;
        BOOL resultCur = [[ContentManager sharedManager] deleteChatHistryWithRoser:roser type:@"chat" isServer:false];
        BOOL resultHis = [[HistoryContentManager sharedManager] deleteChatHistryWithRoser:roser isServer:false type:@"chat"];
        if (resultCur||resultHis) {
            [_datas removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [CustomToast showMessageOnWindow:@"发生未知错误"];
        }
        
    }else{
        [CustomToast showMessageOnWindow:@"发生未知错误"];
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    XMMUCController *XMVC = [XMMUCController messagesViewController];
    ChatMessageEntity *message = CRArrayObject(_datas, indexPath.row);
    RoomListCell *cell = (RoomListCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (message) {
        XMVC.roser = message.to;
        XMVC.senderDisplayName = cell.titleView.text;
        [CRRootNavigation() pushViewController:XMVC animated:true];
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
