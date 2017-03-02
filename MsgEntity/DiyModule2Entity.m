//
//  DiyListEntity.m
//  Kaoke
//
//  Created by wngzc on 14/12/2.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "DiyModule2Entity.h"

@implementation DiyModule2Entity

+(DiyModule2Entity*)buildByJson:(NSDictionary *)json{
    
    DiyModule2Entity *entity = [[DiyModule2Entity alloc] init];
    entity.kind = [Utility dictionaryValue:json forKey:@"kind"];
    entity.price = [Utility dictionaryValue:json forKey:@"price"];
    entity.text = [Utility dictionaryValue:json forKey:@"text"];
    entity.grid_position = [Utility dictionaryValue:json forKey:@"grid_position"];
    entity.bg_img = [Utility dictionaryValue:json forKey:@"bg_img"];
    entity.action = [Utility dictionaryValue:json forKey:@"action"];
    entity.type = [Utility dictionaryValue:json forKey:@"type"];
    entity.mid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    entity.descr = [Utility dictionaryValue:json forKey:@"descr"];
    entity.thumbnail = [Utility dictionaryValue:json forKey:@"thumbnail"];
    return entity;
}

@end
