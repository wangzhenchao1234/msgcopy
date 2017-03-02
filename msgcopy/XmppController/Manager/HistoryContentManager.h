//
//  HistoryContentManager.h
//  Kaoke
//
//  Created by xiaogu on 14-8-15.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@class ChatMessageEntity;
@interface HistoryContentManager : NSObject
@property (nonatomic, retain) FMDatabase *database;
@property (nonatomic, retain) NSArray    *data;
@property (nonatomic, retain) NSMutableArray *rooms;
+ (HistoryContentManager *)sharedManager;
-(void)getAllRoomsComplete:(requestComplete)cmp;
-(NSArray *)refreshHistory;
-(NSArray*)getAllServerHistoryWithRoser:(NSString*)roser isServer:(BOOL)server type:(NSString *)chatType;
-(NSArray*)getAllhistoryWithRoser:(NSString*)roser isServer:(BOOL)server type:(NSString *)chatType;
-(NSArray*)getAllServerHistoryWithRoser:(NSString*)roser from:(NSString*)from to:(NSString*)to isServer:(BOOL)server type:(NSString *)chatType;
-(BOOL)deleteChatHistryWithRoser:(NSString *)roser isServer:(BOOL)server type:(NSString*)type;
@end
