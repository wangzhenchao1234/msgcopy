//
//  AppDataManager.m
//  msgcopy
//
//  Created by wngzc on 15/4/8.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "AppDataManager.h"
#import "MSGTabBarItem.h"
#import "HomeController.h"
#import "TabBarMoreController.h"
#import "CenterController.h"
#import <SSZipArchive/SSZipArchive.h>

static AppDataManager *manager = nil;

@interface AppDataManager()
@property(nonatomic,weak)UIViewController *targetViewController;
@property(nonatomic,copy)void(^callBack)(BOOL result);
@property(nonatomic,copy)void(^progressBlock)(CGFloat progress);

@end


@implementation AppDataManager
CRManager(AppDataManager);
- (instancetype)init
{
    self = [super init];
    if (self) {
        _webApps = [NSMutableArray new];
        _banners = [NSMutableArray new];
        [ContentManager sharedManager];
        [HistoryContentManager sharedManager];
        [MCenterManager sharedManager];
        [self checkWebModalUpdate];
    }
    return self;
}
#pragma mark - 初始化app数据
/**
 * 初始化app数据
 */
+(void)intilizedAppDataForTarget:(UIViewController *)target  progress:(void(^)(CGFloat progress))progress  complete:(intilizedAppDataComplete)complete
{
    manager = [AppDataManager sharedManager];
    manager.targetViewController = target;
    manager.callBack = complete;
    manager.progressBlock = progress;
    if (CRUserBOOL(kAppInit)) {
        [AppDataManager loadCache];
        return;
    }else{
        [AppDataManager loadFromServer];
    }
}
+(void)refreshData:(intilizedAppDataComplete)complete
{
    manager.callBack = complete;
    [AppDataManager loadFromServer];
}
+(void)loadFromServer{
    /**
     * 获取App配置信息
     */
    
    [manager getAppInfo];
}
+(void)loadCache
{
    //app数据
    NSDictionary *appdata = [LocalManager objectForKey:kAppInfo];
    NSArray *limbsJson = [LocalManager objectForKey:kAllLimbs];
    NSArray *webapps = [LocalManager objectForKey:kWebAppInfo];
    NSDictionary *funcData = [LocalManager objectForKey:kAppDiyFunBar];
    NSArray *bannersJson =  [LocalManager objectForKey:kAppBanner];
    NSDictionary *registerJson = [LocalManager objectForKey:kAppRegType];
    NSString *shareDomain = CRUserObj(kThirdShare);
    NSDictionary *permissionData = [LocalManager objectForKey:kOldPermissionKey];
    if (!appdata||!limbsJson||!bannersJson||!registerJson||!permissionData||!shareDomain) {
        [AppDataManager loadFromServer];
        return;
    }
    AppDataManager *manager = [AppDataManager sharedManager];
    manager.curApp = [MSGAppEntity  buildByJson:appdata];
//    manager.progressBlock(0.4);
    //一级频道数据
    [limbsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LimbEntity *limb = [LimbEntity buildInstanceByJson:obj];
        [manager.curApp.limbs addObject:limb];
    }];
//    manager.progressBlock(0.5);
    //webapp
    [webapps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *app = obj;
        WebAppEntity *appEntity = [WebAppEntity buildInstanceByJson:app];
        [manager.webApps addObject:appEntity];
    }];
    manager.progressBlock(0.6);
    //所有diy功能栏
    if (funcData) {
        manager.curApp.menuBar = [MenuBarConfigEntity buildByJson:funcData];
    }else{
        manager.curApp.menuBar = nil;
    }
//    manager.progressBlock(0.7);
    
    [[PermissonManager sharedManager] loadCache];
//    manager.progressBlock(0.8);

    //获取轮播图
    NSMutableArray *banners = [NSMutableArray new];
    [bannersJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AppBannerEntity *banner = [AppBannerEntity buildInstanceByJson:obj];
        [banners addObject:banner];
        if (banner.bannerType == AppBannerTypeSplash) {
            manager.splashBanner = banner;
        }
    }];
//    manager.progressBlock(0.9);
    manager.banners = banners;
    //获取注册类型
    NSArray *types = [registerJson valueForKey:@"login_type"];
    if (types) {
        if (types.count == 0) {
            manager.registerType = RegegistTypeNormal;
        }else{
            NSString *email = nil;
            NSString *phone = nil;
            NSString *normal = nil;
            for (NSString *type in types) {
                NSString *newType = type;
                if ([type isKindOfClass:[NSNull class]]) {
                    newType = @"";
                }
                if ([newType isEqualToString:@"email"]) {
                    email = type;
                }else if ([type isEqualToString:@"phone"]) {
                    phone = type;
                }else if ([type isEqualToString:@"normal"]) {
                    normal = type;
                }
            }
            if (normal) {
                manager.registerType = RegegistTypeNormal;
            }else if(phone&&!email){
                manager.registerType = RegegistTypePhone;
            }else if(email&&!phone){
                manager.registerType = RegegistTypeEmail;
            }else{
                manager.registerType = RegegistTypePhone | RegegistTypeEmail;
            }
        }
    }
    manager.progressBlock(1.0);
    manager.callBack(true);

}

# pragma mark - 刷新全部数据



#pragma mark - 获取webApps
/**
 * 获取webApps
 */
-(void)getAllWebApps
{
    /**
     *  获取webApps信息
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    CRWeekRef(manager);
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIWebApp params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        //缓存数据
        [LocalManager storeObject:data forKey:kWebAppInfo];
        __manager.progressBlock(0.6);
        NSArray *webapps = data;
        __block NSMutableArray *allapps = [NSMutableArray new];
        [webapps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *app = obj;
            WebAppEntity *appEntity = [WebAppEntity buildInstanceByJson:app];
            [allapps addObject:appEntity];
        }];
        __manager.webApps = allapps;
        [__self getDiyFunctionBar];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSArray *webapps = [LocalManager objectForKey:kWebAppInfo];
        if (webapps) {
            __block NSMutableArray *allapps = [NSMutableArray new];
            [webapps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *app = obj;
                WebAppEntity *appEntity = [WebAppEntity buildInstanceByJson:app];
                [allapps addObject:appEntity];
            }];
            __manager.webApps = allapps;
            [__self getDiyFunctionBar];

        }else{
            manager.callBack(false);
        }
    }];
    
}
#pragma mark - 获取app基础信息
/**
 * 获取diy功能栏
 */
-(void)getDiyFunctionBar
{
    /**
     *  获取diy功能栏
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    CRWeekRef(manager);
    CRWeekRef(self);
    [GCookieManager setCookie:kAPIDiyFuncBar];
    [MSGRequestManager Get:kAPIDiyFuncBar params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
     {
         //缓存数据
         [LocalManager storeObject:data forKey:kAppDiyFunBar];
         __manager.progressBlock(0.7);
         __manager.curApp.menuBar = [MenuBarConfigEntity buildByJson:data];
         [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
             NSDictionary *pm = [LocalManager objectForKey:kOldPermissionKey];
             if (result||pm) {
                 [__self getAppBanner];
             }else{
                 __manager.callBack(false);
             }
         }];
         
     } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
         
         __manager.progressBlock(0.7);
         if (code == 404||code == 502) {
             __manager.curApp.menuBar = nil;
             CRUserRemoveObj(kAppDiyFunBar);
             [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                 NSDictionary *pm = [LocalManager objectForKey:kOldPermissionKey];
                 if (result||pm) {
                     [__self getAppBanner];
                 }else{
                     __manager.callBack(false);
                 }
             }];
         }else{
             NSDictionary *barData = [LocalManager objectForKey:kAppDiyFunBar];
             if (barData) {
                 __manager.curApp.menuBar = [MenuBarConfigEntity buildByJson:barData];
                 [[PermissonManager sharedManager] checkAppPermisson:^(BOOL result) {
                     NSDictionary *pm = [LocalManager objectForKey:kOldPermissionKey];
                     if (result||pm) {
                         [__self getAppBanner];
                     }else{
                         __manager.callBack(false);
                     }
                 }];
                 
             }else{
                 manager.callBack(false);
             }

         }
    }];
}
/**
 * 获取diy首页
 */
-(void)getDiyPageInfoSuccess:(requestComplete)success failed:(requestComplete)failed
{
    /**
     *  获取diy首页
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    [MSGRequestManager Get:kAPIDiyPage params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
     {
         //缓存数据
         [LocalManager storeObject:data forKey:kAppInfo];
         success(msg,code,data,requestURL);
         
     } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
         [CustomToast showMessageOnWindow:msg];
         failed(msg,code,data,requestURL);
     }];
}

#pragma mark - 获取app基础信息
/**
 * 获取app基础信息
 */
-(void)getAppInfo
{
    /**
     *  获取app基础信息
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    CRWeekRef(manager);
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIApp params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
     {
         //缓存数据
         [LocalManager storeObject:data forKey:kAppInfo];
         __manager.curApp = [MSGAppEntity  buildByJson:data];
         [__self getAllLimbs];
         
     } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
         NSDictionary *appData = [LocalManager objectForKey:kAppInfo];
         if (appData) {
             __manager.curApp = [MSGAppEntity  buildByJson:appData];
             [__self getAllLimbs];
         }else{
             __manager.callBack(false);
         }
     }];
}


#pragma mark - 获取旧权限
/**
 * 获取旧权限
 */
-(void)getOldPermissionSuccess:(requestComplete)success failed:(requestComplete)failed
{
    /**
     *  获取旧权限
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    
    [MSGRequestManager Get:kAPIBasePermission params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [LocalManager storeObject:data forKey:kOldPermissionKey];
        success(msg,code,data,requestURL);

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
        failed(msg,code,data,requestURL);
    }];
    
}

#pragma mark - 获取新权限
/**
 * 获取新权限
 */
-(void)getNewPermissionSuccess:(requestComplete)success failed:(requestComplete)failed
{
    /**
     *  获取新权限
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    [MSGRequestManager Get:kAPIPermission params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [LocalManager storeObject:data forKey:kNewPermissionKey];
        success(msg,code,data,requestURL);
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [CustomToast showMessageOnWindow:msg];
        failed(msg,code,data,requestURL);
    }];
    
}

#pragma mark - 获取轮播图
/**
 * 获取轮播图
 */
-(void)getAppBanner
{
    /**
     *  获取轮播图
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    CRWeekRef(manager);
    CRWeekRef(self);
    
    [MSGRequestManager Get:kAPIAppBanner params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
        [LocalManager storeObject:data forKey:kAppBanner];
        __manager.progressBlock(0.9);
        NSArray *bannersJson = data;
        __block NSMutableArray *banners = [NSMutableArray new];
        [bannersJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AppBannerEntity *banner = [AppBannerEntity buildInstanceByJson:obj];
            [banners addObject:banner];
            if (banner.bannerType == AppBannerTypeSplash) {
                __manager.splashBanner = banner;
            }
        }];
        __manager.banners = banners;
        [__self getAppFilter];

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        
        __manager.progressBlock(0.9);
        NSArray *bannersJson = [LocalManager objectForKey:kAppBanner];
        if (bannersJson) {
            NSArray *bannersJson = data;
            __block NSMutableArray *banners = [NSMutableArray new];
            [bannersJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                AppBannerEntity *banner = [AppBannerEntity buildInstanceByJson:obj];
                [banners addObject:banner];
            }];
            __manager.banners = banners;
            [__self getAppFilter];
        }else{
            __manager.callBack(false);
        }
        
    }];
    
}

#pragma mark - 获取轮全局过滤
/**
 *  获取轮全局过滤
 */
-(void)getAppFilter
{
    /**
     *  获取轮全局过滤
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    CRWeekRef(manager);
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIFilter params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [LocalManager storeObject:data forKey:kAppFilter];
        [__self getAppRegisterType];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSDictionary *filterData = [LocalManager objectForKey:kAppFilter];
        if (filterData) {
            [__self getAppRegisterType];
        }else{
            __manager.callBack(false);
        }
    }];
    
}

#pragma mark - 获取注册类型
/**
 *  获取注册类型
 */
-(void)getAppRegisterType
{
    /**
     *  获取注册类型
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    CRWeekRef(manager);
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIRegisterType params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
    {
        [LocalManager storeObject:data forKey:kAppRegType];
        NSArray *types = [data valueForKey:@"login_type"];
        if (types) {
            if (types.count == 0) {
                __manager.registerType = RegegistTypeNormal;
            }else{
                NSString *email = nil;
                NSString *phone = nil;
                NSString *normal = nil;
                for (NSString *type in types) {
                    NSString *newType = type;
                    if ([type isKindOfClass:[NSNull class]]) {
                        newType = @"";
                    }
                    if ([newType isEqualToString:@"email"]) {
                        email = type;
                    }else if ([type isEqualToString:@"phone"]) {
                        phone = type;
                    }else if ([type isEqualToString:@"normal"]) {
                        normal = type;
                    }
                }
                if (normal) {
                    __manager.registerType = RegegistTypeNormal;
                }else if(phone&&!email){
                    __manager.registerType = RegegistTypePhone;
                }else if(email&&!phone){
                    __manager.registerType = RegegistTypeEmail;
                }else{
                    __manager.registerType = RegegistTypePhone | RegegistTypeEmail;
                }
            }
        }else{
            __manager.registerType = RegegistTypeNormal;
        }
        [__self getThirdShare];

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSDictionary *regData = [LocalManager objectForKey:kAppRegType];
        if (regData) {
            NSArray *types = [data valueForKey:@"login_type"];
            if (types) {
                if (types.count == 0) {
                    __manager.registerType = RegegistTypeNormal;
                }else{
                    NSString *email = nil;
                    NSString *phone = nil;
                    NSString *normal = nil;
                    for (NSString *type in types) {
                        NSString *newType = type;
                        if ([type isKindOfClass:[NSNull class]]) {
                            newType = @"";
                        }
                        if ([newType isEqualToString:@"email"]) {
                            email = type;
                        }else if ([type isEqualToString:@"phone"]) {
                            phone = type;
                        }else if ([type isEqualToString:@"normal"]) {
                            normal = type;
                        }
                    }
                    if (normal) {
                        __manager.registerType = RegegistTypeNormal;
                    }else if(phone&&!email){
                        __manager.registerType = RegegistTypePhone;
                    }else if(email&&!phone){
                        __manager.registerType = RegegistTypeEmail;
                    }else{
                        __manager.registerType = RegegistTypePhone | RegegistTypeEmail;
                    }
                }
            }else{
                __manager.registerType = RegegistTypeNormal;
            }
            [__self getThirdShare];
        }else{
            __manager.callBack(false);
        }
    }];
    
}


#pragma mark - 第三方分享链接
/**
 * 第三方分享链接
 */

-(void)getThirdShare
{
    /**
     *   第三方分享链接
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    CRWeekRef(manager);
    [MSGRequestManager Get:kAPIThirdShare params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSDictionary* jsonDomain = data;
        NSString *domain = [Utility dictionaryValue:jsonDomain forKey:@"third_share"];
        CRUserSetObj(domain,kThirdShare);
        CRUserSetBOOL(true, kAppInit);
        __manager.progressBlock(1.0);
        __manager.callBack(true);
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSString *domain = CRUserObj(kThirdShare);
        if (domain) {
            __manager.progressBlock(1.0);
            __manager.callBack(true);
        }else{
            manager.callBack(false);
        }
    }];
}
#pragma mark - 获取一级列表信息
/**
 * 获取一级列表
 */
-(void)getAllLimbs
{
    /**
     *  获取一级列表
     *
     *  @param msg        错误信息
     *  @param code       返回码
     *  @param data       报文数据
     *  @param requestURL apiUrl
     *
     */
    [MSGRequestManager Get:kAPILimb params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [LocalManager storeObject:data forKey:kAllLimbs];
        NSArray *limbsJson = data;
        [limbsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LimbEntity *limb = [LimbEntity buildInstanceByJson:obj];
            [manager.curApp.limbs addObject:limb];
        }];
        [self getAllWebApps];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSArray *limbsJson = [LocalManager objectForKey:kAllLimbs];
        if (limbsJson) {
            [limbsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LimbEntity *limb = [LimbEntity buildInstanceByJson:obj];
                [manager.curApp.limbs addObject:limb];
            }];
            [self getAllWebApps];
        }else{
            [CustomToast showMessageOnWindow:msg];
            manager.callBack(false);
        }
    }];
}
/**
 *  更新模板
 *
 *  @return 结果
 */
-(void)checkWebModalUpdate{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *orignFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/source.bundle"];
    NSString *path = [NSString stringWithFormat:@"%@/source.bundle",documents];
    NSString *downloadPath = [NSString stringWithFormat:@"%@/download",documents];
    NSError *error = nil;
    [manager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (![manager fileExistsAtPath:path]) {
        
        if([manager copyItemAtPath:orignFilePath toPath:path error:&error] == NO)
        {
            return;
        }
    }
    [MSGRequestManager Get:kAPIWebModalUpdate params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        CRBackgroundGCD(^{
            [self comparedModalVersion:data];
        });
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSLog(@"检查模板更新失败 error == %@",msg);
    }];
    
}
/**
 *  对比本地与远程模板信息
 *
 *  @param info 信息内容
 */
-(void)comparedModalVersion:(NSDictionary*)info{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *basePath = [NSString stringWithFormat:@"%@/source.bundle",documents];
    NSInteger successCount = 0;
    
    for (NSString *name in info.allKeys) {
        
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *desDir = [NSString stringWithFormat:@"%@/%@/readme.txt",basePath,name];
        BOOL isExist = [manager fileExistsAtPath:desDir];
        NSDictionary *obj = [info valueForKey:name];
        
        /**
         * 当模板能对应上并且版本高或者本地模板中不存在是需要更新
         */
        NSDictionary *curObj = nil;
        if (isExist) {
            NSError *error = nil;
            NSString *info = [NSString stringWithContentsOfFile:desDir encoding:NSUTF8StringEncoding error:&error];
            info = [info stringByReplacingOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,info.length)];
            NSData *data = [info dataUsingEncoding:NSUTF8StringEncoding];
            curObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        }
        if (!isExist||[self modal1:obj compareModal2:curObj]) {
            BOOL success = [self templateUpdate:name obj:obj documents:documents];
            if (success) {
                successCount ++;
            }
        }
    }
    if (successCount == info.allKeys.count) {
        //        NSLog(@"");
    }
}
/**
 *  更新制定模板
 *
 *  @param name      名字
 *  @param obj       具体信息
 *  @param documents 路径
 *
 *  @return 成功与否
 */
- (BOOL)templateUpdate:(NSString *)name obj:(NSDictionary *)obj documents:(NSString *)documents {
    /**
     * 升级
     */
    NSString* url = [obj valueForKey:@"url"];
    if ([url rangeOfString:@"http://"].location == NSNotFound) {
        url = [NSString stringWithFormat:@"http://%@",url];
    }
    NSURL *baseURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval = 20;
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error) {
        NSString *zipPath = [NSString stringWithFormat:@"%@/download/%@.zip",documents,name];
        BOOL success = [respData writeToFile:zipPath options:NSDataWritingAtomic error:&error];
        if (success) {
            NSString *desPath = [NSString stringWithFormat:@"%@/source.bundle/",documents];
            NSLog(@"template desPath = %@",desPath);
            BOOL success = [SSZipArchive unzipFileAtPath:zipPath toDestination:desPath];
            if (success) {
                return YES;
            }
        }
        return true;
    }
    
    return NO;
}
/**
 * 比较两个模板的版本号
 */
-(BOOL)modal1:(NSDictionary*)modal1 compareModal2:(NSDictionary*)modal2{
    
    @try {
        if (!modal2||modal2.allKeys.count == 0) {
            return YES;
        }
        NSComparisonResult result = NSOrderedSame;
        NSString *originVersion = [modal1 valueForKey:@"version"];
        NSString *localVersion = [modal2 valueForKey:@"version"];
        NSArray *orVersionCM = [originVersion componentsSeparatedByString:@"."];
        NSArray *lcVersionCM = [localVersion componentsSeparatedByString:@"."];
        for (int i = 0 ; i <[lcVersionCM count] ; i++) {
            if ([orVersionCM[i] integerValue] > [lcVersionCM[i] integerValue] ) {
                result = NSOrderedDescending;
                break;
            }else if ([orVersionCM[i] integerValue] < [lcVersionCM[i] integerValue]){
                break;
            }
        }
        if(result == NSOrderedDescending)
        {
            return YES;
        }
        return NO;
        
    }
    @catch (NSException *exception) {
        return YES;
    }
}

# pragma mark - tabBarHanddler

+(NSArray *)intilizedViewControllers
{
    UIViewController *home = [HomeController homeController];
    LimbController *limb = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LimbController"];
//    if (kCurApp.sideBar.kind == SidBarKindBottom&&kCurCustomBarItems.count>5) {
        TabBarMoreController *more = [Utility controllerInStoryboard:@"Main" withIdentifier:@"TabBarMoreController"];
        return @[home,limb,more];
//    }
//    return @[home,limb];
}
/**
 *  初始化tabbaritems
 *
 *  @return items
 */
+(NSArray *)intilizedTabBarItems:(CenterController*)_rootCenter
{
    NSArray *barItems = kCurCustomBarItems;
    NSMutableArray *tabBarItems = [NSMutableArray new];
    if (barItems.count > 5) {
        NSArray *items = [barItems subarrayWithRange:NSMakeRange(0, 4)];
        [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MenuBarItemEntity *barItemEntity = obj;
            MSGTabBarItem *item = [[MSGTabBarItem alloc] init];
            [self configTabBarItem:item withData:barItemEntity center:_rootCenter];
            item.itemHeight = TAB_H;
            [tabBarItems addObject:item];
        }];
        MSGTabBarItem *item = [[MSGTabBarItem alloc] init];
        item.itemHeight = TAB_H;
        item.linkType = TabBarLinkTypeMore;
        item.title = @"更多";
        [item setFinishedSelectedImage:[UIImage imageNamed:@"ic_home_more"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_home_more"]];
        item.action =  ^(id data){
            TabBarMoreController *more = _rootCenter.viewControllers[2];
            more.items = [barItems subarrayWithRange:NSMakeRange(4, barItems.count - 4)];
            [_rootCenter setSelectedIndex:2];
            [_rootCenter setTitle:@"更多"];
            
        };
        if (kCurApp.sideBar.selected_bgcolor) {
            item.selectedTitleAttributes = @{NSFontAttributeName:MSGHTFont(10),NSForegroundColorAttributeName:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor]};
        }else{
            item.selectedTitleAttributes = @{NSFontAttributeName:MSGHTFont(10)};
        }
        item.unselectedTitleAttributes = @{NSFontAttributeName:MSGHTFont(10),NSForegroundColorAttributeName: [UIColor colorFromHexRGB:@"999999"]};
        [tabBarItems addObject:item];
        
    }else{
        [barItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MenuBarItemEntity *barItemEntity = obj;
            MSGTabBarItem *item = [[MSGTabBarItem alloc] init];
            item.itemHeight = TAB_H;
            [self configTabBarItem:item withData:barItemEntity center:_rootCenter];
            [tabBarItems addObject:item];
        }];
    }
    return tabBarItems;
    
}
/**
 *  配置每一个tabbaritem
 *
 *  @param item 选项
 *  @param data 数据
 */
+(void)configTabBarItem:(MSGTabBarItem*)item withData:(id)data center:(CenterController*)_rootCenter
{
    item.data = data;
    if ([data isMemberOfClass:[HomeConfigEntity class]]) {
        /**
         * 指向首页
         */
        HomeConfigEntity *home  = (HomeConfigEntity*)data;
        item.title = home.title;
        item.isHome = true;
        
        if (home.kind == AppHomeKindLimb) {
            /**
             *  如果首页指向一级频道
             */
            item.linkType = MenuBarTypeLimb;
            item.action = ^(HomeConfigEntity*home){
                [_rootCenter setSelectedIndex:1];
                LimbEntity *limb = [[LimbEntity alloc] init];
                limb.title = home.title;
                limb.lid = home.addr;
                LimbController *limbCon = _rootCenter.viewControllers[1];
                [limbCon reloadDataWithLimb:limb];
                [_rootCenter showTitleView];
            };
        }else{
            /**
             *  如果首页指向其他首页类型
             */
            item.linkType = MenuBarTypeHome;
            if (home.icon.selected_icon.length == 0) {
                item.selectedImage = [UIImage imageNamed:@"ic_home"];
            }
            item.action = ^(HomeConfigEntity*home){
                [_rootCenter setSelectedIndex:0];
                [_rootCenter showTitleView];
            };
        }
        [item setFinishedSelectedImageUrl:home.icon.normal_icon withFinishedUnselectedImage:home.icon.selected_icon];
    }else if ([data isMemberOfClass:[LimbEntity class]]) {
        /**
         *  指向以及频道
         *
         *  @param LimbEntity 一级
         *
         */
        LimbEntity *limb  = (LimbEntity*)data;
        item.title = limb.title;
        item.linkType = MenuBarTypeLimb;
        item.action = ^(LimbEntity*limb){
            [_rootCenter setSelectedIndex:1];
            LimbController *limbCon = _rootCenter.viewControllers[1];
            [limbCon reloadDataWithLimb:limb];
            [_rootCenter setTitle:limb.title];
            
        };
        [item setFinishedSelectedImageUrl:limb.icon.selected_icon withFinishedUnselectedImage:limb.icon.normal_icon];
        
    }else if([data isMemberOfClass:[WebAppEntity class]]){
        /**
         *  指向webapp
         *
         *  @param WebAppEntity
         *
         */
        WebAppEntity *app = (WebAppEntity*)data;
        item.title = app.title;
        item.linkType = MenuBarTypeWebApp;
        item.action = ^(WebAppEntity*app){
            [MSGTansitionManager openWebApp:app withParams:nil goBack:nil callBack:nil];
        };
        if (app.diyIcon) {
            [item setFinishedSelectedImageUrl:app.diyIcon.normal_icon withFinishedUnselectedImage:app.diyIcon.selected_icon];
        }else{
            [item setFinishedSelectedImageUrl:app.icon.normal_icon withFinishedUnselectedImage:app.icon.selected_icon];

        }
        
    }else if([data isMemberOfClass:[DiyPageEntity class]]){
        /**
         *  指向自定义页面
         *
         *  @param DiyPageEntity
         *
         */
        DiyPageEntity *page = (DiyPageEntity*)data;
        item.title = page.text;
        item.action = ^(DiyPageEntity*page){
            [MSGTansitionManager openDiyPage:page withParams:nil];
        };
        
        item.linkType = MenuBarTypeDiyPage;
        
        [item setFinishedSelectedImageUrl:page.icon.selected_icon withFinishedUnselectedImage:page.icon.normal_icon];
        
    }else if([data isMemberOfClass:[PubEntity class]]){
        /**
         * 只想各种类型收藏
         *
         *  @param PubEntity
         *
         */
        PubEntity *pub = (PubEntity*)data;
        item.title = pub.title;
        item.linkType = MenuBarTypePublication;
        item.action = ^(PubEntity*pub){
            
            [MSGTansitionManager openPubWithID:pub.pid withParams:nil];
        };
        
        [item setFinishedSelectedImageUrl:pub.icon.selected_icon withFinishedUnselectedImage:pub.icon.normal_icon];
        
    }else if([data isMemberOfClass:[ArticleEntity class]]){
        /**
         * 只想各种类型收藏
         *
         *  @param PubEntity
         *
         */
        ArticleEntity *article = (ArticleEntity*)data;
        item.title = article.title;
        item.linkType = MenuBarTypeLink;
        NSString *link = CRArrayObject(article.links, 0);
        item.action = ^(ArticleEntity*msg){
            if (link&&[link length]>0) {
                [MSGTansitionManager openLink:link];
            }
        };
        
        [item setFinishedSelectedImageUrl:article.icon.selected_icon withFinishedUnselectedImage:article.icon.normal_icon];
        
    }else if([data isMemberOfClass:[BaseTabItemEntity class]]){
        /**
         *  指向基础功能
         *
         *  @param BaseTabItemEntity
         *
         */
        BaseTabItemEntity *tab = (BaseTabItemEntity*)data;
        item.title = tab.title;
        item.linkType = MenuBarTypeBase;
        item.action = ^(id data){
            BaseTabItemEntity *tab = (BaseTabItemEntity*)data;
            [tab doAction];
        };
        [item setFinishedSelectedImageUrl:tab.icon.selected_icon withFinishedUnselectedImage:tab.icon.normal_icon];
    }else if([data isMemberOfClass:[LeafEntity class]]){
        
        /**
         *  指向二级
         */
        LeafEntity *leaf = (LeafEntity*)data;
        item.title = leaf.title;
        item.linkType = MenuBarTypeLeaf;
        item.action = ^(id data){
            LeafEntity *leaf = (LeafEntity*)data;
            [MSGTansitionManager openLeafWithID:leaf.lid withParams:nil];
        };
        [item setFinishedSelectedImageUrl:leaf.icon.selected_icon withFinishedUnselectedImage:leaf.icon.normal_icon];
        
    }
    
    if (kCurApp.sideBar.selected_bgcolor) {
        item.selectedTitleAttributes = @{NSFontAttributeName:MSGHTFont(10),NSForegroundColorAttributeName:[UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor]};
    }else{
        item.selectedTitleAttributes = @{NSFontAttributeName:MSGHTFont(10)};
    }
    item.unselectedTitleAttributes = @{NSFontAttributeName:MSGHTFont(10),NSForegroundColorAttributeName: [UIColor colorFromHexRGB:@"999999"]};
    
}
 


#pragma mark - 出现错误退出
/**
 * 出现错误退出
 */
-(void)startFailed:(NSString*)msg{
    //发生错误退出
    _callBack(false);
    [GVAlertView showAlert:nil message:msg confirmButton:@"确定" action:^{
        CRLog(@"确认退出");
        self.callBack(false);
    } cancelTitle:nil action:nil];
    
}

#pragma mark - 强制退出客户端
/**
 *  强制退出客户端
 */
-(void)exite{
    
    _targetViewController.view.window.transform = CGAffineTransformMakeScale(1,1);
    [UIView animateWithDuration:.5 animations:^{
        _targetViewController.view.window.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            exit(0);
        }
    }];
}
@end
