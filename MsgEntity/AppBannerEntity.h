//
//  AppBannerEntity.h
//  msgcopy
//
//  Created by wngzc on 15/4/19.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AppBannerType){
    AppBannerTypeDeskTop, //首页级别
    AppBannerTypeSplash,//app级别
    AppBannerTypeLeaf//二级级别
};


@interface AppBannerEntity : NSObject
@property (nonatomic,copy  ) NSString  *descr;
@property (nonatomic,retain) NSDate    *ctime;
@property (nonatomic,assign) NSInteger interval;
@property (nonatomic,assign) CGFloat   height;
@property (nonatomic,assign) AppBannerType bannerType;
@property (nonatomic,retain) NSMutableArray *items;

+(AppBannerEntity*)buildInstanceByJson:(NSDictionary*)json;

@end

typedef NS_ENUM(NSUInteger,BannerClickType){
    
    BannerClickTypePub,
    BannerClickTypeLink,
    BannerClickTypeNone
};


@interface BannerItem : NSObject
@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign) BannerClickType clickType;
@property (nonatomic,copy) NSString *image;
@property (nonatomic,copy) NSString *clickValue;
+(BannerItem*)buildInstanceByJson:(NSDictionary*)json;

@end
