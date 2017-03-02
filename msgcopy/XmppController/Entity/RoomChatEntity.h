//
//  RoomChatEntity.h
//  Kaoke
//
//  Created by wngzc on 14/12/25.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomChatEntity : NSObject
@property(nonatomic,copy)NSString *c_user;
@property(nonatomic,copy)NSString *c_time;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *roomname;
@property(nonatomic,copy)NSString *headphoto;
@property(nonatomic,copy)NSString *groupstatus;
@property(nonatomic,assign)NSInteger rid;
+(instancetype)buildByJson:(NSDictionary*)json;
@end
