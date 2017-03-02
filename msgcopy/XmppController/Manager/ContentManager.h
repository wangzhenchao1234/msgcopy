//
//  ContentManager.h
//  SOSimpleChatDemo
//
// Created by : arturdev
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@class ChatMessageEntity;
@class FMDatabaseQueue;

@interface ContentManager : NSObject
@property (nonatomic, retain) FMDatabase  *database;
+(ContentManager *)sharedManager;
+(FMDatabaseQueue *)getSharedInstance;
-(BOOL)excuteSql:(NSString *)sql;
-(NSInteger)getServerUnreadCount;
-(NSInteger)getUserUnreadCountType:(NSString*)type;
-(NSInteger)storeMessage:(ChatMessageEntity*)message;
-(BOOL)isContainMessage:(ChatMessageEntity*)message;
-(NSArray *)getDataWithSql:(NSString *)sql parameters:(NSArray *)params;
-(BOOL)deleteChatHistryWithRoser:(NSString *)roser type:(NSString*)type isServer:(BOOL)server;
-(NSInteger)getUnreadCountWithRoser:(NSString *)roser isServer:(BOOL)server type:(NSString*)type;
-(void)updateUnreadMessagesWithRoser:(NSString *)roser type:(NSString*)type isServer:(BOOL)server;
-(NSArray *)getUnreadMessagesWithRoser:(NSString *)roser type:(NSString*)type isServer:(BOOL)server;
-(NSMutableArray *)getAllMessagesWithRoser:(NSString *)roser type:(NSString*)type isServer:(BOOL)server;
-(NSMutableArray *)getAlGrouplMessagesWithRoser:(NSString *)roser;
-(NSArray *)getOlderMessagesWithRoser:(NSString *)roser isServer:(BOOL)server type:(NSString*)type fromIndex:(NSInteger)index;
@end
