//
//  WebAppEntity.m
//  msgcopy
//
//  Created by wngzc on 15/4/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "WebAppEntity.h"

@implementation WebAppEntity

+(WebAppEntity*)buildInstanceByJson:(NSDictionary*)json{
    
    WebAppEntity *web  = [[WebAppEntity alloc] init];
    
    web.adv            = [Utility dictionaryValue:json forKey:@"adv"];
    web.descr          = [Utility dictionaryValue:json forKey:@"descr"];
    web.url            = [Utility dictionaryValue:json forKey:@"url"];
    web.title          = [Utility dictionaryValue:json forKey:@"title"];
    web.title_client   = [Utility dictionaryValue:json forKey:@"title_client"];
    if (!web.title_client) {
        web.title_client = [web.title copy];
    }
    web.aid            = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    web.systitle       = [Utility dictionaryValue:json forKey:@"systitle"];
    web.opType         = [[Utility dictionaryValue:json forKey:@"optype"] integerValue];
    web.isRequirelogin = [[Utility dictionaryValue:json forKey:@"requirelogin"] boolValue];
    web.isCommend      = [[Utility dictionaryValue:json forKey:@"iscommend"] boolValue];
    
    NSDictionary *logo = [Utility dictionaryValue:json forKey:@"logo"];
    web.icon           = [IconEntity buildInstanceByJson:logo];
    web.dropIcon       = [IconEntity buildInstanceByJson:logo];
    
    if ([web.systitle isEqualToString:@"map"]) {
        web.dropIcon.normal_icon = @"address";
        web.dropIcon.selected_icon = @"address";
    }else if ([web.systitle isEqualToString:@"tagfilter"]) {
        web.dropIcon.normal_icon = @"filter";
        web.dropIcon.selected_icon = @"filter";
    }
    else if ([web.systitle isEqualToString:@"search_leaf"]) {
        web.dropIcon.normal_icon = @"search";
        web.dropIcon.selected_icon = @"search";
    }else{
        web.dropIcon.normal_icon = @"app_default";
        web.dropIcon.selected_icon = @"app_default";
    }
    web.ctypes = [web parseCtypes:[json objectForKey:@"ctypes"]];
    return web;
}
-(NSMutableArray *)parseCtypes:(NSArray *)array{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (NSDictionary *ctype in array) {
        WebAppCtype *type = [WebAppCtype buildInstanceByJson:ctype];
        [newArray addObject:type];
    }
    return newArray;
}
@end
@implementation WebAppCtype
@synthesize systitle;
@synthesize title;
@synthesize wid;

+(WebAppCtype *)buildInstanceByJson:(NSDictionary *)json{
    WebAppCtype *type = [[WebAppCtype alloc] init];
    type.systitle = [Utility dictionaryValue:json forKey:@"systitle"];
    type.wid      = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    type.title    = [Utility dictionaryValue:json forKey:@"title"];
    return type;
}
@end