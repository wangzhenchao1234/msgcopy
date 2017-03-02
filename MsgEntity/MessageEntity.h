//
//  MessageEntity.h
//  Kaoke
//
//  Created by xiaogu on 14-3-4.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageEntity : NSObject
@property (nonatomic,copy  ) NSString  *title;
@property (nonatomic,copy  ) NSString  *content;
@property (nonatomic,retain  ) UserEntity  *sender;
@property (nonatomic,assign) BOOL      isclient;
@property (nonatomic,assign) BOOL      isadmin;
@property (nonatomic,assign) BOOL      isall;
@property (nonatomic,assign) BOOL      isRead;
@property (nonatomic,assign) BOOL      isOpen;
@property (nonatomic,assign) NSInteger mid;
@property (nonatomic,copy  ) NSString  *link;
@property (nonatomic,retain) NSDate    *cTime;
+(MessageEntity*)buildInstanceByJson:(NSDictionary*)json;
@end
