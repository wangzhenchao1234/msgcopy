//
//  AppDataManager.h
//  msgcopy
//
//  Created by wngzc on 15/4/8.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSGAppEntity;
@class AppBannerEntity;
typedef void(^intilizedAppDataComplete)(BOOL result);

typedef NS_ENUM(NSUInteger, RegegistType) {
    
    RegegistTypeNormal = 0,
    RegegistTypePhone,
    RegegistTypeEmail,
    RegegistTypeEP = RegegistTypeEmail | RegegistTypePhone
    
};


@interface AppDataManager : NSObject

@property (nonatomic,retain) MSGAppEntity   *curApp;
@property (nonatomic,retain) NSMutableArray *webApps;
@property (nonatomic,retain) NSMutableArray *banners;
@property (nonatomic,retain) AppBannerEntity *splashBanner;
@property (nonatomic,assign) RegegistType   registerType;


+(instancetype)sharedManager;
+(void)refreshData:(intilizedAppDataComplete)complete;
+(void)intilizedAppDataForTarget:(UIViewController*)target  progress:(void(^)(CGFloat progress))progress  complete:(intilizedAppDataComplete)complete;
+(NSArray *)intilizedViewControllers;
+(NSArray *)intilizedTabBarItems:(CenterController*)_rootCenter;
@end
