//
//  EmotionManager.m
//  Kaoke
//
//  Created by 谷少坤 on 13-10-10.
//
//

#import "EmotionManager.h"

@implementation EmotionManager
+(FMDatabaseQueue *)getSharedInstance
{
    static FMDatabaseQueue *my_FMDatabaseQueue=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"emotion" ofType:@"db"];
        my_FMDatabaseQueue           = [[FMDatabaseQueue alloc] initWithPath:path];
    });
    return my_FMDatabaseQueue;
}
+(NSArray*)emotions{
    
    FMDatabaseQueue * queue = [EmotionManager getSharedInstance];
    __block NSMutableArray *jsons = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = @"SELECT * FROM emotion WHERE 1 = 1";
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
    }];
    return jsons;
}
+(NSString *)emotionForKey:(NSString *)key
{
    FMDatabaseQueue * queue = [EmotionManager getSharedInstance];
    __block NSMutableArray *jsons = [NSMutableArray new];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM emotion WHERE 1 = 1 AND e_descr='%@'",key];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:nil];
        while ([rs next]) {
            [jsons addObject: [rs resultDictionary]];
        };
        [rs close];
    }];
    if (jsons.count>0) {
        if (CRJSONIsDictionary(jsons[0])) {
            return jsons[0][@"e_name"];
        }
    }
    return nil;
}
@end
