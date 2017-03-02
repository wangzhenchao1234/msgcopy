//
//  PubEntity.m
//  msgcopy
//
//  Created by wngzc on 15/4/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "PubEntity.h"

@implementation PubEntity

+(instancetype)buildInstanceByRelJson:(NSDictionary*)json{
    
    PubEntity *publication = [[PubEntity alloc] init];
    publication.pid                     = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    NSString *idxString = nil;
    idxString          = [Utility dictionaryValue:json forKey:@"idx"];
    publication.descr                   = [Utility dictionaryValue:json forKey:@"descr"];
    NSDictionary *msgJson               = [Utility dictionaryValue:json forKey:@"article"];
    publication.article                 = [ArticleEntity buildInstanceByJson:msgJson];
    publication.article.pubid             = publication.pid;
    return publication;
    
}
+(instancetype)buildInstanceByJson:(NSDictionary*)json{
    
    PubEntity *publication = [[PubEntity alloc] init];
    NSString *utime          = [Utility dictionaryValue:json forKey:@"utime"];
    publication.uTime        = [NSString getDateFromeString:utime];
    NSString *ctime          = [Utility dictionaryValue:json forKey:@"ctime"];
    publication.cTime        = [NSString getDateFromeString:ctime];
    publication.push         = [[Utility dictionaryValue:json forKey:@"push"] boolValue];
    publication.pid          = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    NSString *idxString      = nil;
    idxString                = [Utility dictionaryValue:json forKey:@"idx"];
    publication.idx          = [NSString getDateFromeString:idxString];
    publication.approve_desc = [Utility dictionaryValue:json forKey:@"approve_desc"];
    publication.desrc        = [Utility dictionaryValue:json forKey:@"descr"];
    NSDictionary *msgJson    = [Utility dictionaryValue:json forKey:@"article"];
    publication.article      = [ArticleEntity buildInstanceByJson:msgJson];
    publication.lid          = [[Utility dictionaryValue:json forKey:@"limb_id"] integerValue];
    publication.leafId       = [[Utility dictionaryValue:json forKey:@"leaf_id"] integerValue];
    return publication;
}
-(void)getPubRel:(requestComplete)success failed:(requestComplete)failed{
    
    [MSGRequestManager Get:kAPIPubRel(self.pid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSArray *datas = data[@"pubrels"];
        NSMutableArray *pubRels = [[NSMutableArray alloc] init];
        for (NSDictionary *pubDic in datas) {
            NSDictionary *pubJson = [pubDic valueForKey:@"pub"];
            PubEntity *pub = [PubEntity buildInstanceByRelJson:pubJson];
            pub.pubrelTitle = [pubDic valueForKey:@"descr"];
            [pubRels addObject:pub];
        }
        self.pubrels = pubRels;
        SBJsonWriter *writer = [[SBJsonWriter alloc] init];
        self.pubRelJson =  [writer stringWithObject:data];
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        failed(msg,code,data,requestURL);
        CRLog(@"获取相关投稿失败");
    }];

}

@end
