//
//  HistoryContentManager.m
//  Kaoke
//
//  Created by xiaogu on 14-8-15.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "HistoryContentManager.h"
#import "ChatMessageEntity.h"
#import <FMDB/FMDB.h>
#import "RoomChatEntity.h"
#import "XmppListenerManager.h"

@implementation HistoryContentManager
/**
 *  单例
 *
 *  @return 单例实例
 */
+ (HistoryContentManager *)sharedManager
{
    static HistoryContentManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
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
        [self registNotification];
    }
    return self;
    
}
-(CGFloat)sqlVersion{
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *verionStr = [ud valueForKey:@"xmpphis_version"];
    if (verionStr) {
        return [verionStr floatValue];
    }else{
        return 0;
    }
}
-(void)setVersion:(NSString *)version{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:version forKey:@"xmpphis_version"];
    [ud synchronize];
}
/**
 *  注册网络状态通知
 */
-(void)registNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataNotification:) name:kChatMessageNotification object:nil];
}
/**
 *  收到消息
 *
 *  @param notification 消息
 */
-(void)onDataNotification:(NSNotification*)notification{
    
    ChatMessageEntity *message = notification.object;
    if ([message isMemberOfClass:[ChatMessageEntity class]]) {
        if (![message.username isEqualToString:kCurUserName]) {
            return;
        }
        [self updateHistoryWithMessage:message];
    }
}
/**
 *  初始化database
 */
-(void) initDatabase{
    
    NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path               = [paths objectAtIndex:0];
    path                         = [path stringByAppendingString:@"/Msgcopy.db"];
    NSLog(@"ChatDBPath = %@",path);
    self.database                = [[FMDatabase alloc] initWithPath:path];
    //字段列表
    self.database.traceExecution = YES;
    //建表
    if ([self.database open]) {
        [self.database executeUpdate: [self sqlForCreateTable]];
        [self.database close];
    }
    [self setVersion:@"1.0"];
    [self refreshHistory];
    
}
-(NSString *)tableName{
    
    return @"XmppHis";
    
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
     *  @param mesfrom      发送者
     *  @param mesto        接受者
     *  @param type      类型群发、客服、单独聊天
     *  @param content   内容
     *  @param time      时间
     *  @param isread    是否已读
     *
     */
    return [NSString stringWithFormat:@"CREATE TABLE if not exists XmppHis(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,username TEXT,mesfrom TEXT,mesto TEXT,type TEXT,usagetype TEXT,content TEXT,time text,isread boolean,isHideFailureImage text)"];
    
}

/**
 *  获取所有字段存到数据库的值
 *
 *  @param message entity
 *
 *  @return 字段
 */

-(NSArray *) parameters:(ChatMessageEntity*)message{
    
    
    /**
     *
     *  @param username  用户名
     *  @param mesfrom      发送者
     *  @param mesto        接受者
     *  @param type      类型群发、客服、单独聊天
     *  @param content   内容
     *  @param time      时间
     *  @param isread    是否已读
     *
     */
    NSArray*paras = nil;
    if (message.from==nil || message.contentJson == nil || message.time == nil || message.isHideFailureImage == nil) {
        
        
        if(message.isHideFailureImage == nil){
        
        message.isHideFailureImage = @"1";
        
        }else if (message.from == nil) {
            return paras;

        }else if(message.contentJson == nil){
        
            return paras;
        }else if(message.time == nil){
        
           return paras;
        }
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
        paras = para;

    
    }
   
    return paras;
    
}
/**
 *  刷新
 */
-(NSArray *)refreshHistory{
    
    NSString *username = kCurUserName;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM XmppHis WHERE 1 = 1 AND username='%@' ORDER BY time DESC) GROUP BY mesfrom",username];
    _data = [[ContentManager sharedManager] getDataWithSql:sql parameters:nil];
    for (ChatMessageEntity *message in _data) {
        [self updateHistoryWithMessage:message];
    }
    return _data;
    
}

-(void)getAllRoomsComplete:(requestComplete)cmp{
    
    if (!_rooms) {
        _rooms = [NSMutableArray new];
    }
    NSLog(@"kAPIChatRoomList==========%@",kAPIChatRoomList);
    [MSGRequestManager Get:kAPIChatRoomList params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
     {
         if (CRJSONIsArray(data)) {
             NSMutableArray *newRooms = [NSMutableArray new];
             [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 NSDictionary *json = obj;
                 RoomChatEntity *entity = [RoomChatEntity buildByJson:json];
                 [newRooms addObject:entity];
             }];
             [_rooms removeAllObjects];
             [_rooms addObjectsFromArray:newRooms];
             [newRooms removeAllObjects];
             newRooms = nil;
         }
         [[XmppListenerManager sharedManager] connectToRooms];
         if (cmp) {
             cmp(nil,code,_rooms,requestURL);
         }
         
     } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
         if (cmp) {
             cmp(msg,code,_rooms,requestURL);
         }
         [_rooms removeAllObjects];
     }];
}

/**
 *  获取指定用户的聊天历史
 *
 *  @param roser 用户
 *
 *  @return 数据
 */
-(NSArray*)getAllServerHistoryWithRoser:(NSString*)roser isServer:(BOOL)server type:(NSString *)chatType{
    
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppHis WHERE 1 = 1 AND username='%@' %@ AND  type='%@' ORDER BY time DESC",roser,usage,chatType];
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    __block NSMutableArray *jsons = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
    }];
    NSMutableArray *messages = [NSMutableArray new];
    for (NSDictionary *message in jsons) {
        ChatMessageEntity *entity = [ChatMessageEntity buildInstanceByJson:message];
        [messages addObject:entity];
    }
    return messages;
}
/**
 *  获取指定用户的聊天历史
 *
 *  @param roser 用户
 *
 *  @return 数据
 */
-(NSArray*)getAllServerHistoryWithRoser:(NSString*)roser from:(NSString*)from to:(NSString*)to isServer:(BOOL)server type:(NSString *)chatType{
    
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppHis WHERE 1 = 1 AND username='%@' %@AND  type='%@' AND  mesfrom='%@' AND mesto='%@' ORDER BY time DESC",roser,usage,chatType,from,to];
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    __block NSMutableArray *jsons = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
    }];
    NSMutableArray *messages = [NSMutableArray new];
    for (NSDictionary *message in jsons) {
        ChatMessageEntity *entity = [ChatMessageEntity buildInstanceByJson:message];
        [messages addObject:entity];
    }
    return messages;
    
}
/**
 *  获取指定用户的聊天历史
 *
 *  @param roser 用户
 *
 *  @return 数据
 */
-(NSArray*)getAllhistoryWithRoser:(NSString*)roser isServer:(BOOL)server type:(NSString *)chatType{
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    __block NSMutableArray *messages = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppHis WHERE 1 = 1 AND username='%@' %@ AND  type='%@' ORDER BY time DESC",roser,usage,chatType];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            NSDictionary *rst = [rs resultDictionary];
            ChatMessageEntity *message = [ChatMessageEntity buildInstanceByJson:rst];
            [messages addObject:message];
        };
        [rs close];
    }];
    return messages;
    
}
/**
 *  更新最新消息
 *
 *  @param message 消息
 *  @param type    消息模式
 */
-(void)updateHistoryWithMessage:(ChatMessageEntity *)message{
    
    NSString *type = message.type;
    if ([type isEqualToString:@"groupchat"]) {
        [self updateGroupHistoryWithMessage:message];
        return;
    }
    NSString *username = kCurUserName;
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    
    __block NSMutableArray *jsons = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppHis WHERE 1 = 1 and type='%@' and username='%@' and usagetype='%@' and ((mesfrom='%@' and mesto='%@') OR (mesfrom='%@' and mesto='%@'))",type,username,message.useagetype,message.from,message.to,message.to,message.from];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
        if (jsons.count>0) {
            NSString *sql = [NSString stringWithFormat:@"UPDATE XmppHis SET mesfrom='%@', mesto='%@', content='%@', time='%@', type='%@',usagetype='%@' WHERE id=%d",message.from,message.to,message.contentJson,message.time,message.type,message.useagetype,[[jsons[0] valueForKeyPath:@"id"] integerValue]];
            BOOL result = [db executeUpdate:sql withArgumentsInArray:nil];
            if (!result) {
                result = [db executeUpdate:sql withArgumentsInArray:nil];
                if (!result) {
                    NSString *dropSql = [NSString stringWithFormat:@"DROP TABLE %@",[self tableName]];
                    [db executeQuery:dropSql withArgumentsInArray:nil];
                    [db executeUpdate: [self sqlForCreateTable]];
                    NSString *sql  = [[NSString stringWithFormat:@"INSERT INTO XmppHis"] stringByAppendingString:@"(%@) VALUES (%@)"];
                    NSString *insertFields = @"username, mesfrom, mesto, type, usagetype, content, time, isread, isHideFailureImage";
                    NSString *insertValues = @"?,?,?,?,?,?,?,?,?";
                    sql = [NSString stringWithFormat: sql, insertFields, insertValues];
                    [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
                }
            }
            
        }else{
            
            NSString *sql  = [[NSString stringWithFormat:@"INSERT INTO XmppHis"] stringByAppendingString:@"(%@) VALUES (%@)"];
            NSString *insertFields = @"username, mesfrom, mesto, type, usagetype, content, time, isread, isHideFailureImage";
            NSString *insertValues = @"?,?,?,?,?,?,?,?,?";
            sql = [NSString stringWithFormat: sql, insertFields, insertValues];
            BOOL result = [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
            if (!result) {
                result = [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
                if (!result) {
                    NSString *dropSql = [NSString stringWithFormat:@"DROP TABLE %@",[self tableName]];
                    [db executeQuery:dropSql withArgumentsInArray:nil];
                    [db executeUpdate: [self sqlForCreateTable]];
                    NSString *sql  = [[NSString stringWithFormat:@"INSERT INTO XmppHis"] stringByAppendingString:@"(%@) VALUES (%@)"];
                    NSString *insertFields = @"username, mesfrom, mesto, type, usagetype, content, time, isread, isHideFailureImage";
                    NSString *insertValues = @"?,?,?,?,?,?,?,?,?";
                    sql = [NSString stringWithFormat: sql, insertFields, insertValues];
                    [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
                }
            }
        }
        
    }];
    
}
-(void)updateGroupHistoryWithMessage:(ChatMessageEntity*)message
{
    NSString *type = message.type;
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    
    __block NSMutableArray *jsons = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM XmppHis WHERE 1 = 1 and type='%@' and username='%@' and usagetype='%@' and  mesto='%@'",type,kCurUserName,message.useagetype,message.to];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
        
        if (jsons.count>0) {
            NSString *sql = [NSString stringWithFormat:@"UPDATE XmppHis SET mesfrom='%@', mesto='%@', content='%@', time='%@', type='%@', usagetype='%@' WHERE id=%d",message.from,message.to,message.contentJson,message.time,message.type,message.useagetype,[[jsons[0] valueForKeyPath:@"id"] integerValue]];
            BOOL result = [db executeUpdate:sql withArgumentsInArray:nil];
            if (!result) {
                result = [db executeUpdate:sql withArgumentsInArray:nil];
                if (!result) {
                    NSString *dropSql = [NSString stringWithFormat:@"DROP TABLE %@",[self tableName]];
                    [db executeQuery:dropSql withArgumentsInArray:nil];
                    [db executeUpdate: [self sqlForCreateTable]];
                    NSString *sql  = [[NSString stringWithFormat:@"INSERT INTO XmppHis"] stringByAppendingString:@"(%@) VALUES (%@)"];
                    NSString *insertFields = @"username, mesfrom, mesto, type, usagetype, content, time, isread, isHideFailureImage";
                    NSString *insertValues = @"?,?,?,?,?,?,?,?,?";
                    sql = [NSString stringWithFormat: sql, insertFields, insertValues];
                    [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
                }
            }
            
        }else{
            
            NSString *sql  = [[NSString stringWithFormat:@"INSERT INTO XmppHis"] stringByAppendingString:@"(%@) VALUES (%@)"];
            NSString *insertFields = @"username, mesfrom, mesto, type, usagetype, content, time, isread, isHideFailureImage";
            NSString *insertValues = @"?,?,?,?,?,?,?,?,?";
            sql = [NSString stringWithFormat: sql, insertFields, insertValues];
            BOOL result = [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
            if (!result) {
                result = [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
                if (!result) {
                    NSString *dropSql = [NSString stringWithFormat:@"DROP TABLE %@",[self tableName]];
                    [db executeQuery:dropSql withArgumentsInArray:nil];
                    [db executeUpdate: [self sqlForCreateTable]];
                    NSString *sql  = [[NSString stringWithFormat:@"INSERT INTO XmppHis"] stringByAppendingString:@"(%@) VALUES (%@)"];
                    NSString *insertFields = @"username, mesfrom, mesto, type, usagetype, content, time, isread, isHideFailureImage";
                    NSString *insertValues = @"?,?,?,?,?,?,?,?,?";
                    sql = [NSString stringWithFormat: sql, insertFields, insertValues];
                    [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
                }
            }        }
        
    }];
    
}
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
/**
 *  删除与指定用户的聊天记录
 *
 *  @param roser
 *
 *  @return 成功与否
 */
-(BOOL)deleteChatHistryWithRoser:(NSString *)roser isServer:(BOOL)server type:(NSString*)type{
    
    if ([type isEqualToString:@"groupchat"]) {
        return [self deleteGroupChatHistryWithRoser:roser isServer:server type:type];
    }
    
    NSString *username = kCurUserName;
    NSString *realUser = [self convertName:username];
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM XmppHis WHERE 1 = 1 AND username='%@' %@ AND ((mesfrom='%@' AND mesto='%@') OR (mesfrom='%@' AND mesto='%@')) AND type='%@'",username,usage,roser,realUser,realUser,roser,type];
        [db executeUpdate:sql withArgumentsInArray:nil];
    }];
    return [[ContentManager sharedManager] deleteChatHistryWithRoser:roser type:type isServer:server];
}

-(BOOL)deleteGroupChatHistryWithRoser:(NSString *)roser isServer:(BOOL)server type:(NSString*)type{
    
    NSString *username = kCurUserName;
    NSString *usage = @"AND (usagetype='normal' OR usagetype='null') ";
    if (server) {
        usage = @"AND usagetype='service' ";
    }
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM XmppHis WHERE 1 = 1 AND username='%@' %@ AND mesto='%@' AND type='%@'",username,usage,roser,type];
        [db executeUpdate:sql withArgumentsInArray:nil];
    }];
    return [[ContentManager sharedManager] deleteChatHistryWithRoser:roser type:type isServer:server];
}


/**
 *  自定义语句
 *
 *  @param sql sql语句
 */

-(void)excuteSql:(NSString *)sql{
    
    FMDatabaseQueue * queue = [ContentManager getSharedInstance];
    [queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:sql withArgumentsInArray:nil];
        
    }];
    
}
@end
