//
//  GCookieManager.h
//  msgcopy
//
//  Created by Gavin on 15/4/8.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCookieManager : NSObject
+(void)storeCookie:(NSString*)cookieString; //保存cookie
+(void)setCookie:(NSString *)url;                                 //设置cookie
+(void)clearCookiesForUrl:(NSString *)url;                        //清理cookie
@end
