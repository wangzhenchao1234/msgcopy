//
//  WeiChatOauth.h
//  msgcopy
//
//  Created by wngzc on 15/7/16.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiChatOauth : NSObject
+(void)doWeixinLogin:(void(^)(BOOL result, id data))complete shouldRegister:(void(^)(NSString*openID))registerBlock;
+(void)doBindWeiChat:(void(^)(BOOL result, id data))complete;
+(void)doDeBindWeiChat:(NSString*)openID complete:(void (^)(BOOL, id))complete;

@end
