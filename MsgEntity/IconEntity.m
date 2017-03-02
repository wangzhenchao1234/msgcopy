//
//  IconEntity.m
//  msgcopy
//
//  Created by wngzc on 15/4/13.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "IconEntity.h"

/**
 *  icon Model
 *
 *  @param json json数据
 *
 *  @return IconEntity
 */

@implementation IconEntity

+(instancetype)buildInstanceByJson:(NSDictionary *)json
{
    IconEntity *icon   = [[IconEntity alloc] init];
    icon.icid          = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    icon.normal_icon   = [Utility dictionaryValue:json forKey:@"normal_url"];
    icon.selected_icon = [Utility dictionaryValue:json forKey:@"selected_url"];
    icon.descr         = [Utility dictionaryValue:json forKey:@"descr"];
    return icon;
}

@end
@implementation DiyIcon

+(instancetype)buildByJson:(NSDictionary*)json
{
    DiyIcon *icon = [[DiyIcon alloc] init];
    icon.url = [Utility dictionaryValue:json forKey:@"url"];
    icon.width = [Utility dictionaryValue:json forKey:@"width"];
    icon.height = [Utility dictionaryValue:json forKey:@"height"];
    return icon;
}

@end
