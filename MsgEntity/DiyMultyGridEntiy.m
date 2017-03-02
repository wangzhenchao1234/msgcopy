//
//  DiyMultyGridEnty.m
//  Kaoke
//
//  Created by Gavin on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "DiyMultyGridEntiy.h"

@implementation DiyMultyGridEntiy
+(DiyMultyGridEntiy*)buildByJson:(NSDictionary*)json
{
    DiyMultyGridEntiy *entity = [[DiyMultyGridEntiy alloc] init];
    entity.rows = [[Utility dictionaryValue:json forKey:@"rows"] integerValue];
    entity.columns = [[Utility dictionaryValue:json forKey:@"columns"] integerValue];
    entity.bg_img = [Utility dictionaryValue:json forKey:@"bg_img"];
    entity.type = [Utility dictionaryValue:json forKey:@"type"];
    entity.position = [Utility dictionaryValue:json forKey:@"position"];
    entity.bg_color = [Utility dictionaryValue:json forKey:@"bg_color"];
    entity.padding = [Utility dictionaryValue:json forKey:@"padding"];
    entity.controls = [NSMutableArray new];
    NSArray *controls = [Utility dictionaryValue:json forKey:@"controls"];
    for (NSDictionary *control in controls) {
        NSString *type = [Utility dictionaryValue:control forKey:@"type"];

        if ([type isEqualToString:@"Grid"]) {
            
            DiyMultyGridEntiy *item = [DiyMultyGridEntiy buildByJson:control];
            [entity.controls addObject:item];
            
        }else if ([type isEqualToString:@"Module"]) {
            
            DiySingleGridEntity *item = [DiySingleGridEntity buildByJson:control];
            [entity.controls addObject:item];
            
        }else if ([type isEqualToString:@"Module2"]) {
            
            DiyModule2Entity *item = [DiyModule2Entity buildByJson:control];
            [entity.controls addObject:item];
            
        }else if([type isEqualToString:@"Banner"]){
            DiyBannerEntity *item = [DiyBannerEntity buildByJson:control];
            [entity.controls addObject:item];
        }else if([type isEqualToString:@"LeafContent"]){
            DiyLeafContentEntity *item = [DiyLeafContentEntity buildByJson:control];
            [entity.controls addObject:item];
        }
    }
    return entity;

}
@end
