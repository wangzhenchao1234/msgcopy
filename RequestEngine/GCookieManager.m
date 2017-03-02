//
//  GCookieManager.m
//  msgcopy
//
//  Created by Gavin on 15/4/8.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "GCookieManager.h"

@implementation GCookieManager

#pragma mark - 保存cookie信息
/**
 *  保存cookie
 *
 *  @param url          url地址
 *  @param cookieString cookie串
 */
+(void)storeCookie:(NSString*)cookieString
{
    NSArray *array = [cookieString componentsSeparatedByString:@"; "];
    NSMutableDictionary *cookieInfo = [[NSMutableDictionary alloc] init];
    for (NSMutableString *str in array) {
        if ([str rangeOfString:@"="].location!=NSNotFound) {
            NSArray *subArray = [str componentsSeparatedByString:@"="];
            if ([subArray[0] isEqualToString:@"sessionid"]) {
                NSLog(@"usercookie == %@",subArray[0]);
                [cookieInfo setObject:subArray[0] forKey:NSHTTPCookieName];
                [cookieInfo setObject:subArray[1] forKey:NSHTTPCookieValue];
            }else if([subArray[0] isEqualToString:@"expires"]){
                [cookieInfo setObject:subArray[1] forKey:NSHTTPCookieExpires];
            }else if([subArray[0] isEqualToString:@"Path"]){
                [cookieInfo setObject:@"/" forKey:NSHTTPCookiePath];
            }else if([subArray[0] isEqualToString:@"Max-Age"]){
                [cookieInfo setObject:subArray[1] forKey:NSHTTPCookieMaximumAge];
            }
        }
    }
    CRLog(@"store cookie == %@",cookieInfo);
    [LocalManager storeObject:cookieInfo forKey:kUserDefaultsCookie];
    
}
#pragma  mark - 设置cookie信息
/**
 *  设置cookie信息
 *
 *  @param url url地址
 */
+(void)setCookie:(NSString *)url
{
    NSURL *requestUrl = CRURL(url);
    NSMutableDictionary *cookieInfo = [LocalManager objectForKey:kUserDefaultsCookie];
    if (url) {
        NSLog(@" resq == %@ host == %@",url , requestUrl.host);
        [cookieInfo setObject:requestUrl.host forKey:NSHTTPCookieDomain];
    }
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieInfo];
    NSLog(@"set-cookie == %@",cookie);
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];

}
#pragma mark - 清理cookie信息
/**
 *  清理cookie信息
 *
 *  @param url url地址
 */
+(void)clearCookiesForUrl:(NSString *)url
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:CRURL(url)];
    for (int i = 0;i<cookies.count;i++) {
        NSHTTPCookie *cookie = cookies[i];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}
@end
