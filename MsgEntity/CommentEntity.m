//
//  CommentEntity.m
//  msgcopy
//
//  Created by Gavin on 15/4/21.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "CommentEntity.h"

@implementation CommentEntity

+(instancetype)buildInstanceByJson:(NSDictionary*)json{
    
    CommentEntity* comment = [[CommentEntity alloc] init];
    comment.content                = [Utility dictionaryValue:json forKey:@"content"];
    comment.commenJson             = [[[SBJsonWriter alloc] init] stringWithObject:json];
    comment.cid                    = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    NSMutableString* ctime         = [Utility dictionaryValue:json forKey:@"ctime"];
    comment.cTime                  = [NSString getDateFromeString:ctime];
    
    NSMutableString* readtime      = [Utility dictionaryValue:json forKey:@"readtime"];
    comment.readTime               = [NSString getDateFromeString:readtime];
    
    NSDictionary*jsonProfile       = [Utility dictionaryValue:json forKey:@"master"];
    comment.master                 = [UserEntity buildInstanceByMasterJson:jsonProfile];
    
    NSDictionary* jsonUser         = [Utility dictionaryValue:json forKey:@"article"];
    comment.article                = [ArticleEntity buildInstanceByJson:jsonUser];
    
    comment.videos                 = [NSMutableArray new];
    comment.images                 = [NSMutableArray new];
    comment.audios                 = [NSMutableArray new];
    
    NSArray* videosJson            = [Utility dictionaryValue:json forKey:@"videos"];
    for (NSDictionary *videoJson in videosJson) {
        KaokeVideo *video = [KaokeVideo buildInstanceByJson:videoJson];
        [comment.videos addObject:video];
    }
    NSArray* imagesJson = [Utility dictionaryValue:json forKey:@"images"];
    for (NSDictionary *imageJson in imagesJson) {
        KaokeImage *image = [KaokeImage buildInstanceByJson:imageJson];
        [comment.images addObject:image];
    }
    NSArray *audiosJson = [Utility dictionaryValue:json forKey:@"audios"];
    [audiosJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        KaokeAudio *audio = [KaokeAudio buildInstanceByJson:obj];
        [comment.audios addObject:audio];
    }];
    return comment;
}

@end
