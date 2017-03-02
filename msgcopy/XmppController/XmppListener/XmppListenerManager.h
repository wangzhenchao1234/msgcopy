//
//  XmppListenerManager.h
//  msgcopy
//
//  Created by Gavin on 15/5/27.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>
#import <XMPPFramework/XMPPRoomCoreDataStorage.h>
#import <XMPPFramework/XMPPReconnect.h>
#import <XMPPFramework/XMPPMUC.h>
#import <AVFoundation/AVFoundation.h>

#import "ContentManager.h"

//typedef void(^sendSuccessBlock)(NSString*sendMessageSuccessBlock);
@interface XmppListenerManager : NSObject<XMPPStreamDelegate,XMPPReconnectDelegate,UIAlertViewDelegate,XMPPRoomDelegate,XMPPMUCDelegate,XMPPRoomStorage>
{
    UserEntity *_user;
    NSMutableArray *_rosers;
    NSMutableArray *_rooms;
    NSMutableArray *_roomsJID;
    ContentManager *_contentManager;
    NSInteger _aid;
    NSDateFormatter *_formatter;
    AVAudioPlayer *_player;
    NSInteger _reconnectCount;
    SBJsonParser *_jsonParser;
    
}
//@property(nonatomic,copy)sendSuccessBlock sendMessageSuccessBlock;
@property (nonatomic,strong) NSThread *dataBaseThread;
@property (nonatomic,strong) XMPPStream *xmppStream;
@property (nonatomic,strong)XMPPReconnect *xmppReconnect;
@property BOOL isNetworkOK;
@property(nonatomic,copy)NSString*isHideFailureImage;
//-(void)sendMessageSuccess:(sendSuccessBlock)sendSuccessBlock;
+(XmppListenerManager*)sharedManager;
-(XMPPStream *)xmppStream;
-(ContentManager*)contentManager;
-(void)disconnect;
-(void)connectToServer;
-(void)setUser:(UserEntity *)user;
-(void)connectToRooms;

@end
