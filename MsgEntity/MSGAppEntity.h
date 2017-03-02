//
//  MSGAppEntity.h
//  msgcopy
//
//  Created by wngzc on 15/4/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserEntity;
@class IconEntity;
@class DiyPageEntity;
@class HomeConfigEntity;
@class SidBarConfigEntity;
@class MenuBarConfigEntity;
/**
 *  appModel
 */
@interface MSGAppEntity : NSObject

@property (nonatomic,assign  ) NSInteger aid;//id
@property (nonatomic,assign  ) BOOL showShop;//是否显示店铺
@property (nonatomic,copy    ) NSString  *title;//名称
@property (nonatomic,copy    ) NSString  *descr;//描述
@property (nonatomic,retain  ) NSDate    *ctime;//创建时间
@property (nonatomic,retain  ) NSDate    *utime;//更新时间
@property (nonatomic,copy    ) NSString *downloadUrl;//下载地址
@property (nonatomic,retain  ) NSArray  *global_filter;//全局过滤
@property (nonatomic,retain  ) NSMutableArray *limbs;//一级频道
@property (nonatomic,retain  ) NSMutableArray *diyPages;//自定义页面
@property (nonatomic,retain  ) UserEntity          *master;//创建者
@property (nonatomic,retain  ) HomeConfigEntity    *home;//首页类型配置
@property (nonatomic,retain  ) SidBarConfigEntity  *sideBar;//左右栏配置
@property (nonatomic,retain  ) MenuBarConfigEntity *menuBar;//功能栏配置
+(instancetype)buildByJson:(NSDictionary*)json;
//-(instancetype)pageForId:(NSInteger)pageID;

@end

typedef NS_ENUM(NSUInteger,AppHomeKind){
    
    AppHomeKindNormal,
    AppHomeKindWin8,
    AppHomeKindWebApp,
    AppHomeKindLimb,
    AppHomeKindDiyPage
    
};


/**
 *  首页配置model
 */
@interface  HomeConfigEntity:NSObject

@property (nonatomic,copy  ) NSString   *title;//名称
@property (nonatomic,assign) AppHomeKind kind;//类型
@property (nonatomic,copy  ) NSString   *params;//参数
@property (nonatomic,assign) NSInteger  hid;//id
@property (nonatomic,assign) NSInteger  addr;//参数id 如果kind为limb则为limbid 如果为webapp则为webappid
@property (nonatomic,retain) IconEntity *icon;//图标
//@property (nonatomic,assign) BOOL isShowTotal; //是否显示总浏览量
//@property (nonatomic,assign) BOOL isShowToday; //是否显示今日浏览量
//@property (nonatomic,assign) NSInteger totalPV; //总浏览量label
//@property (nonatomic,assign) NSInteger todayPV; //今日浏览量label
+(instancetype)buildByJson:(NSDictionary*)json;

@end

typedef NS_ENUM(NSUInteger,SidBarKind ){
    
    SidBarKindLeft,
    SidBarKindBottom,
    SidBarKindNone
};

/**
 左右栏类型
 */
@interface  SidBarConfigEntity:NSObject
@property (nonatomic,assign) BOOL sub;//是否启用订阅
@property (nonatomic,assign) BOOL hide_limb;//隐藏一级
@property (nonatomic,assign) NSInteger subCount;//最多可订阅个数
@property (nonatomic,assign) SidBarKind kind;//左右兰类型左、右、无
@property (nonatomic,copy  ) NSString *selected_bgcolor;//底栏选种颜色
+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end

/**
 *  自定义功能栏Model
 */
@interface  MenuBarConfigEntity:NSObject

@property (nonatomic,retain) NSMutableArray *items;//items
@property (nonatomic,copy  ) NSString *backgroundColor;//点击背景颜色
+(instancetype)buildByJson:(NSDictionary*)json;

@end



/**
 自定义功能栏指向类型
 */
typedef enum MenuBarItemEntityType{
    
    MenuBarTypeHome = 0,//首页
    MenuBarTypeLimb,//一级
    MenuBarTypeWebApp,//webApp
    MenuBarTypeLink,//链接
    MenuBarTypeDiyPage,//自定义页面
    MenuBarTypePublication,//投稿
    MenuBarTypeArticle,//投稿
    MenuBarTypeShop,//店铺功能
    MenuBarTypeBase,//基础功能
    MenuBarTypeLeaf//二级
    
    
}MenuBarItemEntityType;
/**
 *  自定义功能栏ItemModel
 */
@interface  MenuBarItemEntity:NSObject
@property (nonatomic,copy  ) NSString   *title;//标题
@property (nonatomic,copy  ) NSString   *value;//特殊参数例如id、url 等
@property (nonatomic,retain) IconEntity *icon;//图标
@property (nonatomic,assign) MenuBarItemEntityType type;//指向类型
+(instancetype)buildByJson:(NSDictionary*)json;

@end
/**
 *  自定义页面Model
 */
@interface DiyPageEntity : NSObject

@property (nonatomic,assign) BOOL isHome;//是否为首页
@property (nonatomic,assign) NSInteger dpid;//id
@property (nonatomic,assign) NSInteger column;//列数
@property (nonatomic,retain) NSMutableArray *controls;//子view
@property (nonatomic,retain) MSGAppEntity *app;//上级app
@property (nonatomic,retain) IconEntity *icon;//图标
@property (nonatomic,retain)NSDictionary *gridPosition;//在grid中位置
@property (nonatomic,copy  ) NSString *type;//类型 banner、grid、model1、model2
@property (nonatomic,copy  ) NSString *text;//描述
@property (nonatomic,copy  ) NSString *backgroundImage;//背景图
@property (nonatomic,copy  ) NSString *backgroundColor;//背景颜色
@property (nonatomic,assign) BOOL isShowTotal; //是否显示总浏览量
@property (nonatomic,assign) BOOL isShowToday; //是否显示今日浏览量
@property (nonatomic,assign) int totalPV; //总浏览量label
@property (nonatomic,assign) int todayPV; //今日浏览量label


+(instancetype)buildByJson:(NSDictionary*)json;

@end

