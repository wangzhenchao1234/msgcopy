//
//  DiySingleGridEntity.h
//  Kaoke
//
//  Created by wngzc on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiySingleGridEntity : NSObject
@property (nonatomic,retain)NSDictionary *padding;
@property(nonatomic,copy)NSString *hor_ico_align;
@property(nonatomic,copy)NSString *ver_tex_align;
@property(nonatomic,copy)NSString *ver_ico_align;
@property(nonatomic,copy)NSString *hor_tex_align;
@property(nonatomic,copy)NSString *bg_img;
@property(nonatomic,copy)NSString *text;
@property(nonatomic,assign)NSInteger font_size;
@property(nonatomic,copy)NSString *bg_color;
@property(nonatomic,copy)NSDictionary *grid_position;
@property(nonatomic,retain)NSDictionary *action;
@property(nonatomic,retain)NSDictionary *position;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,assign)NSInteger gid;
@property(nonatomic,retain)DiyIcon *icon;
@property(nonatomic,copy)NSString *font_color;
+(instancetype)buildByJson:(NSDictionary*)json;

@end