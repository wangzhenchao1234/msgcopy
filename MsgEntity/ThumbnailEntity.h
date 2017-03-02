//
//  ThumbnailEntity.h
//  msgcopy
//
//  Created by wngzc on 15/4/13.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThumbnailEntity : NSObject
@property (nonatomic,assign ) NSInteger tid;
@property (nonatomic,copy   ) NSString  * turl;
+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end
