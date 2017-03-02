//
//  DiyLeafContentEntity.h
//  Kaoke
//
//  Created by wngzc on 14/12/3.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LeafEntity;

@interface DiyLeafContentEntity : NSObject
@property(nonatomic,assign)NSInteger lid;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,retain)LeafEntity *leaf;
+(instancetype)buildByJson:(NSDictionary*)json;
@end
