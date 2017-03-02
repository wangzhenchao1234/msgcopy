//
//  UploadManager.h
//  Kaoke
//
//  Created by xiaogu on 14-2-26.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ServiceData;

@interface UploadManager : NSObject

+(void) uploadCommentMedia:(NSInteger)mediaId descr:(NSString*)descr fType:(NSString*)type thumnail:(NSData*)data success:(requestComplete)success failed:(requestComplete)failed;
+(void)uploadFile:(NSData*) data type:(NSString*)type name:(NSString *)name success:(requestComplete)success failed:(requestComplete)failed;
+(void) createArticleMedia:(NSInteger)mediaId descr:(NSString*)descr fType:(NSString*)type thumnail:(NSData*)data success:(requestComplete)success failed:(requestComplete)failed;
+(void) createArticleThumnail:(NSData*)thData success:(requestComplete)success failed:(requestComplete)failed;
@end
