//
//  XMSingleListController.m
//  msgcopy
//
//  Created by wngzc on 15/5/28.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "XMSingleListController.h"
#import "SingleListCell.h"
#import "ChatMessageEntity.h"
#import "XMContntController.h"
#import "ContactController.h"

static NSString *CellIdentifire = @"SingleListCell";

@interface XMSingleListController ()<UITableViewDataSource,UITableViewDelegate>
{
    BlankView *blankView;
}
@property (weak, nonatomic)IBOutlet UITableView *listView;
@property (nonatomic,retain)NSMutableArray *datas;
@end

@implementation XMSingleListController

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
-(void)dealloc
{
    [self removeNotifications];
}
-(void)configNavigationItem
{
    //config some
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 27, 27);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [button setImage:[UIImage imageNamed:@"msg_group_new"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showContact:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.tabBarController.navigationItem.rightBarButtonItem = add;
}
-(void)showContact:(id)sender{
    
    ContactController *contact = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ContactController"];
    [self.navigationController pushViewController:contact animated:true];
    
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
    if ([message.useagetype isEqualToString:@"service"]||[message.type isEqualToString:@"groupchat"]) {
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
}
/**
 *  loadDataSource
 */
-(void)loadDataSource
{
    _datas = [NSMutableArray new];
}
-(void)reloadData
{
    NSArray *history = [[HistoryContentManager sharedManager] getAllhistoryWithRoser:kCurUserName isServer:false type:@"chat"];
    [_datas removeAllObjects];
    [_datas addObjectsFromArray:history];
    [_listView reloadData];
    if (_datas.count == 0) {
        if (!blankView) {
            blankView = [BlankView blanViewWith:[UIImage imageNamed:@"message_blank"] descr:@"您暂时还没有聊天消息" actionTitle:nil target:nil selector:nil];
            blankView.actionView.hidden = true;
        }
        self.listView.backgroundView = blankView;
    }else{
        self.listView.backgroundView = nil;
    }
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
    SingleListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire];
    if (!cell) {
        cell = [Utility nibWithName:CellIdentifire index:0];
    }
    ChatMessageEntity *message = CRArrayObject(_datas, indexPath.row);
    [cell buildWithMessage:message];
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
    XMContntController *XMVC = [XMContntController messagesViewController];
    ChatMessageEntity *message = CRArrayObject(_datas, indexPath.row);
    SingleListCell *cell = (SingleListCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (message) {
        XMVC.roser = [message.from isEqualToString:kCurUserName]?message.to : message.from;
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
