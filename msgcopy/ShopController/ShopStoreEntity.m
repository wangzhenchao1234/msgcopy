//
//  ShopStoreEntity.m
//  Kaoke
//
//  Created by Gavin on 15/3/10.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "ShopStoreEntity.h"

@implementation ShopStoreEntity

+(instancetype)buildWithJson:(NSDictionary*)json
{
    ShopStoreEntity *entity = [[ShopStoreEntity alloc] init];
    NSString *streatStr = [Utility dictionaryValue:json forKey:@"streetaddr"];
    if (streatStr) {
        entity.streetaddr = [NSJSONSerialization JSONObjectWithData:[streatStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
    entity.ctime = [Utility dictionaryValue:json forKey:@"ctime"];
    entity.descr = [Utility dictionaryValue:json forKey:@"descr"];
    entity.title = [Utility dictionaryValue:json forKey:@"title"];
    entity.sid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    NSDictionary *appInfo = [Utility dictionaryValue:json forKey:@"app"];
    if (appInfo) {
        entity.app = [MSGAppEntity buildByJson:appInfo];
    }
    
    NSDictionary *master = [Utility dictionaryValue:json forKey:@"master"];
    if (master) {
        entity.master = [UserEntity buildInstanceByMasterJson:master];
    }
    
    NSString *position = [Utility dictionaryValue:json forKey:@"position"];
    if (position) {
        NSDictionary *location = [NSJSONSerialization JSONObjectWithData:[position dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        entity.lat = location[@"lat"];
        entity.lng = location[@"lng"];
    }
    NSDictionary *thumnail = [Utility dictionaryValue:json forKey:@"thumbnail"];
    entity.thumbnail = [ThumbnailEntity buildInstanceByJson:thumnail];
    return entity;
}
@end
