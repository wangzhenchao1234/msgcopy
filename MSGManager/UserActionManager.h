//
//  UserActionManager.h
//  msgcopy
//
//  Created by Gavin on 15/8/19.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserActionManager : NSObject
+(void)applicationRecordPubRead:(PubEntity*)pub;
+(void)userRecordPubRead:(PubEntity*)pub;
+(void)userRecordPubArticle:(PubEntity*)pub;
+(void)userBrowsMap:(PubEntity*)pub;
+(void)userAddComments:(PubEntity*)pub;
+(void)userPubLike:(PubEntity*)pub;
+(void)userDoShareSina:(PubEntity*)pub;
+(void)userDoShareWeichat:(PubEntity*)pub;
+(void)userDoShareCircleFriends:(PubEntity*)pub;

@end
