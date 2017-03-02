//
//  UploadManager.m
//  Kaoke
//
//  Created by xiaogu on 14-2-26.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "UploadManager.h"
#import "CommentEntity.h"
#import "MediaEntity.h"
#import "ArticleMediaEntity.h"

static  MKNetworkEngine *engine = nil;


#define HTTPREQUEST_TIMEOUT_INVERVAL 30

@implementation UploadManager

+(void) uploadCommentMedia:(NSInteger)mediaId descr:(NSString*)descr fType:(NSString*)type thumnail:(NSData*)data success:(requestComplete)success failed:(requestComplete)failed{
    
    NSString* requestUrlString;
    requestUrlString   = kAPIUploadCommentFile;
    if ([type isEqualToString:@"image"]) {

    }else if([type isEqualToString:@"media"]){
       type     = @"video";
    }else{
       type     = @"audio";
    }
    NSMutableDictionary *params         = [NSMutableDictionary dictionaryWithObjectsAndKeys:descr,@"descr",[NSString stringWithFormat:@"%d",mediaId],@"obj",type,@"type",nil];
    MKNetworkEngine *engine             = [UploadManager getHttpEngine];
    MKNetworkOperation *op              = [engine operationWithURLString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:params httpMethod:@"POST"];
    if ([type isEqualToString:@"video"]&&data) {
        [op addData:data forKey:@"imgFile" mimeType:@"multipart/form-data" fileName:@"thumbnail.png"];
    }
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSDictionary* jsonMedia = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        ArticleMediaEntity* media = [ArticleMediaEntity buildInstanceByJson:jsonMedia];
        success(nil,200,media,requestUrlString);

    } onError:^(NSError *error) {
    
        failed(error.localizedDescription,error.code,nil,requestUrlString);

    }];
    [engine enqueueOperation:op];
}
+(void)uploadFile:(NSData*)data type:(NSString*)type name:(NSString *)name success:(requestComplete)success failed:(requestComplete)failed
{
    
    NSString *urlString = kAPIUploadFile;
    NSString *ftype     = nil;
    NSString *source    = @"iphone";
    if ([type isEqualToString:@"image"]) {
        ftype    = @"image";
    }else{
        ftype    = @"media";
    }
    NSMutableDictionary *params         = [NSMutableDictionary dictionaryWithObjectsAndKeys:name,@"title",ftype,@"ftype",source,@"source",nil];
    MKNetworkEngine *engine             = [UploadManager getHttpEngine];
    MKNetworkOperation *op              = [engine operationWithURLString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:params httpMethod:@"POST"];
    if (data) {
        [op addData:data forKey:@"imgFile" mimeType:@"multipart/form-data" fileName:name];
    }
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSDictionary* jsonMedia = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        MediaEntity* media = [MediaEntity buildInstanceByJson:jsonMedia];
        success(nil,200,media,urlString);

    } onError:^(NSError *error) {
        
        failed(error.localizedDescription,error.code,nil,urlString);
        
    }];
    [engine enqueueOperation:op];
}

+(void) createArticleMedia:(NSInteger)mediaId descr:(NSString*)descr fType:(NSString*)type thumnail:(NSData*)data success:(requestComplete)success failed:(requestComplete)failed{
    NSString* requestUrlString;
    if ([type isEqualToString:@"media"]) {
        type = @"video";
    }
    requestUrlString   = [NSString stringWithFormat:@"%@article/%@/?%@",URL_API,type,URL_CHANNEL];
    NSLog(@"sourceUrl == %@",requestUrlString);
    NSMutableDictionary *params         = [NSMutableDictionary dictionaryWithObjectsAndKeys:descr,@"descr",[NSString stringWithFormat:@"%d",mediaId],@"obj",nil];
    MKNetworkEngine *engine             = [UploadManager getHttpEngine];
    MKNetworkOperation *op              = [engine operationWithURLString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:params httpMethod:@"POST"];
    if ([type isEqualToString:@"video"]) {
        [op addData:data forKey:@"imgFile" mimeType:@"multipart/form-data" fileName:@"thumbnail.png"];
    }
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSDictionary* jsonMedia = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        ArticleMediaEntity* media = [ArticleMediaEntity buildInstanceByJson:jsonMedia];
        success(nil,200,media,requestUrlString);

    } onError:^(NSError *error) {
        failed(error.localizedDescription,error.code,nil,requestUrlString);

    }];
    [engine enqueueOperation:op];
}
+(void) createArticleThumnail:(NSData*)thData success:(requestComplete)success failed:(requestComplete)failed{
    
    NSString *requestUrlString   = [NSString stringWithFormat:@"%@article/thumbnail/?%@",URL_API,URL_CHANNEL];
    MKNetworkEngine *engine             = [UploadManager getHttpEngine];
    MKNetworkOperation *op              = [engine operationWithURLString:[requestUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:nil httpMethod:@"POST"];
    [op addData:thData forKey:@"imgFile" mimeType:@"multipart/form-data" fileName:@"thumbnail.png"];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        NSDictionary* jsonMedia = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:nil];
        ThumbnailEntity* media = [ThumbnailEntity buildInstanceByJson:jsonMedia];
        success(nil,200,media,requestUrlString);
        
    } onError:^(NSError *error) {
        
        failed(error.localizedDescription,error.code,nil,requestUrlString);
        
    }];
    [engine enqueueOperation:op];
}
+(MKNetworkEngine*)getHttpEngine{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
    });
    return engine;
}
@end
