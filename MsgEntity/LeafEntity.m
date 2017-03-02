//
//  LeafEntity.m
//  msgcopy
//
//  Created by wngzc on 15/4/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "LeafEntity.h"

@implementation LeafEntity
+(instancetype)buildInstanceByJson:(NSDictionary*)json{
    
    LeafEntity* leaf         = [[LeafEntity alloc] init];
    leaf.isInited = NO;
    NSDictionary *placeholderJson = [Utility dictionaryValue:json forKey:@"placeholder"];
    leaf.placeholder              = [leafPlaceholder buildInstanceByJson:placeholderJson];
    leaf.publications             = [NSMutableArray new];
    NSArray* publicationsJson     = [Utility dictionaryValue:json forKey:@"publications"];
    for (NSDictionary *publication in publicationsJson) {
        PubEntity *pub = [PubEntity buildInstanceByJson:publication];
        [leaf.publications addObject:pub];
    }
    leaf.hiddeen          = false;
    leaf.req_permission   = false;
    leaf.lid              = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    leaf.idx              = [[Utility dictionaryValue:json forKey:@"idx"] integerValue];
    leaf.readonly         = [[Utility dictionaryValue:json forKey:@"readonly"] boolValue];
    leaf.title            = [Utility dictionaryValue:json forKey:@"title"];
    leaf.descr            = [Utility dictionaryValue:json forKey:@"descr"];
    
    NSDictionary *type    = [Utility dictionaryValue:json forKey:@"ctype"];
    leaf.ctype            = [CtypeModal buildInstanceByJson:type];
    return leaf;
}
@end
@implementation LeafTop

@synthesize descr    = _descr;
@synthesize link     = _link;
@synthesize imageUrl = _imageUrl;
@synthesize pid      = _pid;

+(instancetype)buildInstanceByJson:(NSDictionary*)json{
    if (json == nil) return nil;
    LeafTop *leafTop = [[LeafTop alloc] init];
    leafTop.descr         = [Utility dictionaryValue:json forKey:@"descr"];
    leafTop.link          = [Utility dictionaryValue:json forKey:@"link"];
    leafTop.imageUrl      = [Utility dictionaryValue:json forKey:@"img_url"];
    leafTop.pid           = [[Utility dictionaryValue:json forKey:@"pid"] integerValue];
    return leafTop;
}
@end

@implementation leafPlaceholder
@synthesize imageUrl;
@synthesize lid;

+(instancetype)buildInstanceByJson:(NSDictionary*)json{
    
    leafPlaceholder *ph = [[leafPlaceholder alloc] init];
    ph.imageUrl        = [Utility dictionaryValue:json forKey:@"url"];
    ph.lid             = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    return ph;
}
@end
