//
//  DiyBannerEntity.h
//  Kaoke
//
//  Created by Gavin on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiyBannerEntity : NSObject
@property(nonatomic,retain)NSArray *items;
@property(nonatomic,assign)NSInteger interval;
@property(nonatomic,assign)NSInteger bid;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *bg_color;
@property(nonatomic,retain)NSDictionary *position;
@property (nonatomic,retain)NSDictionary *padding;
@property(nonatomic,copy)NSDictionary *grid_position;

+(DiyBannerEntity*)buildByJson:(NSDictionary*)json;
@end
