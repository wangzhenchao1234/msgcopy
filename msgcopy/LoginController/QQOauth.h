//
//  QQOauth.h
//  msgcopy
//
//  Created by Gavin on 15/7/16.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QQOauth : NSObject
+(instancetype)sharedQQOauth;
- (void)doQQLoginOauth:(void(^)(BOOL reult,id data))complete shouldRegister:(void(^)(NSString*openID))registerBlock;
- (void)doQQBindOauth:(void(^)(BOOL reult,id data))complete;

@end
