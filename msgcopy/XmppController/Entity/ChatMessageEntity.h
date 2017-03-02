//
//  Message.h
//  SOSimpleChatDemo
//
//  Created by Artur Mkrtchyan on 6/3/14.
//  Copyright (c) 2014 SocialOjbects Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessageEntity : NSObject

/**
 * Attributes for attributed message text
 */
@property (strong, nonatomic) NSDictionary *attributes;
/**
 * NSData from photo or video
 */
@property (strong, nonatomic) NSData  *media;

/**
 * Default thumbnail for media.
 */
@property (strong, nonatomic) UIImage *thumbnail;

/**
 * Boolean value that indicates who is the sender
 * This is important property and will be used to decide in which side show message.
 */
@property (nonatomic ,assign) BOOL fromMe;
@property (nonatomic ,assign) BOOL failed;
/**
 * Type of message.
 * Available values:
 * SOMessageTypeText, SOMessageTypePhoto, SOMessageTypeVideo
 */
@property (nonatomic,assign ) SOMessageType souceType;
@property (nonatomic,copy   ) NSString      *from;
@property (nonatomic,copy   ) NSString      *to;
@property (nonatomic,copy   ) NSString      *text;
@property (nonatomic,copy   ) NSString      *time;
@property (nonatomic,copy   ) NSString      *nickName;
@property (nonatomic,copy   ) NSString      *sourceTitle;
@property (nonatomic,copy   ) NSString      *sourceUrl;
@property (nonatomic,assign ) BOOL          isRead;
@property (nonatomic,copy   ) NSString      *username;
@property (nonatomic,copy   ) NSString      *avatar;
@property (nonatomic,copy   ) NSString      *extra;
@property (nonatomic,copy   ) NSString      *type;
@property (nonatomic,copy   ) NSString      *master;
@property (nonatomic,copy   ) NSString      *useagetype;
@property (nonatomic,copy   ) NSString      *contentJson;
@property (nonatomic,assign ) NSUInteger    cid;
@property(nonatomic,copy)NSString* isHideFailureImage;

+(ChatMessageEntity*)buildInstanceByJson:(NSDictionary*)json;
+(ChatMessageEntity*)buildWithXml:(XMPPMessage*)message;
@end
