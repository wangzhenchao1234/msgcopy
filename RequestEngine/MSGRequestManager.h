//
//  KKRequestManager.h
//  Kaoke
//
//  Created by Gavin on 14/12/3.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^requestComplete)(NSString*msg,NSInteger code, id data,NSString *requestURL);

@interface MSGRequestManager : NSObject
+(BOOL)isNetworkEnabled;
+(void)Get:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed;
+(void)Post:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed;
+(void)MKGet:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed;
+(void)MKPost:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed;
+(void)Update:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed;
+(void)MKUpdate:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed;
+(void)MKDelete:(NSString*)api params:(NSDictionary*)params success:(requestComplete)success failed:(requestComplete)failed;
@end
