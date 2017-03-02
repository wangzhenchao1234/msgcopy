//
//  KKRequestManager.m
//  Kaoke
//
//  Created by Gavin on 14/12/3.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "MSGRequestManager.h"

@implementation MSGRequestManager

+(BOOL)isNetworkEnabled
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFNetworkReachabilityManager *reachaManager = manager.reachabilityManager;
    if (reachaManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {

        return false;
    }

    return true;
}

+(void)Get:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed{
    CRLog(@"Get Api : %@\nParams: %@",api,params);

    if (![MSGRequestManager isNetworkEnabled]) {
        failed(@"网络连接已断开",10000,nil,nil);
        return;
    }
    NSURL *url = CRURL(api);
    if ([url.host isEqualToString:WEBAPP_HOST]) {
        [GCookieManager setCookie:api];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:api parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *msg = nil;
        success(msg,operation.response.statusCode,responseObject,api);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *msg = error.localizedDescription;
        id data = nil;
        failed(msg,operation.response.statusCode,data,api);
    }];
}

+(void)Post:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed{
    CRLog(@"Post Api : %@",api);

    if (![MSGRequestManager isNetworkEnabled]) {
        failed(@"网络连接已断开",10000,nil,nil);
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:api parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([api rangeOfString:@"user/login/"].location != NSNotFound) {
            NSMutableString *cookie  = [[operation.response allHeaderFields] valueForKey:@"Set-Cookie"];
            [GCookieManager storeCookie:cookie];
        }
        NSString *msg = nil;
        success(msg,operation.response.statusCode,responseObject,api);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *msg = error.localizedDescription;
        if (operation.response.statusCode == 400) {
            msg = [MSGRequestManager handleBadRequest:operation.responseData];
        }
        id data = nil;
        failed(msg,operation.response.statusCode,data,api);
    }];
}

+(void)Update:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed{
    CRLog(@"Get Api : %@",api);

    if (![MSGRequestManager isNetworkEnabled]) {
        failed(@"网络连接已断开",10000,nil,nil);
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager PUT:api parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *msg = nil;
        success(msg,operation.response.statusCode,responseObject,api);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *msg = error.localizedDescription;
        id data = nil;
        msg = [MSGRequestManager handleBadRequest:operation.responseData];
        failed(msg,operation.response.statusCode,data,api);
    }];
}
+(void)MKGet:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed{
    CRLog(@"Get Api : %@",api);
    
    if (![MSGRequestManager isNetworkEnabled]) {
        failed(@"网络连接已断开",10000,nil,nil);
        return;
    }
    NSURL *url = CRURL(api);
    if ([url.host isEqualToString:WEBAPP_HOST]) {
        [GCookieManager setCookie:api];
    }
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
    MKNetworkOperation *op = [[MKNetworkOperation alloc] initWithURLString:api params:params httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        success(nil,0,completedOperation.responseData,api);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSString *msg = error.localizedDescription;
        msg = [MSGRequestManager handleBadRequest:completedOperation.responseData];
        failed(msg,completedOperation.HTTPStatusCode,completedOperation.responseData,api);
    }];
    [engine enqueueOperation:op];
    
}

+(void)MKPost:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed{
    CRLog(@"Post Api : %@",api);
    
    if (![MSGRequestManager isNetworkEnabled]) {
        failed(@"网络连接已断开",10000,nil,nil);
        return;
    }
    NSURL *url = CRURL(api);
    if ([url.host isEqualToString:WEBAPP_HOST]) {
        [GCookieManager setCookie:api];
    }
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
    MKNetworkOperation *op = [[MKNetworkOperation alloc] initWithURLString:api params:params httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
        if ([api rangeOfString:@"user/login/"].location != NSNotFound) {
            NSMutableString *cookie  = [[completedOperation.readonlyResponse allHeaderFields] valueForKey:@"Set-Cookie"];
            [GCookieManager storeCookie:cookie];
        }
        success(nil,completedOperation.HTTPStatusCode,completedOperation.responseData,api);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSString *msg = error.localizedDescription;
        msg = [MSGRequestManager handleBadRequest:completedOperation.responseData];
        failed(msg,completedOperation.HTTPStatusCode,completedOperation.responseData,api);
    }];
    [engine enqueueOperation:op];
    
}
+(void)MKUpdate:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed{
    CRLog(@"PUT Api : %@",api);
    
    if (![MSGRequestManager isNetworkEnabled]) {
        failed(@"网络连接已断开",10000,nil,nil);
        return;
    }
    NSURL *url = CRURL(api);
    if ([url.host isEqualToString:WEBAPP_HOST]) {
        [GCookieManager setCookie:api];
    }
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
    MKNetworkOperation *op = [[MKNetworkOperation alloc] initWithURLString:api params:params httpMethod:@"PUT"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data = completedOperation.responseData;
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        success(msg.description,0,completedOperation.responseData,api);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSString *msg = error.localizedDescription;
        msg = [MSGRequestManager handleBadRequest:completedOperation.responseData];
        failed(msg.description,completedOperation.HTTPStatusCode,completedOperation.responseData,api);
    }];
    [engine enqueueOperation:op];
    
}
+(void)MKDelete:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed{
    CRLog(@"PUT Api : %@",api);
    
    if (![MSGRequestManager isNetworkEnabled]) {
        failed(@"网络连接已断开",10000,nil,nil);
        return;
    }
    NSURL *url = CRURL(api);
    if ([url.host isEqualToString:WEBAPP_HOST]) {
        [GCookieManager setCookie:api];
    }
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] init];
    MKNetworkOperation *op = [[MKNetworkOperation alloc] initWithURLString:api params:params httpMethod:@"Delete"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        success(nil,0,completedOperation.responseData,api);
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSString *msg = error.localizedDescription;
        msg = [MSGRequestManager handleBadRequest:completedOperation.responseData];
        failed(msg,completedOperation.HTTPStatusCode,completedOperation.responseData,api);
    }];
    [engine enqueueOperation:op];
}

+(NSString*) handleBadRequest:(NSData*) jsonData
{
    NSError *error = nil;
    
    if (jsonData) {
        
        id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        
        if (error) {
            NSLog(@"error is %@", [error localizedDescription]);
            
            // Handle Error and return
            return error.localizedDescription;
            
        }
        
        NSArray *keys = [jsonObjects allKeys];
        
        // values in foreach loop
        NSString* outString = @"";
        for (NSString *key in keys) {
            id value = [jsonObjects objectForKey:key];
            if([value isKindOfClass:[NSArray class]])
            {
                NSArray* contents = value;
                for(NSString *content in contents)
                {
                    
                    outString = [NSString stringWithFormat:@"%@ %@", outString, content];
                }
            }
            else if([value isKindOfClass:[NSString class]])
            {
                outString = value;
            }
        }
        return outString;
        
    } else {
        // Handle Error
    }
    return @"";
    
}

@end
