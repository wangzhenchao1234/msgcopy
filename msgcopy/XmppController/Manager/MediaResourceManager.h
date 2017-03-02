//
//  MediaResourceManager.h
//  Kaoke
//
//  Created by xiaogu on 14-9-19.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatMessageEntity;

@interface MediaResourceManager : NSObject{
    void(^callBack)(BOOL result,NSArray *datas);
}
+(void)uploadAudioMessage:(ChatMessageEntity*)message complete:(void(^)(BOOL resulet,NSArray *datas))complete;
+(void)uploadImageMessage:(ChatMessageEntity*)message complete:(void(^)(BOOL resulet,NSArray *datas))complete;
@end
