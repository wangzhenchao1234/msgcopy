//
//  WebAppEntity.h
//  msgcopy
//
//  Created by wngzc on 15/4/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IconEntity;

@interface WebAppEntity : NSObject
@property BOOL isCommend;
@property NSInteger orderCount;
@property BOOL isRequirelogin;
@property (nonatomic,copy  ) NSString  *adv;
@property (nonatomic,assign) NSInteger aid;
@property (nonatomic,copy  ) NSString  *descr;
@property (nonatomic,copy  ) NSString   *url;
@property (nonatomic,assign) NSInteger  opType;
@property (nonatomic,copy  ) NSString   *title;
@property (nonatomic,copy  ) NSString   *title_client;
@property (nonatomic,retain) IconEntity *icon;
@property (nonatomic,retain) IconEntity *diyIcon;
@property (nonatomic,retain) IconEntity *dropIcon;
@property (nonatomic,copy  ) NSString   *systitle;
@property (nonatomic,copy  ) NSMutableArray *ctypes;
+(WebAppEntity*)buildInstanceByJson:(NSDictionary*)json;
@end
@interface WebAppCtype : NSObject
@property (nonatomic,copy  ) NSString  *systitle;
@property (nonatomic,assign) NSInteger wid;
@property (nonatomic,copy  ) NSString  *title;
+(WebAppCtype *)buildInstanceByJson:(NSDictionary*)json;
@end