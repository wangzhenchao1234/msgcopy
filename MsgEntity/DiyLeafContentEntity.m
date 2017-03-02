//
//  DiyLeafContentEntity.m
//  Kaoke
//
//  Created by Gavin on 14/12/3.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "DiyLeafContentEntity.h"

@implementation DiyLeafContentEntity
+(instancetype)buildByJson:(NSDictionary*)json{
    DiyLeafContentEntity *entity = [[DiyLeafContentEntity alloc] init];
    entity.lid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    entity.type = [Utility dictionaryValue:json forKey:@"type"];
    NSDictionary *leafJson = [Utility dictionaryValue:json forKey:@"leaf"];
    entity.leaf = [LeafEntity buildInstanceByJson:leafJson];
    return entity;
}
@end
