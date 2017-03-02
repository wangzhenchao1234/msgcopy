//
//  PermissonManager.h
//  msgcopy
//
//  Created by Gavin on 15/4/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LeafEntity;
@class OldPermissionEntity;
@class PermissionEntity;

@interface PermissonManager : NSObject
@property(nonatomic,retain)OldPermissionEntity *oldPermission;//旧权限
@property(nonatomic,retain,setter=setAPermissions:)NSMutableArray *authorPermissions;//新权限
@property(nonatomic,assign)BOOL loginValid;//登录权限
@property(nonatomic,assign)BOOL creatPubValid;//投稿权限
@property(nonatomic,retain)NSMutableArray *authLimbs;//符合权限的一级
@property(nonatomic,retain)NSArray *customTabBarItems;//自定义功能兰项目

+(instancetype)sharedManager;
-(void)loadCache;
-(void)permissionForLeaf:(LeafEntity*)leaf;//过滤二级权限
-(BOOL)isNewPermssionValid;//新权限绑定关系
-(BOOL)isOldPermssionValid;//就权限绑定关系
-(BOOL)isCustoumFuncBarValid;//自定义功能栏绑定关系
-(void)checkAppPermisson:(void(^)(BOOL result))complete;
+(NSArray*)filterDiyFunctionBar;//过滤自定义功能栏
@end
