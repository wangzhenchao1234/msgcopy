//
//  StoreLimbEntity.h
//  Kaoke
//
//  Created by wngzc on 15/3/19.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreLimbEntity : NSObject

@property(nonatomic,assign)NSInteger storeID;//店铺id
@property(nonatomic,copy)NSString *descr;//limb描述
@property(nonatomic,copy)NSString *title;//limb名称
@property(nonatomic,assign)NSInteger lid; //limbID
@property(nonatomic,retain)NSMutableArray *publications;//一级投稿

+(instancetype)buildWithJson:(NSDictionary *)json;

@end
