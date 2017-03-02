//
//  MediaEntity.h
//  msgcopy
//
//  Created by wngzc on 15/4/21.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaEntity : NSObject

@property (nonatomic,assign) NSInteger mid;
@property (nonatomic,copy  ) NSString  * fType;
@property (nonatomic,copy  ) NSString  * url;
@property (nonatomic,assign) NSInteger size;
@property (nonatomic,copy  ) NSString  * title;
@property (nonatomic,copy  ) NSString  * ctime;
@property (nonatomic,copy  ) NSString  * html;
@property (nonatomic,copy  ) NSString  *jsonStr;

+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end
