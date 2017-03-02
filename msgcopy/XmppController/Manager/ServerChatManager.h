//
//  ServerChatManager.h
//  Kaoke
//
//  Created by Gavin on 14/10/28.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerChatManager : NSObject

@property (nonatomic,retain) NSMutableArray *serverGroups;

+(ServerChatManager*)sharedManager;
-(void)refresh;

@end
