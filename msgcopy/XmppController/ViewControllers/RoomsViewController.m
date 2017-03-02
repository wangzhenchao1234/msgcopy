//
//  RoomsViewController.m
//  Kaoke
//
//  Created by wngzc on 14/12/24.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "RoomsViewController.h"
#import "RoomChatEntity.h"
#import "RoomCell.h"
#import "XMMUCController.h"
#import "HistoryContentManager.h"
#import "MCenterManager.h"

@interface RoomsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tabeView;
@property(nonatomic,retain)NSMutableArray *rooms;
@end

@implementation RoomsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"群组";
    [self configTableView];
    // Do any additional setup after loading the view.
}
-(void)configTableView
{
    //config some
    CRWeekRef(self);
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [[HistoryContentManager sharedManager] getAllRoomsComplete:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__self.tableView.header endRefreshing];
            
//            NSLog(@"**************************%@",data);
            
            
            
            if (!msg) {
                _rooms = data;
                [__self.tableView reloadData];
            }else{
                [CustomToast showMessageOnWindow:msg];
            }
        }];
    }];
    [self.tableView.header performSelector:@selector(beginRefreshing) withObject:nil afterDelay:1];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _rooms.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [Utility nibWithName:@"RoomCell" index:0];
    }
    if (_rooms.count > indexPath.row) {
        RoomChatEntity *room = _rooms[indexPath.row];
        cell.titleView.text = room.title;
        cell.statusView.text = room.groupstatus;
        cell.iconView.layer.cornerRadius = cell.iconView.frame.size.width/2;
        [cell.iconView sd_setImageWithURL:[NSURL URLWithString:room.headphoto] placeholderImage:[UIImage imageNamed:@"ic_group"]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_rooms.count > indexPath.row) {
        RoomChatEntity *room = _rooms[indexPath.row];
        if ([room.groupstatus isEqualToString:@"已加群"]) {
            //进入聊天室
            XMMUCController *XMVC = [XMMUCController messagesViewController];
            XMVC.roser = room.roomname;
            XMVC.senderDisplayName = room.title;
            [self.navigationController pushViewController:XMVC animated:true];

        }else if ([room.groupstatus isEqualToString:@"未申请"]) {
            
            CRWeekRef(self);
            [GVConfirmView showConfirm:@"是否加入该群" inView:self.view confirmButton:@"确定" action:^{
                [__self joinGroup:room];
            } cancelTitle:@"取消" action:^{
                
            }];
        }
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_rooms.count > indexPath.row) {
        CRWeekRef(self);
        RoomChatEntity *room = _rooms[indexPath.row];
        if ([room.groupstatus isEqualToString:@"已加群"]) {
            //退群
            [GVConfirmView showConfirm:@"是否退出该群" inView:self.view confirmButton:@"确定" action:^{
                [__self quiteGroup:room];
            } cancelTitle:@"取消" action:^{
                
            }];

        }else if([room.groupstatus isEqualToString:@"申请中..."]){
            //取消申请
            [GVConfirmView showConfirm:@"是否取消申请" inView:self.view confirmButton:@"确定" action:^{
                [__self quiteGroup:room];
            } cancelTitle:@"取消" action:^{
                
            }];
        }
    }
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_rooms.count > indexPath.row) {
        RoomChatEntity *room = _rooms[indexPath.row];
        if ([room.groupstatus isEqualToString:@"未申请"]) {
            return UITableViewCellEditingStyleNone;
        }
    }
    return UITableViewCellEditingStyleDelete;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_rooms.count > indexPath.row) {
        RoomChatEntity *room = _rooms[indexPath.row];
        if ([room.groupstatus isEqualToString:@"申请中..."]) {
            return @"取消申请";
        }
    }
    return @"退群";
}

-(void)joinGroup:(RoomChatEntity*)room{
    //加群
    CRWeekRef(self);
    [__self modifyRoomStatus:@"applying" room:room];
}
-(void)cancelGroup:(RoomChatEntity*)room{
    //取消申请
    CRWeekRef(self);
    [__self modifyRoomStatus:@"apply" room:room];
}
-(void)quiteGroup:(RoomChatEntity*)room{
    //退群群
    CRWeekRef(self);
    [__self modifyRoomStatus:@"apply" room:room];
}
-(void)modifyRoomStatus:(NSString*)status room:(RoomChatEntity*)room
{
    NSString *appID = CRString(@"%d",kCurApp.aid);
    NSString *userstatus = status;
    NSString *username = kCurUser.userName;
    NSDictionary *params = @{@"app":appID,@"userstatus":userstatus,@"username":username};
    CRWeekRef(self);
    [MSGRequestManager MKUpdate:kAPIModifyRoomStatus(room.rid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if ([status isEqualToString:@"apply"]) {
            room.groupstatus = @"未申请";
        }else{
            room.groupstatus = @"申请中";
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [MCenterManager sendApplyToadmin:@"群聊提醒" content:[NSString stringWithFormat:@"该用户申请加入您的群组%@",room.title] success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [CustomToast showMessageOnWindow:@"消息已发送"];
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [CustomToast showMessageOnWindow:msg];
            }];
            
        });
        [__self.tableView reloadData];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
