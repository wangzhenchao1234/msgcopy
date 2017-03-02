//
//  WeiChatOauth.h
//  msgcopy
//
//  Created by Gavin on 15/7/16.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiChatOauth : NSObject
+(void)doWeixinLogin:(void(^)(BOOL result, id data))complete shouldRegister:(void(^)(NSString*openID))registerBlock;
+(void)doBindWeiChat:(void(^)(BOOL result, id data))complete;
+(void)doDeBindWeiChat:(NSString*)openID complete:(void (^)(BOOL, id))complete;

@end
