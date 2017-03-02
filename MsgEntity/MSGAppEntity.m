//
//  MSGAppEntity.m
//  msgcopy
//
//  Created by wngzc on 15/4/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MSGAppEntity.h"

@implementation MSGAppEntity
/**
 *  初始化appModel
 *
 *  @param json json数据
 *
 *  @return appModel
 */
+(instancetype)buildByJson:(NSDictionary*)json
{
    MSGAppEntity* app     = [[MSGAppEntity alloc] init];
    app.aid               = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    app.title             = [Utility dictionaryValue:json forKey:@"title"];
    app.downloadUrl       = [Utility dictionaryValue:json forKey:@"app_url"];
    NSDictionary *homeJson    = [Utility dictionaryValue:json forKey:@"home"];
    app.home  = [HomeConfigEntity buildByJson:homeJson];
    app.diyPages = [NSMutableArray new];
    app.limbs = [NSMutableArray new];
    NSDictionary *jsonSideBar = [Utility dictionaryValue:json forKey:@"sidebar"];
    app.sideBar               = [SidBarConfigEntity buildInstanceByJson:jsonSideBar];
    NSDictionary* jsonMaster  = [json valueForKey:@"master"];
    UserEntity* master        = [UserEntity buildInstanceByJson:jsonMaster];
    app.master                = master;
    app.menuBar = nil;
    app.showShop = [[Utility dictionaryValue:json forKey:@"show_shop"] boolValue];
    return app;

}
/**
 *  初始化sideBar
 */

-(void)updateSidebar{
    
    if (self.menuBar.backgroundColor&&[self.menuBar.backgroundColor length]>1) {
        self.sideBar.selected_bgcolor = [self.menuBar.backgroundColor substringFromIndex:1];
        CRUserSetObj(self.sideBar.selected_bgcolor, @"sidebar_selectedcolor");
    }
}

@end
/**
 *  初始化app首页配置信息
 *
 *  @param json json数据
 *
 *  @return homeConfigModel
 */

@implementation HomeConfigEntity

+(instancetype)buildByJson:(NSDictionary*)json
{
    HomeConfigEntity *home = [[HomeConfigEntity alloc] init];
    home.hid         = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    home.title       = [Utility dictionaryValue:json forKey:@"title"];
    home.title       = home.title == nil?@"首页":home.title;
    NSString *kindStr   = [Utility dictionaryValue:json forKey:@"kind"];
    if ([kindStr length] == 0) {
        home.kind = AppHomeKindNormal;
    }else if([kindStr isEqualToString:@"win8"]){
        home.kind = AppHomeKindWin8;
    }else if([kindStr isEqualToString:@"webapp"]){
        home.kind = AppHomeKindWebApp;
    }else if([kindStr isEqualToString:@"diypage"]){
        home.kind = AppHomeKindDiyPage;
    }else if ([kindStr isEqualToString:@"limb"]){
        home.kind = AppHomeKindLimb;
    }
    home.addr   = [[Utility dictionaryValue:json forKey:@"addr"] integerValue];
    home.params = [Utility dictionaryValue:json forKey:@"params"];
    if (home.params != nil && [home.params length] == 0) {
        home.params = nil;
    }
    NSDictionary *iconJson = [json valueForKey:@"icon"];
    if (iconJson) {
        home.icon = [IconEntity buildInstanceByJson:iconJson];
    }
    return home;
}

@end

/**
 *  初始化sidBar配置信息
 *
 *  @param json json数据
 *
 *  @return SideBarConfigModel
 */

@implementation SidBarConfigEntity

+(instancetype)buildInstanceByJson:(NSDictionary *)json
{
    SidBarConfigEntity *sideBar = [[SidBarConfigEntity alloc] init];
    NSString *kindStr = [Utility dictionaryValue:json forKey:@"kind"];
    if ( kindStr != nil && [kindStr  length] == 0) {
        sideBar.kind = SidBarKindLeft;
    }
    if ([kindStr isEqualToString:@"left"]) {
        sideBar.kind = SidBarKindLeft;
    }else if ([kindStr isEqualToString:@"bottom"]){
        sideBar.kind = SidBarKindBottom;
    }else{
        sideBar.kind = SidBarKindNone;
    }
    sideBar.sub              = [[Utility dictionaryValue:json forKey:@"sub"] boolValue];
    sideBar.subCount        = [[Utility dictionaryValue:json forKey:@"sub_count"] integerValue];
    sideBar.hide_limb        = [[Utility dictionaryValue:json forKey:@"hide_limb"] boolValue];
    sideBar.selected_bgcolor = [Utility dictionaryValue:json forKey:@"selected_bgcolor"];
    if ( sideBar.selected_bgcolor != nil && [ sideBar.selected_bgcolor  length] == 0) {
        sideBar.selected_bgcolor = nil;
    }else{
        NSString *color = [sideBar.selected_bgcolor substringFromIndex:0];
        sideBar.selected_bgcolor = [sideBar.selected_bgcolor substringFromIndex:0];
        if ([color rangeOfString:@"#"].location!=NSNotFound) {
            sideBar.selected_bgcolor = [sideBar.selected_bgcolor substringFromIndex:1];
        }
    }
    return sideBar;
}

@end

/**
 *  初始化自定义功能栏配置信息
 *
 *  @param json json数据
 *
 *  @return MenuBarConfigModel
 */

@implementation MenuBarConfigEntity

+(instancetype)buildByJson:(NSDictionary *)json
{
    MenuBarConfigEntity *config = [[MenuBarConfigEntity alloc] init];
    NSString *backColor = [Utility dictionaryValue:json forKey:@"background_color"];
    config.backgroundColor = backColor.length>0?[backColor substringFromIndex:0]:backColor;
    if ([backColor rangeOfString:@"#"].location!=NSNotFound) {
        config.backgroundColor = [config.backgroundColor substringFromIndex:1];
    }
    kCurApp.sideBar.selected_bgcolor = config.backgroundColor;
    NSArray *items = [Utility dictionaryValue:json forKey:@"items"];
    config.items = [NSMutableArray new];
    if (items.count>0) {
        for (NSDictionary *itemJson in items) {
            MenuBarItemEntity *entity = [MenuBarItemEntity buildByJson:itemJson];
            [config.items addObject:entity];
            
        }
    }
    return config;
}

@end
/**
 *  自定义功能栏itemModel
 *
 *  @param json json数据
 *
 *  @return MenuBarEntityModel
 */

@implementation MenuBarItemEntity

+(instancetype)buildByJson:(NSDictionary *)json{
    
    MenuBarItemEntity *entity = [[MenuBarItemEntity alloc] init];
    entity.title = [Utility dictionaryValue:json forKey:@"title"];
    entity.icon = [IconEntity buildInstanceByJson:[Utility dictionaryValue:json forKey:@"icon"]];
    entity.value = [Utility dictionaryValue:json forKey:@"value"];
    if ([[Utility dictionaryValue:json forKey:@"type"] isEqualToString:@"home"]) {
        entity.type = MenuBarTypeHome;
    }else if([[Utility dictionaryValue:json forKey:@"type"] isEqualToString:@"limb"]){
        entity.type = MenuBarTypeLimb;
    }else if([[Utility dictionaryValue:json forKey:@"type"] isEqualToString:@"webapp"]){
        entity.type = MenuBarTypeWebApp;
    }else if([[Utility dictionaryValue:json forKey:@"type"] isEqualToString:@"custompage"]){
        entity.type = MenuBarTypeDiyPage;
    }else if([[Utility dictionaryValue:json forKey:@"type"] isEqualToString:@"link"]){
        entity.type = MenuBarTypeLink;
    }else if([[Utility dictionaryValue:json forKey:@"type"] isEqualToString:@"pub"]){
        entity.type = MenuBarTypePublication;
    }else if([[Utility dictionaryValue:json forKey:@"type"] isEqualToString:@"base"]){
        entity.type = MenuBarTypeBase;
    }else if([[Utility dictionaryValue:json forKey:@"type"] isEqualToString:@"leaf"]){
        entity.type = MenuBarTypeLeaf;
    }
    return entity;
}

@end

@implementation DiyPageEntity

/**
 *  自定义页面Model
 *
 *  @param json json数据
 *
 *  @return DiyPageEntity
 */


+(instancetype)buildByJson:(NSDictionary*)json{
    DiyPageEntity *page = [[DiyPageEntity alloc] init];
    if ([json[@"is_home"] boolValue]) {
//        MSGAppEntity * entity = [[MSGAppEntity alloc] init];
//        NSString * appID = [NSString stringWithFormat:@"%@",entity.aid];
//        
//        NSDictionary * params = @{
//                                  @"app_id":appID,
//                                  @"pageview":@"true"
//                                  };
//        
//        
//        [MSGRequestManager Post:KAPIPV params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//            
//            
//        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//            [CustomToast showMessageOnWindow:msg];
//            
//        }];
//        
        NSDictionary * PV = [LocalManager objectForKey:kAppInfo];
        
        
        if ([[PV objectForKey:@"app_total_pageview"] isEqual:[NSNumber numberWithInt:1]]) {
            
            page.isShowTotal = true;
        }else{
            
            page.isShowTotal = false;
        }
        
        if ([[PV objectForKey:@"app_today_pageview"] isEqual:[NSNumber numberWithInt:1]]) {
            page.isShowToday = true;
        }else{
            page.isShowToday = false;
        }
        
        page.totalPV     = [[PV objectForKey:@"total_pageview"] integerValue] ;
        page.todayPV     = [[PV objectForKey:@"today_pageview"] integerValue ];
        
        NSLog(@"json == %@",json);
    }
    page.column = [[Utility dictionaryValue:json forKey:@"column"] integerValue];
    page.text = [Utility dictionaryValue:json forKey:@"text"];
    page.isHome = [[Utility dictionaryValue:json forKey:@"is_home"] boolValue];
    NSArray *controls = [Utility dictionaryValue:json forKey:@"controls"];
    page.controls = [NSMutableArray new];
    for (NSDictionary *control in controls) {
        
        NSString *type = [Utility dictionaryValue:control forKey:@"type"];
        
        if ([type isEqualToString:@"Grid"]) {
            
            DiyMultyGridEntiy *entity = [DiyMultyGridEntiy buildByJson:control];
            [page.controls addObject:entity];
            
        }else if ([type isEqualToString:@"Module"]) {
            
            DiySingleGridEntity *entity = [DiySingleGridEntity buildByJson:control];
            [page.controls addObject:entity];
            
        }else if ([type isEqualToString:@"Module2"]) {
            
            DiyModule2Entity *entity = [DiyModule2Entity buildByJson:control];
            [page.controls addObject:entity];
            
        }else if([type isEqualToString:@"Banner"]){
            
            DiyBannerEntity *entity = [DiyBannerEntity buildByJson:control];
            [page.controls addObject:entity];
            
        }else if([type isEqualToString:@"LeafContent"]){
            
            DiyLeafContentEntity *content = [DiyLeafContentEntity buildByJson:control];
            [page.controls addObject:content];
            
        }
    }
    page.backgroundImage = [Utility dictionaryValue:json forKey:@"bg_img"];
    page.backgroundColor = [Utility dictionaryValue:json forKey:@"bg_color"];
    page.type = [Utility dictionaryValue:json forKey:@"type"];
    page.dpid = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    return page;
}

@end

