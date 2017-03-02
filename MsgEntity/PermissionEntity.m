//
//  PermissionEntity.m
//  msgcopy
//
//  Created by Gavin on 15/4/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "PermissionEntity.h"

@implementation OldPermissionEntity

+(instancetype)buildInstanceByJson:(NSDictionary*)json{
    // login_switch
    // 1能进
    // 0不能进
    OldPermissionEntity *entity = [[OldPermissionEntity alloc] init];
    entity.login_switch = [[Utility dictionaryValue:json forKey:@"login"] boolValue];
    entity.leafs = [Utility dictionaryValue:json forKey:@"leafs"];
    return entity;
    
}
@end

@implementation PermissionEntity

+(instancetype)buildWithJson:(NSDictionary*)json
{
    PermissionEntity *permission = [[PermissionEntity alloc] init];
    NSDictionary *func = [Utility dictionaryValue:json forKey:@"permissionfunc"];
    permission.pread = [[Utility dictionaryValue:func forKey:@"pread"] boolValue];
    permission.pcreate = [[Utility dictionaryValue:func forKey:@"pcreate"] boolValue];
    permission.pupdate = [[Utility dictionaryValue:func forKey:@"pupdate"] boolValue];
    permission.pdelete = [[Utility dictionaryValue:func forKey:@"pdelete"] boolValue];
    permission.title = [Utility dictionaryValue:json forKey:@"title"];
    permission.descr = [Utility dictionaryValue:json forKey:@"descr"];
    permission.systitle = [Utility dictionaryValue:json forKey:@"systitle"];
    permission.pid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    
    return permission;
}
@end
