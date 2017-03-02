//
//  RoomChatEntity.m
//  Kaoke
//
//  Created by wngzc on 14/12/25.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "RoomChatEntity.h"

@implementation RoomChatEntity
+(instancetype)buildByJson:(NSDictionary*)json{
    
    RoomChatEntity *group = [[RoomChatEntity alloc] init];
    group.c_time = [Utility dictionaryValue:json forKey:@"c_time"];
    group.c_user = [Utility dictionaryValue:json forKey:@"c_user"];
    group.title = [Utility dictionaryValue:json forKey:@"title"];
    group.roomname = [Utility dictionaryValue:json forKey:@"roomname"];
    group.headphoto = [Utility dictionaryValue:json forKey:@"headphoto"];
    
    NSString *status = [Utility dictionaryValue:json forKey:@"groupstatus"];
    if ([status isEqualToString:@"applied"]) {
        group.groupstatus = @"已加群";
    }else if ([status isEqualToString:@"applying"]) {
        group.groupstatus = @"申请中...";
    }else{
        group.groupstatus = @"未申请";
    }
    group.rid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    return group;
}
@end
