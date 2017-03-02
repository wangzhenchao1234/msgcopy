//
//  PermissonManager.m
//  msgcopy
//
//  Created by wngzc on 15/4/13.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "PermissonManager.h"

@implementation PermissonManager
CRManager(PermissonManager)
/**
 *  是否绑定新权限
 *
 *  @return 结果
 */
-(BOOL)isNewPermssionValid
{
    WebAppEntity *app = CRWebAppTitle(@"permissionmanage");
    if (app) {
        return true;
    }
    return false;
}
/**
 *  是否绑定旧权限
 *
 *  @return 结果
 */
-(BOOL)isOldPermssionValid
{
    WebAppEntity *app = CRWebAppTitle(@"auth_client");
    if (app) {
        return true;
    }
    return false;
}
/**
 *  是否绑定自定义功能兰
 *
 *  @return 结果
 */

-(BOOL)isCustoumFuncBarValid{
    WebAppEntity *app = CRWebAppTitle(@"diyfuncbar");
    if (app) {
        return true;
    }
    return false;
}

/**
 *  检查leaf权限
 *
 *  @param leaf 二级列表entity
 */
-(void)permissionForLeaf:(LeafEntity*)leaf{
    
    for (NSDictionary *item in _oldPermission.leafs) {
        NSString *leafId = [item valueForKey:@"leaf_id"];
        if ([leafId integerValue] == leaf.lid) {
            if ([[item valueForKey:@"status"] isEqualToString:@"hide"]) {
                leaf.hiddeen = true;
                leaf.req_permission = false;
            }else{
                leaf.hiddeen = false;
                leaf.req_permission = true;
            }
            return;
        }
    }
    leaf.hiddeen = false;
    leaf.req_permission = false;
    
}
/**
 * 更新一级权限
 */
-(void)updateLimbs{
    
    NSArray *limbs = kCurApp.limbs;
    _authLimbs = [NSMutableArray new];
    for (LimbEntity *limb  in  limbs) {
        for (LeafEntity *leaf in limb.leafs) {
            [self permissionForLeaf:leaf];
        }
//        if ([self checkDiyFunctionBar:limb.lid]) {
            [_authLimbs addObject:limb];
//        }
    }
    _customTabBarItems = [PermissonManager filterDiyFunctionBar];
}
/**
 *  更新自定义功能栏权限
 *
 *  @param lid 功能栏itemID
 *
 *  @return
 */
-(BOOL)checkDiyFunctionBar:(NSInteger)lid{
    
    if (![self isCustoumFuncBarValid]) {
        return true;
    }else{
        __block BOOL result = false;
        [kCurApp.menuBar.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MenuBarItemEntity *item = obj;
            if (item.type == MenuBarTypeLimb) {
                if ([item.value integerValue] == lid) {
                    result = true;
                    *stop = true;
                }
            }
        }];
        return result;
    }
}
/**
 *  加载旧权限缓存
 *
 *  @return 成功否
 */
-(BOOL)loadOldPermissionCache
{
    NSDictionary *permissionJson = [LocalManager objectForKey:kOldPermissionKey];
    if (permissionJson) {
        _oldPermission = [OldPermissionEntity buildInstanceByJson:permissionJson];
        return YES;
    }
    return NO;
}
/**
 *  加载新权限缓存
 *
 *  @return 成功否
 */

-(BOOL)loadNewPermissionCache
{
    PermissonManager *manager = [PermissonManager sharedManager];
    NSArray *permissionJson = [LocalManager objectForKey:kNewPermissionKey];
    NSMutableArray *permissons = [NSMutableArray new];
    if (permissionJson) {
        [permissionJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PermissionEntity *entity = [PermissionEntity buildWithJson:obj];
            if ([entity.systitle isEqualToString:@"login"]) {
                //有登录权限
                manager.loginValid = true;
            }
            [permissons addObject:entity];
        }];
        _authorPermissions = permissons;
        return YES;
    }
    return NO;
}

-(void)checkAppPermisson:(void(^)(BOOL result))complete
{
    PermissonManager *manager = [PermissonManager sharedManager];
    if (!self.isOldPermssionValid) {
        manager.oldPermission = [[OldPermissionEntity alloc] init];
        manager.oldPermission.login_switch = 1;
        _loginValid = 1;
        manager.oldPermission.leafs = [NSMutableArray new];
        [self updateLimbs];
//        if (![self isNewPermssionValid]) {
        //两个权限都没有直接跳过
        complete(true);
//        }else{
//            
//            //第二个权限存在判断登录和投稿权限
//            _authorPermissions = [NSMutableArray new];
//            [MSGRequestManager Get:kAPIPermission params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//                [LocalManager storeObject:data forKey:kNewPermissionKey];
//                [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    PermissionEntity *entity = [PermissionEntity buildWithJson:obj];
//                    if ([entity.systitle isEqualToString:@"login"]) {
//                        //有登录权限
//                        manager.loginValid = true;
//                    }
//                    [_authorPermissions addObject:entity];
//                }];
//                complete(true);
//            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//                //加载缓存数据
//                if ([self loadNewPermissionCache]) {
//                    complete(true);
//                    return;
//                }
//                complete(false);
//            }];
//        }
        
    }else{
        //旧权限
        [MSGRequestManager Get:kAPIBasePermission params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [LocalManager storeObject:data forKey:kOldPermissionKey];
            _oldPermission = [OldPermissionEntity buildInstanceByJson:data];
            _loginValid = _oldPermission.login_switch;
            [self updateLimbs];
//            if (![self isNewPermssionValid]) {
//                //两个权限都没有直接跳过
                complete(true);
//            }else{
//                //第二个权限存在判断登录和投稿权限
//                _authorPermissions = [NSMutableArray new];
//                [MSGRequestManager Get:kAPIPermission params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//                    [LocalManager storeObject:data forKey:kNewPermissionKey];
//                    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                        PermissionEntity *entity = [PermissionEntity buildWithJson:obj];
//                        if ([entity.systitle isEqualToString:@"login"]) {
//                            //有登录权限
//                            manager.loginValid = true;
//                        }
//                        [_authorPermissions addObject:entity];
//                    }];
//                    complete(true);
//                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//                    //加载缓存数据
//                    if ([self loadNewPermissionCache]) {
//                        complete(true);
//                        return;
//                    }
//                    complete(false);
//                }];
//            }
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            //加载缓存
            if ([self loadOldPermissionCache]) {
                [self updateLimbs];
                complete(true);
            }else{
                complete(false);
            }
        }];
    }
}
-(void)loadCache
{
    if ([self loadOldPermissionCache]){
        _loginValid = _oldPermission.login_switch;
        [self updateLimbs];
    }
}
/**
 *  过滤自定义功能栏items
 *
 *  @return 自定义功能栏items
 */
+(NSArray*)filterDiyFunctionBar
{
    NSMutableArray *barItems = [NSMutableArray new];
    MSGAppEntity *curApp = kCurApp;
    MenuBarConfigEntity *menuBar = curApp.menuBar;
    if (!menuBar) {
        NSMutableArray *barApps = [NSMutableArray new];
        NSArray *filterApps = CRWebAppOptype(0);
        [barApps addObjectsFromArray:filterApps];
        if (kCurApp.home.kind!=AppHomeKindLimb) {
            [barItems addObject:curApp.home];
        }
        NSArray *limbs = [PermissonManager sharedManager].authLimbs;
        if (curApp.showShop) {
            //店铺显示隐藏一级
            WebAppEntity *shopStore = CRWebAppTitle(@"shopstore");
            [barApps removeObject:shopStore];
            [barItems insertObject:shopStore atIndex:0];
            HomeConfigEntity *home = curApp.home;
            if (home&&home.kind!= AppHomeKindLimb) {
                [barItems removeObject:home];
                [barItems insertObject:home atIndex:0];
            }
        }else{
            [barItems addObjectsFromArray:limbs];
        }
        [barItems addObjectsFromArray:barApps];
        return barItems;
    }
    for (MenuBarItemEntity *item in menuBar.items) {
        
        if (item.type == MenuBarTypeHome) {
            if (item.title&&[item.title length]>0) {
                curApp.home.title = item.title;
            }
            if (item.icon.normal_icon&&[item.icon.normal_icon length]>0) {
                curApp.home.icon = item.icon;
            }
            [barItems addObject:curApp.home];
        }else if (item.type == MenuBarTypeLimb&&!curApp.sideBar.hide_limb&&!curApp.showShop) {
            //店铺显示隐藏一级
            LimbEntity *limb = CRLimbForID(item.value.integerValue);
            if ((kCurApp.home.kind == AppHomeKindLimb && kCurApp.home.addr == limb.lid)||!limb) {
                continue;
            }
            if (limb) {
                if (item.icon.normal_icon) {
                    limb.icon.normal_icon = item.icon.normal_icon;
                }
                if (item.icon.selected_icon) {
                    limb.icon.selected_icon = item.icon.selected_icon;
                }
                if (item.title) {
                    limb.title = item.title;
                }
                [barItems addObject:limb];
            }else{
                LimbEntity *limb = [[LimbEntity alloc] init];
                limb.lid = item.value.integerValue;
                limb.icon = item.icon;
                limb.title = item.title;
                [barItems addObject:limb];
            }
            
        }else if(item.type == MenuBarTypeWebApp){
            
            WebAppEntity *webApp = CRWebAppID(item.value.integerValue);
            if ([webApp.systitle isEqualToString:@"shopstore"]&&!kCurApp.showShop) {
                continue;
            }
            if (webApp) {
                if (item.icon.selected_icon) {
                    webApp.diyIcon = item.icon;
                }else{
                    webApp.diyIcon = webApp.icon;
                }
                if (item.title) {
                    webApp.title = item.title;
                }
                [barItems addObject:webApp];
                
            }else{
                WebAppEntity *webApp = [[WebAppEntity alloc] init];
                webApp.aid = item.value.integerValue;
                webApp.icon = item.icon;
                webApp.title = item.title;
                [barItems addObject:webApp];
            }
            
        }else if(item.type == MenuBarTypeLink){
            
            ArticleEntity *msg = [[ArticleEntity alloc] init];
            msg.ctype = [[CtypeModal alloc] init];
            msg.ctype.systitle = @"lianjie";
            msg.links = [NSMutableArray new];
            [msg.links addObject:item.value];
            if (item.title&&[item.title length]>0) {
                msg.title = item.title;
            }else{
                msg.title = @"";
            }
            if (item.icon.normal_icon&&[item.icon.normal_icon length]>0) {
                msg.icon = item.icon;
            }
            [barItems addObject:msg];
            
        }else if(item.type == MenuBarTypeDiyPage){
            
            DiyPageEntity *page = CRPageForID(item.value.integerValue);
            if (page) {
                if (item.title&&[item.title length]>0) {
                    page.text = item.title;
                }else{
                    page.text = @"";
                }
                if (item.icon.normal_icon&&[item.icon.normal_icon length]>0) {
                    page.icon = item.icon;
                }
                [barItems addObject:page];
                
            }else{
                DiyPageEntity *page = [[DiyPageEntity alloc] init];
                page.text = item.title;
                page.icon = item.icon;
                page.dpid = item.value.integerValue;
                [barItems addObject:page];
            }
            
        }else if(item.type == MenuBarTypePublication){
            
            PubEntity *pub = [[PubEntity alloc] init];
            pub.pid = item.value.integerValue;
            if (item.title&&[item.title length]>0) {
                pub.title = item.title;
            }else{
                pub.title = @"";
            }
            if (item.icon.normal_icon&&[item.icon.normal_icon length]>0) {
                pub.icon = item.icon;
            }
            [barItems addObject:pub];
            
        }else if(item.type == MenuBarTypeBase){
            
            BaseTabItemEntity *baseItem = [[BaseTabItemEntity alloc] initWithType:item.value title:item.title icon:item.icon];
            [barItems addObject:baseItem];
            
        }else if(item.type == MenuBarTypeLeaf){
            
            LeafEntity *leaf = [[LeafEntity alloc] init];
            leaf.lid = item.value.integerValue;
            leaf.title = item.title;
            if (item.icon.normal_icon&&[item.icon.normal_icon length]>0) {
                leaf.icon = item.icon;
            }
            [barItems addObject:leaf];
        }
        
    }
    return barItems;
}

@end
