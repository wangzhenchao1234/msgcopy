//
//  MCenterManager.h
//  msgcopy
//
//  Created by Gavin on 15/7/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MessageEntity;

@interface MCenterManager : NSObject
+(instancetype)sharedManager;
-(void)startService;
-(void)stopService;
-(BOOL)isOnService;
-(void)updateMessages:(void(^)(BOOL finished,NSArray *result))complete;
-(NSArray*)messages;
-(BOOL)deleteMessageWithID:(NSInteger)mid;
-(BOOL)readMessageWithID:(NSInteger)mid;
-(MessageEntity*)messageWithID:(NSInteger)mid;
-(NSArray*)unReadMessages;
-(NSArray*)messagesAtDate:(NSDate*)date;
-(NSArray*)messagesForPage:(NSInteger)page;
+(NSDate *)getInternetDate;
+(void)sendApplyToadmin:(NSString*)title content:(NSString *)content success:(requestComplete)success failed:(requestComplete)failed;
@end
