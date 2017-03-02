//
//  XmppListenerManager.m
//  msgcopy
//
//  Created by wngzc on 15/5/27.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "XmppListenerManager.h"
#import "ChatMessageEntity.h"
#import "RoomChatEntity.h"
#import "HistoryContentManager.h"

#define CONNTECT_TIMEOUT 20


@implementation XmppListenerManager
/**
 *  单例
 *  @return 单例对象
 */
+(XmppListenerManager*)sharedManager{
    
    static XmppListenerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
    
}
/**
 *  构造
 *
 *  @return self
 */
-(id)init{
    
    self = [super init];
    if (self) {
        
        [self intilizedXmpp];
        [self registInternetServer];
        
    }
    return self;
}
/**
 *  初始化 _contentManager
 */
-(void)intilizedContentManager{
    
    _contentManager = [ContentManager sharedManager];
    
}
/**
 *  xmppstream
 *
 *  @return _xmppStream
 */
-(XMPPStream *)xmppStream{
    
    return _xmppStream;
    
}
/**
 *  contentManager
 *
 *  @return _contentManager
 */
-(ContentManager*)contentManager{
    
    return _contentManager;
    
}
/**
 *  注册网络状态通知
 */
-(void)registInternetServer{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataNotification:) name:NOTIFICATION_INTERNET_STATUS object:nil];
    
}
/**
 *  网络状态改变收到通知
 *
 *  @param notification 通知信息
 */
-(void)onDataNotification:(NSNotification*)notification{
    
    NSDictionary* userinfo = notification.userInfo;
    id data = [userinfo objectForKey:@"data"];
    if ([data integerValue] != NotReachable) {
        _isNetworkOK = true;
        [self disconnect];
        [self connectToServer];
        
    }else{
        _isNetworkOK = false;
    }
    [self changeChatState];
}
/**
 * 初始化_xmppStream
 */
-(void)intilizedXmpp{
    
    
    // Note that this input contains multiple top-level JSON documents
    Reachability *intenet = [Reachability reachabilityForInternetConnection];
    _isNetworkOK = false;
    if (intenet.isReachable) {
        _isNetworkOK = true;
    }
    _reconnectCount = 0;
    NSString *path
    = [[NSBundle mainBundle] pathForResource:@"msgTritone" ofType:@"caf"];
    NSURL *soundUrl=[[NSURL alloc] initFileURLWithPath:path];
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    _player=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    //    [_player prepareToPlay];
    
    _aid = kCurAppID;
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    _jsonParser = [[SBJsonParser alloc] init];
    
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _xmppStream.enableBackgroundingOnSocket = YES;
    
    /**
     *  好友列表
     */
    _xmppReconnect = [[XMPPReconnect alloc] init];
    [_xmppReconnect activate:_xmppStream];
    [_xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
/**
 *  配置服务器
 *
 *  @param userName   用户名
 *  @param host 服务器IP
 *  @param port       服务器端口
 */
-(void)setUser:(UserEntity *)user{
    
    [self disconnect];
    [_rosers removeAllObjects];
    [_rooms removeAllObjects];
    _rosers   = Nil;
    _rooms    = Nil;
    _rosers   = [NSMutableArray new];
    _rooms    = [NSMutableArray new];
    _user = user;
    [self connectToServer];
}

/**
 *  登录
 */
-(void)connectToServer{
    
    NSString *username = [NSString convertName:_user.userName];
    [_xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%d|%@@%@",_aid,username,XMPP_SERVER_HOST] resource:@"Smack"]];
    [_xmppStream setHostName:XMPP_SERVER_HOST];
    NSLog(@"、、、、、、、、、、、、、、、、、XMPPJID - %@",[XMPPJID jidWithString:[NSString stringWithFormat:@"%d|%@@%@",_aid,username,XMPP_SERVER_HOST]]);
    [_xmppStream setHostPort:XMPP_SERVER_PORT];
    NSError *error = nil;
    BOOL success = [_xmppStream connectWithTimeout:CONNTECT_TIMEOUT error:&error];
    if (error&&!success) {
        
        NSLog(@"################# - %@",error);
        ;
    [CustomToast showMessageOnWindow:@"聊天服务器连接失败"];
        
    }else{
        
       
       
    }
}
-(void)connectToRooms{
    
    NSArray *rooms = [[HistoryContentManager sharedManager] rooms];
    [rooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RoomChatEntity *room = obj;
        if ([room.groupstatus isEqualToString:@"已加群"]) {
            XMPPJID *jid = [XMPPJID jidWithString:CRString(@"%@@conference.%@",room.roomname,XMPP_SERVER_HOST)];
            XMPPRoom *xmRomm = [[XMPPRoom alloc] initWithRoomStorage:self jid:jid];
            [xmRomm activate:_xmppStream];
            [xmRomm addDelegate:self delegateQueue:dispatch_get_main_queue()];
            [xmRomm joinRoomUsingNickname:[_xmppStream myJID].user history:nil];
        }
    }];
    
}
-(void)joinRoom:(NSString *)roomName{
    
    XMPPJID *jid = [XMPPJID jidWithString:CRString(@"%@@conference.%@",roomName,XMPP_SERVER_HOST)];
    XMPPRoom *xmRomm = [[XMPPRoom alloc] initWithRoomStorage:self jid:jid];
    [xmRomm activate:_xmppStream];
    [xmRomm addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmRomm joinRoomUsingNickname:[_xmppStream myJID].user history:nil];
    
    
}
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    CRLog(@"%@", sender);
}
//获取聊天室信息
- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
        [sender fetchConfigurationForm];
        [sender fetchBanList];
        [sender fetchMembersList];
        [sender fetchModeratorsList];
}
- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitation:(XMPPMessage *)message{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"didReceiveInvitation %@", message);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    
}
- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *) roomJID didReceiveInvitationDecline:(XMPPMessage *)message{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"ReceiveInvitationDecline %@", message);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    
}
- (BOOL)configureWithParent:(XMPPRoom *)aParent queue:(dispatch_queue_t)queue{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"%@", aParent);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    return true;
}
- (void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"presence:%@", presence);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    
}

/**
 * Stores or otherwise handles the given message element.
 **/
- (void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    NSLog(@"xmpp ....  进入房间");
    CRLog(@"\n-----------------------------------------------------------------\n\n");
}
- (void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    NSLog(@"xmpp ....  退出房间");
    CRLog(@"\n-----------------------------------------------------------------\n\n");
}

/**
 * Handles leaving the room, which generally means clearing the list of occupants.
 **/
- (void)handleDidLeaveRoom:(XMPPRoom *)room{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"离开房间: %@", room);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
}
/**
 *  注销登录
 */
- (void)disconnect{
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
    [_xmppStream disconnect];
    [_xmppReconnect deactivate];
    
    
}
/**
 *  release 释放内存
 */
- (void)teardownStream
{
    
    [_xmppStream removeDelegate:self];
    [_xmppReconnect deactivate];
    [_xmppStream disconnect];
    
    _xmppStream = nil;
    _xmppReconnect = nil;
}
/**
 *  启动连接操作后，回调函数（委托函数）
 *
 *  @param sender sender
 */
- (void)xmppStreamWillConnect:(XMPPStream *)sender{//将被调用，表示将要连接
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"正在连接服务器...");
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    
}
/**
 *  连接成功
 *
 *  @param sender sender
 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"连接成功...");
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    
    CRLog(@"%@", sender);
    
    NSError *error = nil;
    
    //验证帐户密码
    
    NSString *password = @"1234";
    
    BOOL bRes =  [_xmppStream authenticateWithPassword:password error:&error];
    if (!bRes) {
        /**
         * 验证失败
         */
        CRLog(@"\n\n-----------------------------------------------------------------\n");
        CRLog(@"验证失败%@", error);
        CRLog(@"\n-----------------------------------------------------------------\n\n");
    }
}
/**
 *  验证成功的回调函数
 *
 *  @param sender sender
 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    CRLog(@"上线");
    /**
     * 发送上线通知
     */
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
   // _isHideFailureImage = YES;
    [self changeChatState];
    /**
     *获取好友列表
     */
    [self intilizedContentManager];
    [self connectToRooms];

    
}
/**
 *  连接状态发生变化
 */
-(void)changeChatState{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPPConnectStateChanged object:nil];
}
/**
 *  验证失败的回调
 *
 *  @param sender sender
 *  @param error  错误信息
 */

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    
    CRLog(@"%@", error);
    /**
     *登录失败未注册
     */
    NSError *err;
    NSString *tjid = [[NSString alloc] initWithFormat:@"anonymous@%@", XMPP_SERVER_HOST];
    [_xmppStream setMyJID:[XMPPJID jidWithString:tjid]];
    if (![_xmppStream isConnected]) {
        if ( ![_xmppStream connectWithTimeout:20 error:&err])
        {
            
        }
    }else{
        NSString *username = [NSString convertName:_user.userName];
        [_xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%d|%@@%@",_aid,username,XMPP_SERVER_HOST]]];
        NSError *error=nil;
        if (![_xmppStream registerWithPassword:@"1234" error:&error])
        {
            NSLog(@"注册失败------%@",error);
        }
        
    }
}
/**
 *  注册成功
 */
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"注册成功%@", sender);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    [self disconnect];
    [self connectToServer];
}
/**
 *  注册失败
 */
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    
    CRLog(@"%@", error);
    
}
/**
 *  收到消息
 *
 *  @param sender  收到者
 *  @param message 消息内容
 */
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"收到来自消息:\n %@ \n", message);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    
    if (!message.from.user) {
        return;
    }
    if (message.errorMessage) {
        return;
    }
    NSString *username = kCurUserName;
    ChatMessageEntity *entity = [ChatMessageEntity buildWithXml:message];
    NSString *source = message.from.resource;
    NSString *user = [self getJID:source];
    user = [NSString userName:user];
    if ([entity.type isEqualToString:@"groupchat"]) {
        if ([[ContentManager sharedManager] isContainMessage:entity]||[user isEqualToString:username])
        {
            return;
        }
    }else{
        entity.to = [self getJID:_xmppStream.myJID.user];
        entity.from = [self getJID:message.from.user];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_player prepareToPlay];
        [_player play];
    });
    [self reciveMessage:entity];
    if (!([UIApplication sharedApplication].applicationState == UIApplicationStateActive)) {
        [self sendLocalNotification:entity];
    }
}
-(void)reciveMessage:(ChatMessageEntity*)entity{
    entity.isHideFailureImage = @"1";
    NSInteger cid =  [[ContentManager sharedManager] storeMessage:entity];
    entity.cid = cid;
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatMessageNotification object:entity];
}
/**
 *  程序在后台发送本地推送
 *
 *  @param data message
 */
-(void)sendLocalNotification:(ChatMessageEntity*)message{
    
    NSString *text = message.text;
    if (message.souceType == SOMessageTypeAudio) {
        text = @"[语音]";
    }
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:0];
    notification.repeatInterval = kCFCalendarUnitEra;
    notification.fireDate = pushDate;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = [NSString stringWithFormat:@"%@:\n%@",message.nickName,text];
    notification.userInfo = @{@"new_chat": @"true"};
    notification.alertAction = NSLocalizedString(@"确定", nil);
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}
/**
 *  成功发送消息
 *
 *  @param sender  发送者
 *  @param message 消息内容
 */
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message;
{   NSLog(@"message===%@",message);
    ChatMessageEntity *entity = [ChatMessageEntity buildWithXml:message];
    entity.from = kCurUserName;
    entity.isRead = true;
    entity.isHideFailureImage = @"1";
    NSLog(@"entity.isHideFailureImage===%@",entity.isHideFailureImage);
    [self saveMessage:entity];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHAT_SUCCESS object:entity];
}

-(void)saveMessage:(ChatMessageEntity*)message{
    [[ContentManager sharedManager] storeMessage:message];
}
-(NSString *)getJID:(NSString *)JID{
    
    NSRange range = [JID rangeOfString:@"|"];
    if (range.location!=NSNotFound) {
        
        return [JID substringFromIndex:JID.length>0?range.location+1:0];
    }
    return JID;
}
/**
 *  发送消息失败
 *
 *  @param sender  发送者
 *  @param message 消息内容
 *  @param error   错误信息
 */
-(void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    
    ChatMessageEntity *entity = [ChatMessageEntity buildWithXml:message];
    entity.isHideFailureImage = @"0";
    entity.isRead = true;
    entity.from = kCurUserName;
    NSLog(@"entity===%@",entity);
    [self saveMessage:entity];

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHAT_FAILED object:entity];
}
-(SOMessageType)parseSourceType:(NSString *)type{
    if ([type isEqualToString:@"txt"]) {
        return SOMessageTypeText;
    }
    if ([type isEqualToString:@"audio"]) {
        return SOMessageTypeAudio;
    }
    if ([type isEqualToString:@"pic"]) {
        return SOMessageTypePhoto;
    }
    if ([type isEqualToString:@"video"]) {
        return SOMessageTypeVideo;
    }
    return SOMessageTypeOther;
}
/**
 *  xmpp收到错误
 *
 *  @param sender
 *  @param error  错误信息
 */
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
//    CRLog(@"连接成功 ：%@",socket);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    
}
-(void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"错误 ：%@",error);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    [_xmppReconnect deactivate];
    
}
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"断开连接 ：%@",error);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
        //_isHideFailureImage = NO;
    [self changeChatState];
    
}
//新人加入群聊
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID
{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"加入聊天室 ：%@",occupantJID);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
}
//有人退出群聊
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID
{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"退出聊天室 ：%@",occupantJID);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
}
//有人在群里发言
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"%@在聊天室发言 ：%@",occupantJID,message);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
}

/**
 *  失去连接
 *
 *  @param sender xmppstream
 */
-(void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender{
    
    CRLog(@"\n\n-----------------------------------------------------------------\n");
    CRLog(@"失去连接 ：%@",sender);
    CRLog(@"\n-----------------------------------------------------------------\n\n");
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [_xmppReconnect deactivate];
        return;
    }
    [self disconnect];
    [self connectToServer];
}

/**
 *  析构
 */
-(void)dealloc{
    [self teardownStream];
}

@end
