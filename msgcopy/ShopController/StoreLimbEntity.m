//
//  StoreLimbEntity.m
//  Kaoke
//
//  Created by wngzc on 15/3/19.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "StoreLimbEntity.h"
/*
 "shopstore": {
 "id": 40
 },
 "descr": "",
 "title": "学校动态",
 "publications": [
 */
@implementation StoreLimbEntity
+(instancetype)buildWithJson:(NSDictionary *)json
{
    StoreLimbEntity *entity = [[StoreLimbEntity alloc] init];
    entity.storeID = [[[Utility dictionaryValue:json forKey:@"shopstore"] valueForKey:@"id"] integerValue];
    entity.descr = [Utility dictionaryValue:json forKey:@"descr"];
    entity.title = [Utility dictionaryValue:json forKey:@"title"];
    entity.lid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    NSArray *pubsJson = [Utility dictionaryValue:json forKey:@"publications"];
    entity.publications = [NSMutableArray new];
    [pubsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        PubEntity *pub = [PubEntity buildInstanceByJson:obj];
        [entity.publications addObject:pub];
        
    }];
    return entity;
    
}
@end
