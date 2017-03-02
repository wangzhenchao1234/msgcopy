//
//  ServerChatManager.m
//  Kaoke
//
//  Created by Gavin on 14/10/28.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "ServerChatManager.h"
#import "ChatServerEntity.h"

@implementation ServerChatManager

+(ServerChatManager*)sharedManager{
    
    static ServerChatManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerChatManager alloc] init];
        [manager loadCache];
    });
    return manager;
    
}
-(void)loadCache{
    
    NSArray *groups =  [LocalManager objectForKey:@"servers_json"];
    NSMutableArray *groupEntities = [NSMutableArray new];
    for (NSDictionary *json in groups) {
        ChatServerEntity *server = [ChatServerEntity buildByinstans:json];
        [groupEntities addObject:server];
    }
    if (groupEntities.count > 0) {
        [_serverGroups addObjectsFromArray:groupEntities];
    }
    
}
-(void)refresh{
    
    [MSGRequestManager Get:KAPIServerGroup params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
    {
        [LocalManager storeObject:data forKey:@"servers_json"];
        NSMutableArray *groupEntities = [NSMutableArray new];
        for (NSDictionary *json in data) {
            ChatServerEntity *server = [ChatServerEntity buildByinstans:json];
            [groupEntities addObject:server];
        }
        if (!_serverGroups) {
            _serverGroups = [NSMutableArray new];
        }
        [_serverGroups removeAllObjects];
        [_serverGroups addObjectsFromArray:groupEntities];
        [groupEntities removeAllObjects];
        groupEntities = nil;
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
        [CustomToast showMessageOnWindow:msg];
    }];
}

@end
