//
//  ArticleMediaEntity.m
//  msgcopy
//
//  Created by Gavin on 15/4/21.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ArticleMediaEntity.h"

@implementation ArticleMediaEntity

+(instancetype)buildInstanceByJson:(NSDictionary*)json{
    
    ArticleMediaEntity *entity = [[ArticleMediaEntity alloc] init];
    NSDictionary *dict = [json valueForKey:@"obj"];
    entity.url         = [dict valueForKey:@"url"];
    entity.aid         = [[json valueForKey:@"id"] integerValue];
    entity.descr       = [json valueForKey:@"descr"];
    entity.thumbnail   = [json valueForKey:@"thumbnail"];
    entity.type        = [json valueForKey:@"type"];
    return entity;
    
}
@end
