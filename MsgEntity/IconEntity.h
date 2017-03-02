//
//  IconEntity.h
//  msgcopy
//
//  Created by Gavin on 15/4/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconEntity : NSObject
/**
 *  图标model
 */
@property (nonatomic,assign) NSInteger icid;//id
@property (nonatomic,copy  ) NSString *normal_icon;//正常图标
@property (nonatomic,copy  ) NSString *selected_icon;//选中图标
@property (nonatomic,copy  ) NSString *descr;//描述
+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end

@interface DiyIcon : NSObject
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *width;
@property(nonatomic,copy)NSString *height;
+(instancetype)buildByJson:(NSDictionary*)json;

@end
