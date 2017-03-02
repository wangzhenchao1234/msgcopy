//
//  PermissionEntity.h
//  msgcopy
//
//  Created by wngzc on 15/4/13.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PermissionEntity;

@interface OldPermissionEntity : NSObject

@property (nonatomic       ) BOOL      login_switch;
@property (nonatomic,retain) NSArray   *leafs;

+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end

@interface PermissionEntity : NSObject

@property(nonatomic,assign)BOOL pread;
@property(nonatomic,assign)BOOL pcreate;
@property(nonatomic,assign)BOOL pupdate;
@property(nonatomic,assign)BOOL pdelete;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,assign)NSInteger pid;
@property(nonatomic,copy)NSString *descr;
@property(nonatomic,copy)NSString *systitle;

+(instancetype)buildWithJson:(NSDictionary*)json;

@end
