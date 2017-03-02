//
//  AppBannerEntity.m
//  msgcopy
//
//  Created by wngzc on 15/4/19.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "AppBannerEntity.h"

@implementation AppBannerEntity

+(AppBannerEntity*)buildInstanceByJson:(NSDictionary*)json{
    
    AppBannerEntity *banner = [[AppBannerEntity alloc] init];
    banner.descr = [Utility dictionaryValue:json forKey:@"descr"];
    NSString *time =  [Utility dictionaryValue:json forKey:@"c_time"];
    if (time&&time.length) {
        banner.ctime = [NSString getDateFromeString:time];
    }
    banner.interval = [[Utility dictionaryValue:json forKey:@"interval"] integerValue];
    NSString *heightStr = [Utility dictionaryValue:json forKey:@"height"];
    NSData *sizeData = [heightStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *size = [NSJSONSerialization JSONObjectWithData:sizeData options:NSJSONReadingMutableContainers error:nil];
    NSInteger h = [[size valueForKey:@"height"] floatValue];
    NSInteger w = [[size valueForKey:@"width"] floatValue];
    banner.height = ([UIScreen mainScreen].bounds.size.width * h) / w ;
    NSString *type = [Utility dictionaryValue:json forKey:@"banner_type"];
    banner.items = [[NSMutableArray alloc] init];
    if ([type isEqualToString:@"desktop"]) {
        banner.bannerType = AppBannerTypeDeskTop;
    }else if([type isEqualToString:@"splash"])
    {
        banner.bannerType = AppBannerTypeSplash;
    }
    NSArray *images = [Utility dictionaryValue:json forKey:@"images"];
    if (images&&images.count>0) {
        NSMutableArray *items = [NSMutableArray new];
        for (NSDictionary *image in images) {
            BannerItem *item = [BannerItem buildInstanceByJson:image];
            [items addObject:item];
        }
        [banner.items addObjectsFromArray:items];
        [items removeAllObjects];
        items = nil;
    }
    return banner;
}
@end
@implementation BannerItem

+(BannerItem*)buildInstanceByJson:(NSDictionary *)json{
    
    BannerItem *item = [[BannerItem alloc] init];
    NSString *clickType = [Utility dictionaryValue:json forKey:@"click_type"];
    if ([clickType isEqualToString:@"pub"]) {
        item.clickType = BannerClickTypePub;
    }else if([clickType isEqualToString:@"link"]){
        item.clickType = BannerClickTypeLink;
    }else{
        item.clickType = BannerClickTypeNone;
    }
    item.title = [Utility dictionaryValue:json forKey:@"title"];
    item.image = [Utility dictionaryValue:json forKey:@"image"];
    item.clickValue = [Utility dictionaryValue:json forKey:@"click_value"];
    return item;
}

@end