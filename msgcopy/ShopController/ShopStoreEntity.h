//
//  ShopStoreEntity.h
//  Kaoke
//
//  Created by wngzc on 15/3/10.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopStoreEntity : NSObject

@property (nonatomic,retain)NSDictionary *streetaddr;
@property (nonatomic,copy)NSString *ctime;
@property (nonatomic,copy)NSString *descr;
@property (nonatomic,retain)MSGAppEntity *app;
@property (nonatomic,retain)UserEntity *master;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,assign)NSInteger sid;
@property (nonatomic,copy)NSString *lat;
@property (nonatomic,copy)NSString *lng;
@property (nonatomic,retain)ThumbnailEntity *thumbnail;

+(instancetype)buildWithJson:(NSDictionary*)json;

@end
