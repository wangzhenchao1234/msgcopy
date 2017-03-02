//
//  VerifyHanddler.h
//  msgcopy
//
//  Created by wngzc on 15/5/22.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VerifyHanddler : NSObject
+(BOOL)verifyied:(NSString *)str;
+(BOOL)verifyPhone:(NSString*)str;
+(BOOL)verifyEmail:(NSString*)email;
@end
