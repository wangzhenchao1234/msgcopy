//
//  MessageEntity.m
//  Kaoke
//
//  Created by xiaogu on 14-3-4.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "MessageEntity.h"

@implementation MessageEntity

+(MessageEntity*)buildInstanceByJson:(NSDictionary*)json{
    
    NSString *contentStr = [Utility dictionaryValue:json forKey:@"content"];
    NSDictionary *messageJson = [[[SBJsonParser alloc] init] objectWithString:contentStr];
    MessageEntity *message = [[MessageEntity alloc] init];
    message.title          = [Utility dictionaryValue:messageJson forKey:@"title"];
    message.isclient       = [[Utility dictionaryValue:messageJson forKey:@"isclient"] boolValue];
    message.content        = [Utility dictionaryValue:messageJson forKey:@"content"];
    message.isRead         = [[Utility dictionaryValue:json forKey:@"isread"] boolValue];
    message.link           = [Utility dictionaryValue:messageJson forKey:@"link"];
    message.mid = [[Utility dictionaryValue:json forKey:@"mid"] integerValue];
    message.isall          = [[Utility dictionaryValue:messageJson forKey:@"isall"] boolValue];
    message.isadmin        = [[Utility dictionaryValue:messageJson forKey:@"isadmin"] boolValue];
    message.cTime = [NSString valueToDate:[Utility dictionaryValue:json forKey:@"date"]];
    NSDictionary *user = [Utility dictionaryValue:messageJson forKey:@"sender"];
    message.sender   = [UserEntity buildInstanceByMasterJson:user];
    return message;

}
@end
