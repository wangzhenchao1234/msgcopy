//
//  ThumbnailEntity.h
//  msgcopy
//
//  Created by Gavin on 15/4/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThumbnailEntity : NSObject
@property (nonatomic,assign ) NSInteger tid;
@property (nonatomic,copy   ) NSString  * turl;
+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end
