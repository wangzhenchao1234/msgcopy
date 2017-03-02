//
//  DiySingleGridEntity.m
//  Kaoke
//
//  Created by Gavin on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "DiySingleGridEntity.h" 

@implementation DiySingleGridEntity

+(instancetype)buildByJson:(NSDictionary*)json
{
    DiySingleGridEntity *entity = [[DiySingleGridEntity alloc] init];
    entity.hor_ico_align = [Utility dictionaryValue:json forKey:@"horizontal_icon_alignment"];
    entity.ver_ico_align = [Utility dictionaryValue:json forKey:@"vertical_icon_alignment"];
    entity.hor_tex_align = [Utility dictionaryValue:json forKey:@"horizontal_text_alignment"];
    entity.ver_tex_align = [Utility dictionaryValue:json forKey:@"vertical_text_alignment"];
    entity.bg_img = [Utility dictionaryValue:json forKey:@"bg_img"];
    entity.text = [Utility dictionaryValue:json forKey:@"text"];
    entity.font_size = [[Utility dictionaryValue:json forKey:@"font_size"] integerValue];
    entity.bg_color = [Utility dictionaryValue:json forKey:@"bg_color"];
    entity.action = [Utility dictionaryValue:json forKey:@"action"];
    entity.position = [Utility dictionaryValue:json forKey:@"position"];
    entity.grid_position = [Utility dictionaryValue:json forKey:@"grid_position"];
    entity.type = [Utility dictionaryValue:json forKey:@"type"];
    entity.gid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    NSDictionary *iconJson = [Utility dictionaryValue:json forKey:@"icon"];
    entity.icon = [DiyIcon buildByJson:iconJson];
    entity.padding = [Utility dictionaryValue:json forKey:@"padding"];
    entity.font_color = [Utility dictionaryValue:json forKey:@"font_color"];
    return entity;
}

@end
