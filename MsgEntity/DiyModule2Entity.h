//
//  DiyListEntity.h
//  Kaoke
//
//  Created by wngzc on 14/12/2.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiyModule2Entity : NSObject

@property(nonatomic,copy)NSString *kind;
@property(nonatomic,copy)NSString *descr;
@property(nonatomic,copy)NSString *price;
@property(nonatomic,copy)NSString *text;
@property(nonatomic,copy)NSDictionary *grid_position;
@property(nonatomic,copy)NSString *bg_img;
@property(nonatomic,copy)NSDictionary *action;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,assign)NSInteger mid;
@property(nonatomic,retain)NSString *thumbnail;

+(DiyModule2Entity*)buildByJson:(NSDictionary *)json;
    

@end
