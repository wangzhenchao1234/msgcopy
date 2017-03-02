//
//  LocalNotificationManager.h
//  msgcopy
//
//  Created by Gavin on 15/8/9.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotificationManager : NSObject
+(instancetype)sharedManager;
-(void)startService;
-(void)stopService;
-(BOOL)isOnService;
-(void)updateNotifications:(void(^)(BOOL finished,NSArray *result))complete;

@end
