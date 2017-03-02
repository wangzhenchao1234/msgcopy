//
//  ContentManager.m
//  SOSimpleChatDemo
//
// Created by : arturdev
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
//

#import "ContentManager.h"
#import <FMDB/FMDB.h>
#import "HistoryContentManager.h"
#import "ChatMessageEntity.h"
#import "XmppListenerManager.h"
#import "RoomChatEntity.h"

@implementation ContentManager
/**
 *  单例
 *
 *  @return 单例实例
 */
+ (ContentManager *)sharedManager
{
    
    static ContentManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
    
}
+(FMDatabaseQueue *)getSharedInstance
{
    static FMDatabaseQueue *my_FMDatabaseQueue=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path               = [paths objectAtIndex:0];
        path                         = [path stringByAppendingString:@"/Msgcopy.db"];
        my_FMDatabaseQueue           = [[FMDatabaseQueue alloc] initWithPath:path];
    });
    return my_FMDatabaseQueue;
}

/**
 *  reset
 */

-(void)clear{
    [self initDatabase];
}

/**
 *  构造
 *
 *  @return 实例
 */

-(id)init{
    
    self = [super init];
    if (self) {
        [self initDatabase];
    }
    return self;
    
}

/**
 *  初始化database
 */

-(void) initDatabase{
    
    NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path               = [paths objectAtIndex:0];
    path                         = [path stringByAppendingString:@"/Msgcopy.db"];
    NSLog(@"ChatHistoryPath = %@",path);
    self.database                = [[FMDatabase alloc] initWithPath:path];
    self.database.traceExecution = YES;
    //建表
    if ([self.database open]) {
        [self.database executeUpdate: [self sqlForCreateTable]];
        [self.database close];
    }
    [self setVersion:@"1.0"];
}

-(NSString *)tableName{
    
    return @"XmppCur";
    
}
/**
 *  版本号
 *
 *  @return 版本号
 */
-(CGFloat)sqlVersion{
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *verionStr = [ud valueForKey:@"xmppcur_version"];
    if (verionStr) {
        return [verionStr floatValue];
    }else{
        return 0;
    }
}
/**
 *  设置版本号
 *
 *  @param version 版本号
 */
-(void)setVersion:(NSString *)version{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:version forKey:@"xmppcur_version"];
    [ud synchronize];
}
/**
 *  建表语句
 *
 *  @return 建表语句
 */

-(NSString *) sqlForCreateTable{
    
    /**
     *
     *  @param username  用户名
     *  @param from      发送者
     *  @param to        接受者
     *  @param type      类型群发、客服、单独聊天
     *  @param content   内容
     *  @param time      时间
     *  @param isread    是否已读
     *
     */
    return [NSString stringWithFormat:@"CREATE TABLE if not exists XmppCur(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,username TEXT,mesfrom TEXT,mesto TEXT,type TEXT,usagetype TEXT,content TEXT,time text,isread boolean,isHideFailureImage text)"];
    
}
/**
 *  获取20条个人聊天记录
 *
 *  @param roserJID
 *
 *  @return 数据
 */

-(NSMutableArray *)getAllMessagesWithRoser:(NSString *)roser type:(NSString*)type isServer:(BOOL)server {
    
    return  [self getAllMessagesWithRoser:roser isServer:server type:type start:0];

}
-(NSMutableArray *)getAlGrouplMessagesWithRoser:(NSString *)roser{
    
    return  [self getAllGroupMessagesWithRoser:roser start:0];
    
}
/**
 *  获取20条个人聊天记录
 *
 *  @param roserJID
 *
 *  @return 数据
 */
-(NSString *)convertName:(NSString *)username{
    
    if (username&&username.length > 0) {
        return [username stringByReplacingOccurrencesOfString:@"@" withString:@"[at]"];
    }
    return username;
    
}
-(NSString *)userName:(NSString*)convertName{
    
    if (convertName&&convertName.length>0) {
        return [convertName stringByReplacingOccurrencesOfString:@"[at]" withString:@"@"];
    }
    return convertName;
    
}

-(NSMutableArray *)getAllMessagesWithRoser:(NSString *)roser isServer:(BOOL)server type:(NSString*)type start:(NSInteger)start
{

    NSString *username = kCurUserName;
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    
    __block NSMutableArray *jsons = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *jid = [self getJID:[XmppListenerManager sharedManager].xmppStream.myJID.user];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM XmppCur WHERE 1 = 1 AND username='%@' %@ AND type='%@' AND ((mesfrom='%@' and mesto='%@') OR (mesfrom='%@' AND mesto='%@')) ORDER BY id DESC  LIMIT %d, 20) ORDER BY time",username,usage,type,jid,roser,roser,jid,start];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
    }];
    NSMutableArray *datas = [NSMutableArray new];
    for (NSDictionary *json in jsons) {
        ChatMessageEntity *message = [ChatMessageEntity buildInstanceByJson:json];
        [datas addObject:message];
        if ([message.from isEqualToString:[self convertName:username]]) {
            message.fromMe = true;
        }
    }
    return datas;
    
}
-(NSMutableArray *)getAllGroupMessagesWithRoser:(NSString *)roser start:(NSInteger)start{
    
    NSString *username = kCurUserName;
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    
    __block NSMutableArray *jsons = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM XmppCur WHERE 1 = 1 AND username='%@' AND type='groupchat' AND mesto='%@' ORDER BY id DESC  LIMIT %d, 20) ORDER BY time",username,roser,start];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
    }];
    NSMutableArray *datas = [NSMutableArray new];
    for (NSDictionary *json in jsons) {
        ChatMessageEntity *message = [ChatMessageEntity buildInstanceByJson:json];
        [datas addObject:message];
        if ([message.from isEqualToString:[self convertName:username]]) {
            message.fromMe = true;
        }
    }
    return datas;
}
/**
 *  加载更多消息
 *
 *  @param index
 *
 *  @return
 */

-(NSArray *)getOlderMessagesWithRoser:(NSString *)roser isServer:(BOOL)server type:(NSString*)type fromIndex:(NSInteger)index
{
    NSArray *datas = [self getAllMessagesWithRoser:roser isServer:server type:type start:index];
    return  datas;
    
}

/**
 *  自定义语句查询
 *
 *  @param sql    sql查询语句
 *  @param params  参数
 *
 *  @return 数据结果
 */

-(NSArray *)getDataWithSql:(NSString *)sql parameters:(NSArray *)params{
    
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    
    __block NSMutableArray *jsons = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
        
    }];
    NSMutableArray *datas = [NSMutableArray new];
    NSString *username = kCurUserName;
    for (NSDictionary *json in jsons) {
        ChatMessageEntity *message = [ChatMessageEntity buildInstanceByJson:json];
        message.contentJson = [Utility dictionaryNullValue:json forKey:@"content"];
        if ([message.from isEqualToString:[self convertName:username]]) {
            message.fromMe = true;
        }
        [datas addObject:message];
    }
    return datas;
    
}
/**
 *  是否已经存在某条聊天记录
 *
 *  @param 内容
 *
 *  @return 结果
 */
-(BOOL)isContainMessage:(ChatMessageEntity*)message{
    
    NSString *username = kCurUserName;
    
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    __block NSMutableArray *jsons = [NSMutableArray new];
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppCur WHERE 1 = 1 AND username='%@' %@ AND type='groupchat' AND mesfrom='%@' AND mesto='%@' AND time='%@' ORDER BY time",username,usage,message.from,message.to,message.time];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
    }];
    return jsons.count>0?true:false;
}
/**
 *  自定义语句
 *
 *  @param sql sql语句
 */

-(BOOL)excuteSql:(NSString *)sql{
    
    __block BOOL result = NO;
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    [queue inDatabase:^(FMDatabase *db) {
        
      result = [db executeUpdate:sql withArgumentsInArray:nil];
        
    }];
    return result;
}

/**
 *  获取与制定用户聊天未读消息
 *
 *  @param roser 用户名
 *
 *  @return 未读数目
 */

-(NSInteger)getUnreadCountWithRoser:(NSString *)roser isServer:(BOOL)server type:(NSString *)type{
    
    if ([type isEqualToString:@"groupchat"]) {
        return [self getGroupUnreadCountWithRoser:roser isServer:server type:type];
    }
    NSString *username = kCurUserName;
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') " ;
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    
    __block NSMutableArray *jsons = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *jid = [self getJID:[XmppListenerManager sharedManager].xmppStream.myJID.user];
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppCur WHERE 1 = 1 AND username='%@' %@ AND ((mesfrom='%@' AND mesto='%@') OR (mesfrom='%@' AND mesto='%@')) AND type='%@' AND isread=0 ORDER BY id",username,usage,roser,jid,jid,roser,type];
        
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
    
    }];
    return jsons.count;
    
}
-(NSInteger)getGroupUnreadCountWithRoser:(NSString *)roser isServer:(BOOL)server type:(NSString *)type{
    
    NSString *username = kCurUserName;
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') " ;
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    
    __block NSMutableArray *jsons = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppCur WHERE 1 = 1 AND username='%@' %@ AND mesto='%@' AND type='%@' AND isread=0 ORDER BY id",username,usage,roser,type];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
        
    }];
    return jsons.count;
    
}

/**
 *  获取与所所有用户聊天未读消息
 *
 *  @param roser 用户名
 *
 *  @return 未读数目
 */

-(NSInteger)getUserUnreadCountType:(NSString *)type{
    
    NSString *username = kCurUserName;
    
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    NSArray *rooms = [HistoryContentManager sharedManager].rooms;
    __block NSMutableArray *jsons = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppCur WHERE 1 = 1 AND username='%@' AND isread=0 AND (usagetype='normal' OR usagetype='null') AND (type='%@') ORDER BY id",username,type];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            
            NSDictionary *result = [rs resultDictionary];
            if ([result[@"type"] isEqualToString:@"groupchat"]) {
                if (CRWebAppTitle(@"groupchat")) {
                    __block BOOL has = false;
                    [rooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        RoomChatEntity *room = obj;
                        if ([result[@"mesto"] isEqualToString:room.roomname]&&[room.groupstatus isEqualToString:@"已加群"]) {
                            has = true;
                            [jsons addObject: [rs resultDictionary]];
                            *stop = true;
                        }
                    }];
                }
            }else{
                [jsons addObject: [rs resultDictionary]];
            }
        };
        [rs close];
        
    }];
    return jsons.count;
    
}
-(NSInteger)getServerUnreadCount{
    
    NSString *username = kCurUserName;
    
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    
    __block NSMutableArray *jsons = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppCur WHERE 1 = 1 AND username='%@' AND isread=0 AND usagetype='service' AND type='chat' ORDER BY id",username];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
        
    }];
    return jsons.count;
    
}
/**
 *  更新与指定用户聊天的未读消息
 *
 *  @param roser 用户
 */

-(void)updateUnreadMessagesWithRoser:(NSString *)roser type:(NSString *)type isServer:(BOOL)server{
    
    if ([type isEqualToString:@"groupchat"]) {
        [self updateGroupUnreadMessagesWithRoser:roser type:type isServer:server];
        return;
    }
    
    NSString *username = kCurUserName;
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    NSString *jid = [self getJID:[XmppListenerManager sharedManager].xmppStream.myJID.user];
    NSString *sql = [NSString stringWithFormat:@"UPDATE XmppCur SET isread=1 WHERE username='%@' %@ AND ((mesfrom='%@' and mesto='%@') or (mesfrom='%@' and mesto='%@')) and type='%@' and isread=0",username,usage,roser,jid,jid,roser,type];
    [self excuteSql:sql];
    
}
-(void)updateGroupUnreadMessagesWithRoser:(NSString *)roser type:(NSString *)type isServer:(BOOL)server{
    
    NSString *username = kCurUserName;
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    NSString *sql = [NSString stringWithFormat:@"UPDATE XmppCur SET isread=1 WHERE username='%@' %@ AND mesto='%@' and type='%@' and isread=0",username,usage,roser,type];
    [self excuteSql:sql];
    
}
/**
 *  删除与指定用户的聊天记录
 *
 *  @param roser
 *
 *  @return 成功与否
 */

-(BOOL)deleteChatHistryWithRoser:(NSString *)roser type:(NSString*)type isServer:(BOOL)server{
    
    NSString *username = kCurUserName;
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    __block BOOL success = false;
    [queue inDatabase:^(FMDatabase *db) {
        NSString *jid = [self getJID:[XmppListenerManager sharedManager].xmppStream.myJID.user];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM XmppCur WHERE 1 = 1 AND username='%@' %@ AND ((mesfrom='%@' AND mesto='%@') OR (mesfrom='%@' AND mesto='%@')) AND type='%@'",username,usage,roser,jid,jid,roser,type];
       success = [db executeUpdate:sql withArgumentsInArray:nil];
        
    }];
    return success;
    
}

/**
 *  获取与指定用户未读消息
 *
 *  @param roser roser
 *
 *  @return 未读消息列表
 */

-(NSArray *)getUnreadMessagesWithRoser:(NSString *)roser type:(NSString *)type isServer:(BOOL)server{
    
    NSMutableArray *datas = [NSMutableArray new];
    NSString *username = kCurUserName;
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    __block NSMutableArray *jsons = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *jid = [self getJID:[XmppListenerManager sharedManager].xmppStream.myJID.user];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppCur WHERE 1 = 1 AND username='%@' %@ and type='%@' and mesfrom='%@' and mesto='%@'",username,usage,type,roser,jid];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
    }];
    for (NSDictionary *json in jsons) {
        ChatMessageEntity *message = [ChatMessageEntity buildInstanceByJson:json];
        [datas addObject:message];
    }
    return datas;
    
}

/**
 *  messageType
 *
 *  @param string message
 *
 *  @return type
 */

- (SOMessageType)messageTypeFromString:(NSString *)string
{
    
    if ([string isEqualToString:@"img"]) {
        return SOMessageTypePhoto;
    } else if ([string isEqualToString:@"video"]) {
        return SOMessageTypeVideo;
    }else if([string isEqualToString:@"audio"]){
        return SOMessageTypeAudio;
    }else{
        return SOMessageTypeText;
    }

}

/**
 *  保存消息
 *
 *  @param message 消息
 */

-(NSInteger)storeMessage:(ChatMessageEntity*)message{
    
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    __block NSInteger lastId = 0;
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"INSERT INTO XmppCur(username, mesfrom, mesto, type, usagetype, content, time, isread, isHideFailureImage) VALUES (?,?,?,?,?,?,?,?,?)";
        BOOL result = [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
        if (!result){
            result = [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
            if (!result) {
                NSString *dropSql = [NSString stringWithFormat:@"DROP TABLE %@",[self tableName]];
                BOOL complite = [db executeUpdate:dropSql];
                complite = [db executeUpdate: [self sqlForCreateTable]];
                complite = [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
            }
        }
        lastId  = (NSInteger)[db lastInsertRowId];
    }];
    return lastId;
  
}

/**
 *   获取所有字段存到数据库的值
 *
 *  @param parameters:ChatMessageEntity
 *
 *  @return params
 */

-(NSArray *) parameters:(ChatMessageEntity*)message{
    NSLog(@"%d",message.souceType);
    
    /**
     *
     *  @param username  用户名
     *  @param from      发送者
     *  @param to        接受者
     *  @param type      类型群发、客服、单独聊天
     *  @param content   内容
     *  @param time      时间
     *  @param isread    是否已读
     *  @param isHideFailureImage 是否发送成功
     */


    NSArray*paras = nil;
    NSLog(@"message.isHideFailureImage====%@",message.isHideFailureImage);
    NSLog(@"message====%@",message);
    NSLog(@"message.contentJson====%@",message.contentJson);

    if (message.isHideFailureImage==nil || message.from==nil ||message.contentJson == nil || message.time == nil) {
        if (message.isHideFailureImage == nil) {
            message.isHideFailureImage = @"1";
  
        }else if(message.from == nil){
        
            return paras;;

        }else if(message.contentJson == nil){

            return paras;
        }else if(message.time == nil){
        
        return paras;
        }
        NSLog(@"message.tim===%@",message.time);
        NSArray *para = @[
                          kCurUserName,
                          message.from,
                          message.to,
                          message.type,
                          message.useagetype,
                          message.contentJson,
                          message.time,
                          [NSNumber numberWithBool:message.isRead],
                          message.isHideFailureImage
                          ];
        CRLog(@"%@",paras);
        paras = para;
        
    }else{
        NSArray *para = @[
                          kCurUserName,
                          message.from,
                          message.to,
                          message.type,
                          message.useagetype,
                          message.contentJson,
                          message.time,
                          [NSNumber numberWithBool:message.isRead],
                          message.isHideFailureImage
                          ];
        CRLog(@"%@",paras);
        paras = para;
        
        
    }
    return paras;
    
}
-(NSString *)getJID:(NSString *)JID{
    
    NSRange range = [JID rangeOfString:@"|"];
    if (range.location!=NSNotFound) {
        
        return [JID substringFromIndex:JID.length>0?range.location+1:0];
    }
    return JID;
}
@end
