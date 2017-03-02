//
//  LocalManager.m
//  Tushuo
//
//  Created by wngzc on 15/3/24.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "LocalManager.h"

@implementation LocalManager
+(void)storeObject:(id)obj forKey:(NSString*)key
{
    NSData *data = [[[SBJsonWriter alloc] init] dataWithObject:obj];
    CRUserSetObj(data, key);
}
+(id)objectForKey:(NSString*)key
{
    NSData *data = CRUserObj(key);
    if (data) {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            return result;
        }
    }
    return nil;
}
@end
