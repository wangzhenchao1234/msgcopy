//
//  MCenterManager.m
//  msgcopy
//
//  Created by Gavin on 15/7/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MCenterManager.h"

#define PerPageCount 20

@interface MCenterManager()
@property(nonatomic,assign)BOOL isOnServer;
@property(nonatomic,retain)NSThread* curThread;
@property(nonatomic,assign)NSInteger curTaskId;
@property(nonatomic,retain)SBJsonWriter *jsonWriter;
@property(nonatomic,retain)NSDateFormatter *formatter;
@property(nonatomic,retain)NSDateFormatter *parserFormatter;

@end

@implementation MCenterManager
CRManager(MCenterManager);

- (instancetype)init
{
    self = [super init];
    if (self) {
        [MCenterManager initDatabase];
        _formatter =[[NSDateFormatter alloc] init];
        _parserFormatter =[[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _jsonWriter = [[SBJsonWriter alloc] init];
    }
    return self;
}

/**
 *  启动服务
 */

-(void)startService
{
    _isOnServer = true;
    _curTaskId = -1;
    _curTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self threadEnd:_curTaskId];
    }];
    _curThread = [[NSThread alloc] initWithTarget:self selector:@selector(treadAction:) object:nil];
    [_curThread start];
}

/**
 *  线程
 */
-(void)treadAction:(id)sender{
    
    [self excuteServer];
    [self threadEnd:_curTaskId];
}

/**
 * 服务
 */

-(void)excuteServer
{
    CRLog(@"server start");
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:MCTimeInterVal target:self selector:@selector(doEvent:) userInfo:nil repeats:true];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    do{
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:2];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:date];
        
    }while (_isOnServer);
    CRLog(@"server stop");
    [timer invalidate];
    timer = nil;
}

/**
 *  服务停止
 */
-(void)stopService
{
    
    _isOnServer = false;
}

/**
 *  状态
 */

-(BOOL)isOnService
{
    return _isOnServer;
}

/**
 *  线程结束
 */

-(void)threadEnd:(NSInteger)taskId
{
    [[UIApplication sharedApplication] endBackgroundTask:taskId];
}

/**
 *  接口请求
 */

-(void)updateMessages:(void(^)(BOOL finished,NSArray *result))complete
{
    __block NSString *currentTime = [_formatter stringFromDate:[MCenterManager getInternetDate]];
    __block NSString *userMCTime = CRString(@"%@_messages",kCurUserName);
    __block NSString *lastTime = CRUserObj(userMCTime);
    if (!lastTime) {
        NSArray *dateArray = [currentTime componentsSeparatedByString:@" "];
        lastTime = [dateArray[0] stringByAppendingString:@" 00:00:00"];
    }
    NSString *url = [kAPIMessages(lastTime) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    CRWeekRef(self);
    [MSGRequestManager Get:url params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
        if (CRJSONIsArray(data)) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *messageDict = obj;
                if (CRJSONIsDictionary(messageDict)) {
                    [__self insertMessage:messageDict];
                }
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:10];
                notification.repeatInterval = 0;
                notification.fireDate = pushDate;
                notification.soundName = UILocalNotificationDefaultSoundName;
                notification.alertBody = messageDict[@"title"];
                notification.userInfo = @{@"notify_message": [NSNumber numberWithInt:[messageDict[@"id"] integerValue]]};
                notification.alertAction = NSLocalizedString(@"确定", nil);
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                NSLog(@"收到推送：%@",messageDict[@"title"]);

            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessageNotification object:nil];
            CRUserSetObj(currentTime, userMCTime);
        }
        [self performSelectorOnMainThread:@selector(messageLog:) withObject:data waitUntilDone:false];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [self performSelectorOnMainThread:@selector(messageLog:) withObject:msg waitUntilDone:false];
    }];
}

/**
 *  log
 */

-(void)messageLog:(id)log
{
    CRLog(@"messages : \n%@",log);
}

/**
 *  所有消息
 */

-(NSArray*)messages
{
    FMDatabaseQueue *queue = [MCenterManager getSharedInstance];
    __block NSMutableArray *messages = [[NSMutableArray alloc] init];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *username = [NSString convertName:kCurUserName];
        NSString *baseSql = CRString(@"select * from %@ where 1=1 and username='%@' order by date desc",[MCenterManager tableName],username);
         FMResultSet *rs = [db executeQuery:baseSql];
        while ([rs next]) {
            NSDictionary *mes = [rs resultDictionary];
            MessageEntity *message = [MessageEntity buildInstanceByJson:mes];
            [messages addObject:message];
        };
        [rs close];
    }];
    return messages;
}

/**
 *  未读消息
 */
-(NSArray*)unReadMessages
{
    FMDatabaseQueue *queue = [MCenterManager getSharedInstance];
    __block NSMutableArray *messages = [[NSMutableArray alloc] init];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *username = [NSString convertName:kCurUserName];
        NSString *baseSql = CRString(@"select * from %@ where 1=1 and username='%@' and isread=0",[MCenterManager tableName],username);
        FMResultSet *rs = [db executeQuery:baseSql];
        while ([rs next]) {
            NSDictionary *mes = [rs resultDictionary];
            MessageEntity *message = [MessageEntity buildInstanceByJson:mes];
            [messages addObject:message];
        };
        [rs close];
    }];
    return messages;
}


/**
 *  按时间获取
 */

-(NSArray*)messagesAtDate:(NSDate*)date
{
    FMDatabaseQueue *queue = [MCenterManager getSharedInstance];
    __block NSMutableArray *messages = [[NSMutableArray alloc] init];
    id dateObj = [NSString dateToValue:date];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *username = [NSString convertName:kCurUserName];
        NSString *baseSql = CRString(@"select * from %@ where 1=1 and username='%@' and date=%@",[MCenterManager tableName],username,dateObj);
        FMResultSet *rs = [db executeQuery:baseSql];
        while ([rs next]) {
            NSDictionary *mes = [rs resultDictionary];
            MessageEntity *message = [MessageEntity buildInstanceByJson:mes];
            [messages addObject:message];
        };
        [rs close];
    }];
    return messages;
}

/**
 *   按页获取
 */

-(NSArray*)messagesForPage:(NSInteger)page
{
    FMDatabaseQueue *queue = [MCenterManager getSharedInstance];
    __block NSMutableArray *messages = [[NSMutableArray alloc] init];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *username = [NSString convertName:kCurUserName];
        NSString *baseSql = CRString(@"select * from %@ where 1=1 and username='%@' order by date desc limit %d,%d",[MCenterManager tableName],username,0,page*PerPageCount);
        FMResultSet *rs = [db executeQuery:baseSql];
        while ([rs next]) {
            NSDictionary *mes = [rs resultDictionary];
            MessageEntity *message = [MessageEntity buildInstanceByJson:mes];
            [messages addObject:message];
        };
        [rs close];
    }];
    return messages;
}
/**
 *  插入一条数据
 *
 *  @param message message
 *
 *  @return id
 */
-(NSInteger)insertMessage:(NSDictionary*)message
{
    __block NSInteger lastID = 0;
    FMDatabaseQueue *queue = [MCenterManager getSharedInstance];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *baseSql = CRString(@"INSERT INTO %@ %@",[MCenterManager tableName],@"(%@) VALUES (%@)");
        NSString *insertFields = @"username, date, content,mid,isread";
        NSString *insertValues = @"?,?,?,?,?";
        NSString *sql  = [NSString stringWithFormat: baseSql, insertFields, insertValues];
        BOOL result = [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
        if (!result){
            result = [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
            if (!result) {
                NSString *dropSql = [NSString stringWithFormat:@"DROP TABLE %@",[self parameters:message]];
                BOOL complite = [db executeUpdate:dropSql];
                complite = [db executeUpdate: [MCenterManager sqlForCreateTable]];
                complite = [db executeUpdate:sql withArgumentsInArray:[self parameters:message]];
            }
        }
        lastID  = (NSInteger)[db lastInsertRowId];
    }];
    return lastID;
}

/**
 *  删除一条
 */

-(BOOL)deleteMessageWithID:(NSInteger)mid
{
    FMDatabaseQueue *queue = [MCenterManager getSharedInstance];
    __block BOOL result = false;
    [queue inDatabase:^(FMDatabase *db) {
        NSString *baseSql = CRString(@"DELETE FROM %@ WHERE 1 = 1 and mid=%@",[MCenterManager tableName],@(mid));
        result = [db executeUpdate:baseSql withArgumentsInArray:nil];
    }];
    return result;
}
/**
 *  读一条
 */

-(BOOL)readMessageWithID:(NSInteger)mid
{
    FMDatabaseQueue *queue = [MCenterManager getSharedInstance];
    __block BOOL result = false;
    [queue inDatabase:^(FMDatabase *db) {
        NSString *baseSql = CRString(@"UPDATE %@ SET isread=1 WHERE mid=%d",[MCenterManager tableName],mid);
        result = [db executeUpdate:baseSql withArgumentsInArray:nil];
    }];
    return result;
}
/**
 *  读一条
 */

-(MessageEntity*)messageWithID:(NSInteger)mid
{
    FMDatabaseQueue *queue = [MCenterManager getSharedInstance];
    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:1];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *baseSql = CRString(@"select * from %@ where 1=1 and mid=%d",[MCenterManager tableName],mid);
        FMResultSet *rs = [db executeQuery:baseSql];
        while ([rs next]) {
            NSDictionary *mes = [rs resultDictionary];
            MessageEntity *message = [MessageEntity buildInstanceByJson:mes];
            [messages addObject:message];
        };
        [rs close];
    }];
    return CRArrayObject(messages, 0);
}

/**
 *  服务
 */

-(void)doEvent:(id)sender{
    [self updateMessages:nil];    
}

/**
 *  数据库操作队列
 *
 *  @return 队列
 */
+(FMDatabaseQueue *)getSharedInstance
{
    static FMDatabaseQueue *my_FMDatabaseQueue=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths     = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path     = [paths objectAtIndex:0];
        path               = [path stringByAppendingString:@"/Msgcopy.db"];
        my_FMDatabaseQueue = [[FMDatabaseQueue alloc] initWithPath:path];
    });
    return my_FMDatabaseQueue;
}


/**
 *  初始化database
 */
+(void) initDatabase{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path           = [path stringByAppendingString:@"/Msgcopy.db"];
    NSLog(@"消息中心数据库路径 = %@",path);
    FMDatabase *database    = [[FMDatabase alloc] initWithPath:path];
    database.traceExecution = YES;
    //建表
    if ([database open]) {
        [database executeUpdate: [self sqlForCreateTable]];
        [database close];
    }
    [MCenterManager setDBVersion:@"1.0"];
    
}
/**
 *  表名
 */

+(NSString *)tableName{
    
    return @"Messages";
    
}

/**
 *  版本号
 *
 *  @return 版本号
 */
+(CGFloat)sqlVersion{
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *verionStr = [ud valueForKey:@"messages_version"];
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
+(void)setDBVersion:(NSString *)version{
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:version forKey:@"messages_version"];
    [ud synchronize];
    
}


/**
 *  建表语句
 *
 *  @return 建表语句
 */
+(NSString *) sqlForCreateTable{
    
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
    return [NSString stringWithFormat:@"CREATE TABLE if not exists Messages(id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,username TEXT,date FLOAT,content TEXT,mid INTEGER,isread boolean)"];
}
//获取所有字段存到数据库的值
-(NSArray *) parameters:(NSDictionary*)message{
    NSString *content = [_jsonWriter stringWithObject:message];
    NSString *time = [Utility dictionaryValue:message forKey:@"ctime"];
    time = [time stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDate *date = [_formatter dateFromString:time];
    NSString *username = [NSString convertName:kCurUserName];
    NSInteger mid = [[Utility dictionaryValue:message forKey:@"id"] integerValue];
    return @[
             [NSString valueToString:username],
             [NSString dateToValue:date],
             [NSString valueToString:content],
             [NSNumber numberWithInt:mid],
             [NSNumber numberWithBool: false],
            ];
}
/**
 
 *  获取网络当前时间
 
 */

+ (NSDate *)getInternetDate

{
    
    NSString *urlString = @"http://m.baidu.com";
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    // 实例化NSMutableURLRequest，并进行参数配置
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString: urlString]];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    [request setTimeoutInterval: 2];
    
    [request setHTTPShouldHandleCookies:FALSE];
    
    [request setHTTPMethod:@"GET"];
    
    NSError *error = nil;
    
    NSHTTPURLResponse *response;
    
    [NSURLConnection sendSynchronousRequest:request
     
                          returningResponse:&response error:&error];
    
    
    
    // 处理返回的数据
    
    //    NSString *strReturn = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    if (error) {
        return [NSDate date];
    }
    
    NSLog(@"response is %@",response);
    
    NSString *date = [[response allHeaderFields] objectForKey:@"Date"];
    
    date = [date substringFromIndex:5];
    
    date = [date substringToIndex:[date length]-4];
    
    NSDateFormatter *dMatter = [[NSDateFormatter alloc] init];
    
    dMatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    [dMatter setDateFormat:@"dd MMM yyyy HH:mm:ss"];
    
    
    
    NSDate *netDate = [[dMatter dateFromString:date] dateByAddingTimeInterval:60*60*8];
    
    return netDate;
    
}

+(void)sendApplyToadmin:(NSString*)title content:(NSString *)content success:(requestComplete)success failed:(requestComplete)failed{
    
    NSDictionary *params = @{
                             @"title":title,
                             @"content":content
                             };
    [MSGRequestManager MKPost:kAPISendMessage params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
    }];
    
}


@end
