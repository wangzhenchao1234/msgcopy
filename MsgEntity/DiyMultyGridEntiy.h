//
//  DiyMultyGridEnty.h
//  Kaoke
//
//  Created by Gavin on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiyMultyGridEntiy : NSObject
@property (nonatomic,assign)NSInteger rows;
@property (nonatomic,assign)NSInteger columns;
@property (nonatomic,copy)NSString *type;
@property (nonatomic,copy)NSString *bg_color;
@property (nonatomic,copy)NSString *bg_img;
@property (nonatomic,retain)NSDictionary *position;
@property (nonatomic,retain)NSMutableArray *controls;
@property(nonatomic,copy)NSDictionary *grid_position;
@property(nonatomic,retain)NSDictionary* padding;

+(DiyMultyGridEntiy*)buildByJson:(NSDictionary *)json;

@end
