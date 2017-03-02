//
//  PubEntity.h
//  msgcopy
//
//  Created by wngzc on 15/4/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ArticleEntity.h"

@interface PubEntity : ArticleEntity
@property (nonatomic,assign) NSInteger      pid;
@property (nonatomic,assign) NSInteger      lid;
@property (nonatomic,assign) NSInteger      leafId;
@property (nonatomic,retain) NSDate         *idx;
@property (nonatomic,copy  ) NSString       *approve_desc;
@property (nonatomic,copy  ) NSString       *desrc;
@property (nonatomic,retain) ArticleEntity  *article;
@property (atomic,retain   ) NSMutableArray *pubrels;
@property (nonatomic,copy  ) NSString       *pubrelTitle;
@property (atomic,copy     ) NSString       *pubRelJson;
@property (nonatomic,assign ) BOOL               push;

+(instancetype)buildInstanceByJson:(NSDictionary*)json;
+(instancetype)buildInstanceByRelJson:(NSDictionary*)json;
-(void)getPubRel:(requestComplete)success failed:(requestComplete)failed;
@end
