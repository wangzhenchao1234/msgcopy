//
//  ArticleMediaEntity.h
//  msgcopy
//
//  Created by Gavin on 15/4/21.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleMediaEntity : NSObject
@property (nonatomic,copy  ) NSString  *url;
@property (nonatomic,assign) NSInteger aid;
@property (nonatomic,copy  ) NSString  *descr;
@property (nonatomic,copy  ) NSString  *thumbnail;
@property (nonatomic,copy  ) NSString  *type;
+(instancetype)buildInstanceByJson:(NSDictionary*)json;
@end
