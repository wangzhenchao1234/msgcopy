//
//  ChatServerEntity.h
//  Kaoke
//
//  Created by Gavin on 14/10/28.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatServerEntity : NSObject

@property (nonatomic,assign) NSInteger app_id;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,retain) NSMutableArray *users;
+(ChatServerEntity *)buildByinstans:(NSDictionary*)json;

@end
@interface ServerEntity : NSObject

@property (nonatomic,assign) NSInteger uid;
@property (nonatomic,copy) NSString *cs_name;
@property (nonatomic,copy) NSString *descr;
@property (nonatomic,copy) NSString *cs_group;
@property (nonatomic,copy) NSString *username;
@property (atomic,copy) NSString *headicon;

+(ServerEntity *)buildByinstans:(NSDictionary*)json;

@end