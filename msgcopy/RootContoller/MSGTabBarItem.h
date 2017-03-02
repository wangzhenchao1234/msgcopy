//
//  MSGTabBarItem.h
//  msgcopy
//
//  Created by Gavin on 15/4/16.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "RDVTabBarItem.h"

/**
 自定义功能栏指向类型
 */
typedef enum TabBarLinkType{
    
    TabBarLinkTypeHome = 0,//首页
    TabBarLinkTypeLimb,//一级
    TabBarLinkTypeWebApp,//webApp
    TabBarLinkTypeDiyPage,//自定义页面
    TabBarLinkTypeArticle,
    TabBarLinkTypePublication,
    TabBarLinkTypeBase,
    TabBarLinkTypeMore,
    TabBarLinkTypeNone
    
}TabBarLinkType;


@interface MSGTabBarItem : RDVTabBarItem

@property (nonatomic,assign) MenuBarItemEntityType linkType;
@property (nonatomic,assign) BOOL isHome;
@property (nonatomic,retain) id data;
@property (nonatomic,copy) void(^action)(id data);

/**
 * The image used for tab bar item's selected state.
 */
- (NSString *)finishedSelectedImageUrl;

/**
 * The image used for tab bar item's unselected state.
 */
- (NSString *)finishedUnselectedImageUrl;

/**
 * Sets the tab bar item's selected and unselected images.
 */
- (void)setFinishedSelectedImageUrl:(NSString *)selectedImageUrl withFinishedUnselectedImage:(NSString *)unselectedImageUrl;
@end
