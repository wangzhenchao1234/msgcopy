//
//  GCookieManager.h
//  msgcopy
//
//  Created by wngzc on 15/4/8.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCookieManager : NSObject
+(void)storeCookie:(NSString*)cookieString; //保存cookie
+(void)setCookie:(NSString *)url;                                 //设置cookie
+(void)clearCookiesForUrl:(NSString *)url;                        //清理cookie
@end
