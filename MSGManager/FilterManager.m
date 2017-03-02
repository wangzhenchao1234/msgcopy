//
//  FilterManager.m
//  msgcopy
//
//  Created by wngzc on 15/7/11.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "FilterManager.h"

@implementation FilterManager
+(NSString*)curFilterName
{
    NSString *fName = CRUserObj(@"filter_name");
    if (!fName) {
        if ([FilterManager isValid]) {
            fName = [FilterManager defaultName];
        }
    }
    return fName;
    
}
+(NSInteger)curFilterId
{
    if (![FilterManager isValid]) {
        return 0;
    }
    NSInteger fid = [CRUserObj(@"filter_id") integerValue];
    if (!fid) {
        if ([FilterManager isValid]) {
            fid = [FilterManager defaultId];
        }
    }
    return fid;
}
+(void)updateCurFilter:(NSDictionary*)condition
{
    NSString *title = [Utility dictionaryNullValue:condition forKey:@"title"];
    NSInteger fid = [[Utility dictionaryNullValue:condition forKey:@"id"] integerValue];
    CRUserSetObj(title,@"filter_name");
    CRUserSetObj(CRString(@"%d",fid), @"filter_id");
}
+(BOOL)isValid
{
    WebAppEntity *app = CRWebAppTitle(@"globalfilter");
    if (app) {
        return true;
    }
    return false;
}
+(NSArray*)filterData
{
    NSDictionary *data = [LocalManager objectForKey:kAppFilter];
    if (CRJSONIsDictionary(data)) {
        NSArray *list = [Utility dictionaryValue:data forKey:@"filters"];
        if (CRJSONIsArray(list)) {
            return list;
        }
    }
    return nil;
}
+(NSString*)defaultName{
    NSArray *list = [FilterManager filterData];
    if (list.count>0) {
        NSDictionary *obj = list[0];
        while ([obj[@"children"] count]>0) {
            obj = obj[@"children"][0];
        }
        NSString *title = [Utility dictionaryNullValue:obj forKey:@"title"];
        NSInteger oid = [[Utility dictionaryValue:obj forKey:@"id"] integerValue];
        CRUserSetObj(title, @"filter_name");
        CRUserSetObj(CRString(@"%d",oid), @"filter_id");
        return title;
    }
    return @"";
}
+(NSInteger)defaultId{
    
    NSArray *list = [FilterManager filterData];
    if (list.count>0) {
        NSDictionary *obj = list[0];
        while ([obj[@"children"] count]>0) {
            obj = obj[@"children"][0];
        }
        NSString *title = [Utility dictionaryNullValue:obj forKey:@"title"];
        NSInteger oid = [[Utility dictionaryValue:obj forKey:@"id"] integerValue];
        CRUserSetObj(title, @"filter_name");
        CRUserSetObj(CRString(@"%d",oid), @"filter_id");
        return oid;
    }

    return 0;
}
@end
