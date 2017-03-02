//
//  Message.m
//  SOSimpleChatDemo
//
//  Created by Artur Mkrtchyan on 6/3/14.
//  Copyright (c) 2014 SocialOjbects Software. All rights reserved.
//

#import "ChatMessageEntity.h"
#import "NSDate+XMPPDateTimeProfiles.h"

@implementation ChatMessageEntity

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}
+(ChatMessageEntity*)buildInstanceByJson:(NSDictionary*)json{
    /*
     {
     content = "ni shi ben dan";
     id = 1;
     isread = true;
     mesfrom = "34|1234";
     mesto = "34|gushaokun";
     time = "2014-01-05";
     type = chat;
     useagetype = normal;
     username = 1234;
     }
     */
    ChatMessageEntity *message = [[ChatMessageEntity alloc] init];
    message.from = [Utility dictionaryNullValue:json forKey:@"mesfrom"];
    if ([message.from isEqualToString:kCurUser.userName]) {
        message.fromMe = true;
    }
    message.from = [NSString convertName:message.from];
    message.from = [message getJID:message.from];
    NSString *contentJson = [Utility dictionaryNullValue:json forKey:@"content"];
    NSDictionary *content = [[[SBJsonParser alloc] init] objectWithString:contentJson];
    if (CRJSONIsDictionary(content)) {
        message.avatar = [Utility dictionaryNullValue:content forKey:@"avatar"];
        message.extra = [Utility dictionaryNullValue:content forKey:@"extra"];
        message.useagetype = [Utility dictionaryNullValue:content forKey:@"usage_type"];
        message.sourceUrl = [Utility dictionaryNullValue:content forKey:@"url"];
        message.nickName = [Utility dictionaryNullValue:content forKey:@"nickname"];
        message.souceType = [message parseSourceType:[Utility dictionaryNullValue:content forKey:@"type"]];
        message.text = [Utility dictionaryNullValue:content forKey:@"content"];
        message.master = [Utility dictionaryValue:content forKey:@"username"];
    }else{
        message.avatar = @"null";
        message.extra = @"null";
        message.useagetype = @"null";
        message.sourceUrl = @"null";
        message.nickName = @"null";
        message.souceType = SOMessageTypeText;
    }
    if ([message.master length]==0) {
        message.master = message.from;
    }
    message.to = [Utility dictionaryNullValue:json forKey:@"mesto"];
    message.to = [NSString convertName:message.to];
    message.to = [message getJID:message.to];
    
    message.type = [Utility dictionaryNullValue:json forKey:@"type"];
    message.failed = false;
    message.username = [Utility dictionaryNullValue:json forKey:@"username"];
    message.username = [NSString convertName:message.username];
    message.username = [message getJID:message.username];
    message.time = [Utility dictionaryNullValue:json forKey:@"time"];
    id isread = [Utility dictionaryNullValue:json forKey:@"isread"];
    if (isread) {
        message.isRead = [isread boolValue];
    }else{
        message.isRead = false;
    }
    
    NSString*isHideFailureImage = [Utility dictionaryValue:json forKey:@"isHideFailureImage"];
    if (isHideFailureImage.length != 0 || ![isHideFailureImage isEqualToString:@"null"]) {
        message.isHideFailureImage = isHideFailureImage;
    }else{
        message.isHideFailureImage = @"1";
    
    }
    message.attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    return message;
    
}
+(ChatMessageEntity*)buildWithXml:(XMPPMessage*)message
{
    SBJsonParser *_jsonParser = [[SBJsonParser alloc] init];
    NSString *username = kCurUserName;
    NSString *content = message.body;
    ChatMessageEntity *entity = [[ChatMessageEntity alloc] init];
    NSDictionary *bodyDict = [_jsonParser objectWithString:content];
    entity.time = bodyDict[@"time"];
    entity.type = message.type;
    if ([message.type isEqualToString:@"groupchat"]) {
        NSString *usr = message.from.full;
        NSArray *names = [usr componentsSeparatedByString:@"@"];
        if (names.count>0) {
            entity.to = names[0];
        }else{
            entity.to = [ChatMessageEntity getJID:message.to.user];
        }
    }else{
        NSLog(@"%@,%@",message.to,message.to.user);
        entity.to = [ChatMessageEntity getJID:message.to.user];
    }
    entity.souceType = [ChatMessageEntity parseSourceType:bodyDict[@"type"]];
    entity.text = bodyDict[@"content"];
    entity.nickName =bodyDict[@"nickname"];
    entity.username = username;
    entity.avatar = bodyDict[@"avatar"];
    entity.extra = bodyDict[@"extra"];
    entity.sourceUrl = bodyDict[@"url"];
    entity.master = bodyDict[@"username"];
    entity.useagetype = bodyDict[@"usage_type"]?bodyDict[@"usage_type"]:@"normal";
    entity.isRead = false;
    entity.isHideFailureImage = bodyDict[@"isHideFailureImage"];
    entity.attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    entity.contentJson = content;
    NSString *user = message.from.resource;
    NSRange range = [user rangeOfString:@"|"];
    if (range.location < user.length) {
        user = [user substringFromIndex:range.location+1];
    }
    entity.from = user;
    return entity;
    
}
+(NSString *)getJID:(NSString *)JID{
    
    NSRange range = [JID rangeOfString:@"|"];
    if (range.location!=NSNotFound) {
        
        return [JID substringFromIndex:JID.length>0?range.location+1:0];
    }
    return JID;
}
-(SOMessageType)parseSourceType:(NSString *)type{
    if ([type isEqualToString:@"txt"]) {
        return SOMessageTypeText;
    }
    if ([type isEqualToString:@"audio"]) {
        return SOMessageTypeAudio;
    }
    if ([type isEqualToString:@"pic"]) {
        return SOMessageTypePhoto;
    }
    if ([type isEqualToString:@"video"]) {
        return SOMessageTypeVideo;
    }
    return SOMessageTypeOther;
}

+(SOMessageType)parseSourceType:(NSString *)type{
    if ([type isEqualToString:@"txt"]) {
        return SOMessageTypeText;
    }
    if ([type isEqualToString:@"audio"]) {
        return SOMessageTypeAudio;
    }
    if ([type isEqualToString:@"pic"]) {
        return SOMessageTypePhoto;
    }
    if ([type isEqualToString:@"video"]) {
        return SOMessageTypeVideo;
    }
    return SOMessageTypeOther;
}
/**
 *  获取20条个人聊天记录
 *
 *  @param roserJID
 *
 *  @return 数据
 */
-(void)setContentJson:(NSString *)contentJson{
    NSString *newText = [contentJson stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    _contentJson = newText;
}

-(NSString *)getJID:(NSString *)JID{
    
    NSRange range = [JID rangeOfString:@"|"];
    if (range.location!=NSNotFound) {
        
        return [JID substringFromIndex:JID.length>0?range.location+1:0];
    }
    return JID;
}
@end
