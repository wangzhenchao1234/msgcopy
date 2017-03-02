//
//  MediaEntity.m
//  msgcopy
//
//  Created by Gavin on 15/4/21.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MediaEntity.h"

@implementation MediaEntity

+(instancetype) buildInstanceByJson:(NSDictionary*)json
{
    MediaEntity* media = [[MediaEntity alloc] init];
    [media setMid:[[json valueForKey:@"id"] integerValue]];
    [media setTitle:[json valueForKey:@"title"]];
    [media setCtime:[json valueForKey:@"ctime"]];
    [media setFType:[json valueForKey:@"ftype"]];
    [media setHtml:[json valueForKey:@"mediaHtml"]];
    [media setJsonStr:[[[SBJsonWriter alloc] init] stringWithObject:json]];
    NSDictionary* jsonDetail = [json valueForKey:@"mediaDetail"];
    if(jsonDetail!=nil)
    {
        [media setUrl:[jsonDetail valueForKey:@"url"]];
        [media setSize:[[jsonDetail valueForKey:@"size"] integerValue]];
    }
    return media;
}

@end
