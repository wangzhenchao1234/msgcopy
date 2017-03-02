//
//  ChatServerEntity.m
//  Kaoke
//
//  Created by Gavin on 14/10/28.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "ChatServerEntity.h"

@implementation ChatServerEntity

+(ChatServerEntity *)buildByinstans:(NSDictionary*)json{
    
    ChatServerEntity *entity = [[ChatServerEntity alloc] init];
    entity.app_id = [[Utility dictionaryValue:json forKey:@"app"] integerValue];
    entity.title = [Utility dictionaryValue:json forKey:@"title"];
    entity.users = [NSMutableArray new];
    NSArray *users = [Utility dictionaryValue:json forKey:@"user"];
    for (NSDictionary *user in users) {
        ServerEntity *server = [ServerEntity buildByinstans:user];
        [entity.users addObject:server];
    }
    return entity;
    
}
@end

@implementation ServerEntity

+(ServerEntity *)buildByinstans:(NSDictionary*)json{
    
    ServerEntity *server = [[ServerEntity alloc] init];
    server.cs_name = [Utility dictionaryValue:json forKey:@"cs_name"];
    server.descr = [Utility dictionaryValue:json forKey:@"descr"];
    server.username = [Utility dictionaryValue:json forKey:@"user"];
    NSString *userName = server.username;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [server getProfile:userName];
    });
    server.cs_group = [Utility dictionaryValue:json forKey:@"cs_group"];
    server.uid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    return server;
    
}

-(void)getProfile:(NSString *)username{
    
//    KaokeContactEntity *contact = [[KaokeContactEntity alloc] init];
//    contact.userName = username;
//    contact.phone = username;
//    ServiceData *data = [ServerService getProfileByContact:contact];
//    if ([ServerServiceUtil isSuccess:data]) {
//        self.headicon = contact.head100;
//    }
    
}

@end