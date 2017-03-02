//
//  ThumbnailEntity.m
//  msgcopy
//
//  Created by Gavin on 15/4/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ThumbnailEntity.h"

@implementation ThumbnailEntity

+(instancetype)buildInstanceByJson:(NSDictionary*)json{
    if (json == nil) return nil;
    ThumbnailEntity *thumbnail = [[ThumbnailEntity alloc] init];
    thumbnail.tid                = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    thumbnail.turl               = [Utility dictionaryValue:json forKey:@"url"];
    return thumbnail;
}
-(void)copy:(ThumbnailEntity*)sender
{
    self.tid = sender.tid;
    sender.turl = sender.turl;
}
@end
