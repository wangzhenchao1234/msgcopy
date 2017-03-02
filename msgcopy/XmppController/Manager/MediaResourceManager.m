//
//  MediaResourceManager.m
//  Kaoke
//
//  Created by xiaogu on 14-9-19.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "MediaResourceManager.h"
#import "ChatMessageEntity.h"
#import "RecordAudioSetting.h"
#import "MediaEntity.h"

@implementation MediaResourceManager
+(void)uploadAudioMessage:(ChatMessageEntity*)message complete:(void(^)(BOOL resulet,NSArray *datas))complete{
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
    NSString *urlString = [NSString stringWithFormat:@"%@media/", URL_API];
    NSString *type = @"media";
    NSString *extension = @"amr";
    NSData *data = [NSData dataWithContentsOfFile:[RecordAudioSetting getPathByFileName:message.sourceTitle ofType:@"amr"]];
    NSMutableDictionary *params         = [NSMutableDictionary dictionaryWithObjectsAndKeys:message.sourceTitle,@"title",type,@"ftype",@"iphone",@"source",nil];
    MKNetworkOperation *op              = [engine operationWithURLString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:params httpMethod:@"POST"];
    [op addData:data forKey:@"imgFile" mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"%@.%@",message.sourceTitle,extension]];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSLog(@"uploadcomplete");
        NSError *error = nil;
        NSDictionary* jsonMedia = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:&error];
        if ([jsonMedia respondsToSelector:@selector(objectForKey:)]) {
            MediaEntity* media = [MediaEntity buildInstanceByJson:jsonMedia];
            media.fType = extension;
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *originPath = [RecordAudioSetting getPathByFileName:message.sourceTitle ofType:@"amr"];
            NSString *name = [NSString getmd5WithString:media.url];
            NSString *path = [RecordAudioSetting getPathByFileName:name ofType:@"amr"];
            if ([manager fileExistsAtPath:originPath]) {
                NSError *error = nil;
                BOOL success = [manager copyItemAtPath:originPath toPath:path error:&error];
                if (success) {
                    complete(true,@[media,message]);
                    message.sourceUrl = media.url;
                }else{
                    complete(false,nil);
                }
            }else{
                complete(false,nil);
            }
        }else{
            complete(false,nil);
        }
        
    } onError:^(NSError *error) {
        complete(false,nil);
    }];
    [engine enqueueOperation:op];
}
+(void)uploadImageMessage:(ChatMessageEntity*)message complete:(void(^)(BOOL resulet,NSArray *datas))complete{
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
    NSString *urlString = [NSString stringWithFormat:@"%@media/", URL_API];
    NSString *extension = @"jpg";
    NSData *data = nil;
    NSString *type = @"image";
    data = [NSData dataWithContentsOfFile:[[MediaResourceManager getFileDir] stringByAppendingPathComponent:CRString(@"/%@",message.sourceTitle)]];
    NSMutableDictionary *params         = [NSMutableDictionary dictionaryWithObjectsAndKeys:message.sourceTitle,@"title",type,@"ftype",@"iphone",@"source",nil];
    MKNetworkOperation *op              = [engine operationWithURLString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:params httpMethod:@"POST"];
    [op addData:data forKey:@"imgFile" mimeType:@"multipart/form-data" fileName:[NSString stringWithFormat:@"%@.%@",message.sourceTitle,extension]];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        NSLog(@"uploadcomplete");
        NSError *error = nil;
        NSDictionary* jsonMedia = [NSJSONSerialization JSONObjectWithData:completedOperation.responseData options:NSJSONReadingMutableContainers error:&error];
        if ([jsonMedia respondsToSelector:@selector(objectForKey:)]) {
            MediaEntity* media = [MediaEntity buildInstanceByJson:jsonMedia];
            media.fType = extension;
            complete(true,@[media,message]);
            message.sourceUrl = media.url;
        }else{
            complete(false,nil);
        }
    } onError:^(NSError *error) {
        complete(false,nil);
    }];
    [engine enqueueOperation:op];
}
+(NSString*) getFileDir
{
    NSString *imgs = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/Images/"];
    NSLog(@"imgpath == %@",imgs);
    return imgs;
}
@end
