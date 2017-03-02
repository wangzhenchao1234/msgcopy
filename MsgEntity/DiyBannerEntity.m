//
//  DiyBannerEntity.m
//  Kaoke
//
//  Created by Gavin on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "DiyBannerEntity.h"

@implementation DiyBannerEntity

+(DiyBannerEntity*)buildByJson:(NSDictionary*)json
{
    DiyBannerEntity *entity = [[DiyBannerEntity alloc] init];
    entity.items = [Utility dictionaryValue:json forKey:@"items"];
    entity.interval = [[Utility dictionaryValue:json forKey:@"interval"] integerValue];
    entity.type = [Utility dictionaryValue:json forKey:@"type"];
    entity.bid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    entity.position = [Utility dictionaryValue:json forKey:@"position"];
    entity.padding = [Utility dictionaryValue:json forKey:@"padding"];
    entity.bg_color = [Utility dictionaryValue:json forKey:@"bg_color"];
    return entity;
}

@end
