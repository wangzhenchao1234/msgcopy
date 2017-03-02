//
//  CtypeModal.m
//  msgcopy
//
//  Created by wngzc on 15/4/13.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "CtypeModal.h"

@implementation CtypeModal
+(instancetype)buildInstanceByJson:(NSDictionary*)json{
    if (json == nil) return nil;
    CtypeModal *type   = [[CtypeModal alloc] init];
    type.title    = [Utility dictionaryValue:json forKey:@"title"];
    type.systitle = [Utility dictionaryValue:json forKey:@"systitle"];
    type.cid      = [[Utility dictionaryValue:json forKey:@"cid"] integerValue];
    return type;
    
}

@end
