//
//  ShareEntity.m
//  msgcopy
//
//  Created by Gavin on 15/4/9.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ShareEntity.h"

@implementation ShareEntity
@synthesize master = _master;
+(ShareEntity*)buildInstanceByJson:(NSDictionary*)json{
    
    ShareEntity* shareEntity = [[ShareEntity alloc] init];
    shareEntity.sid               = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    
    NSMutableString* ctime        = [Utility dictionaryValue:json forKey:@"ctime"];
    shareEntity.cTime             = [NSString getDateFromeString:ctime];
    
    NSMutableString* utime        = [Utility dictionaryValue:json forKey:@"utime"];
    shareEntity.uTime             = [NSString getDateFromeString:utime];
    
    NSMutableString* readtime     = [Utility dictionaryValue:json forKey:@"readtime"];
    shareEntity.readTime          = [NSString getDateFromeString:readtime];
    
    NSDictionary* jsonMsg         = [json valueForKey:@"article"];
    shareEntity.article           = [ArticleEntity buildInstanceByJson:jsonMsg];
    
    NSDictionary* jsonMaster      = [Utility dictionaryValue:json forKey:@"master"];
    shareEntity.master            = [UserEntity buildInstanceByJson:jsonMaster];
    shareEntity.newComment        = NO;
    NSDictionary* jsonShareMaster = [Utility dictionaryValue:json forKey:@"op_master"];
    shareEntity.shareMaster       = [UserEntity buildInstanceByJson:jsonShareMaster];
    shareEntity.title             = shareEntity.article.title;
    return shareEntity;
}
@end
