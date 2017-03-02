//
//  LocalNotificationManager.m
//  msgcopy
//
//  Created by wngzc on 15/8/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "LocalNotificationManager.h"

@interface LocalNotificationManager()
@property(nonatomic,assign)BOOL isOnServer;
@property(nonatomic,retain)NSThread* curThread;
@property(nonatomic,assign)NSInteger curTaskId;
@property(nonatomic,retain)NSDateFormatter *formatter;
@property(nonatomic,retain)NSDateFormatter *parserFormatter;
@end

@implementation LocalNotificationManager
CRManager(LocalNotificationManager);

- (instancetype)init
{
    self = [super init];
    if (self) {
        _formatter =[[NSDateFormatter alloc] init];
        _parserFormatter =[[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return self;
}

/**
 *  启动服务
 */

-(void)startService
{
    _isOnServer = true;
    _curTaskId = -2;
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

-(void)updateNotifications:(void(^)(BOOL finished,NSArray *result))complete
{
    __block NSString *currentTime = [_formatter stringFromDate:[LocalNotificationManager getInternetDate]];
    __block NSString *userMCTime = @"push_time";
    __block NSString *lastTime = CRUserObj(userMCTime);
    if (!lastTime) {
        NSArray *dateArray = [currentTime componentsSeparatedByString:@" "];
        lastTime = [dateArray[0] stringByAppendingString:@" 00:00:00"];
    }
    NSString *url = [kAPIPushNotificatin(lastTime, currentTime) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [MSGRequestManager Get:url params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if (CRJSONIsArray(data)) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
            {
                NSDictionary *pub = obj;
                if (CRJSONIsDictionary(pub)) {
                    PubEntity *entity = [PubEntity buildInstanceByJson:pub];
                    NSArray * leafs = [PermissonManager sharedManager].oldPermission.leafs;
                    for (NSDictionary *item in leafs) {
                        NSString *leafId = [item valueForKey:@"leaf_id"];
                        if ([leafId integerValue] == entity.leafId) {
                            continue;
                        }
                    }
                    UILocalNotification *notification = [[UILocalNotification alloc] init];
                    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:10];
                    notification.repeatInterval = 0;
                    notification.fireDate = pushDate;
                    notification.soundName = UILocalNotificationDefaultSoundName;
                    PubEntity *pub = entity;
                    notification.alertBody = pub.article.title;
                    notification.userInfo = @{@"notify_pub": [NSNumber numberWithInt:pub.pid]};
                    notification.alertAction = NSLocalizedString(@"确定", nil);
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                    NSLog(@"收到推送：%@",entity.article.title);

                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPubeNotification object:nil];
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
 *  服务
 */

-(void)doEvent:(id)sender{
    [self updateNotifications:nil];
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
@end
