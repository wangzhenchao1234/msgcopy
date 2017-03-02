//
//  XMContntController.m
//  msgcopy
//
//  Created by Gavin on 15/6/12.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "XMContntController.h"
#import "JSQMessages.h"
#import "ChatMessageEntity.h"
#import "JSQAudioMediaItem.h"
#import "JSQPhotoMediaItem.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "RecordAudioSetting.h"
#import "MediaResourceManager.h"
@interface XMContntController ()<UIActionSheetDelegate>
{
    SBJsonWriter *_jsonWriter;
    JSQAudioMediaItem *playingAudoiItem;
    dispatch_queue_t uploadqueue;
    dispatch_group_t group;
    BOOL _isHideFailureImage;
    
}
@property(nonatomic,retain)NSMutableArray *messages;
@end

@implementation XMContntController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.senderId = kCurUserName;
    self.usage_type = @"normal";
    self.title = self.senderDisplayName;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(40, 40);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(40, 40);
    self.showLoadEarlierMessagesHeader = false;
    _jsonWriter = [[SBJsonWriter alloc] init];
    uploadqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    group = dispatch_group_create();
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    
    _jsonWriter = [[SBJsonWriter alloc] init];
    /**
     *  Register custom menu actions for cells.
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
    [UIMenuController sharedMenuController].menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action" action:@selector(customAction:)] ];
    NSDateFormatter *formmater = [[NSDateFormatter alloc] init];
    formmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    _messages = [NSMutableArray new];
    
    NSArray *messages = [[ContentManager sharedManager] getAllMessagesWithRoser:_roser type:@"chat" isServer:false];
    CRWeekRef(self);
    [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ChatMessageEntity *message = obj;
       
        NSDate *date = [formmater dateFromString:message.time];
        JSQMessage *msg = nil;
        if (message.souceType == SOMessageTypePhoto) {
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImageUrl:message.sourceUrl complete:^(BOOL result, UIImage *image) {
                [__self.collectionView reloadData];
            }];
            photoItem.appliesMediaViewMaskAsOutgoing = message.fromMe;
            msg = [JSQMessage messageWithSenderId:message.from
                                      displayName:message.nickName
                                           avatar:message.avatar
                                            media:photoItem];
        }else if(message.souceType == SOMessageTypeVideo){
          CRLog(@"视频 url = %@",message.sourceUrl);
          
          
          
          }else if(message.souceType == SOMessageTypeAudio){
              JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithURL:CRURL(message.sourceUrl) length:[message.extra integerValue] isReadyToPlay:true];
              
              audioItem.appliesMediaViewMaskAsOutgoing = message.fromMe;
              msg = [JSQMessage messageWithSenderId:message.from
                                        displayName:message.nickName
                                             avatar:message.avatar
                                              media:audioItem];
              
          }else{
              msg = [[JSQMessage alloc] initWithSenderId:message.from
                                       senderDisplayName:message.nickName
                                                  avatar:message.avatar
                                                    date:date
                                                    text:message.text];
          }
        msg.isHideFailureImage = message.isHideFailureImage;
        [_messages addObject:msg];
        
    }];
    messages = nil;
    
    [[ContentManager sharedManager] updateUnreadMessagesWithRoser:_roser type:@"chat" isServer:false];
    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */
    
    /**
     *  Set a maximum height for the input toolbar
     *
     *  self.inputToolbar.maximumHeight = 150;
     */
    
}
-(void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:kChatMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notHideSendFailureImage:) name:NOTIFICATION_CHAT_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSendFailureImage:) name:NOTIFICATION_CHAT_SUCCESS object:nil];
    
}
-(void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChatMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CHAT_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CHAT_SUCCESS object:nil];
    
}
-(void)hideSendFailureImage:(NSNotification*)notification{
    ChatMessageEntity*message = notification.object;
    if (_messages.count!=0) {
        JSQMessage*msg =[_messages lastObject];
        NSLog(@"msg=====%@",msg);
        [_messages removeLastObject];
        NSLog(@"removeLastObject_messages=====%@",_messages);
        
        msg.isHideFailureImage = message.isHideFailureImage;
        [_messages addObject:msg];
        NSLog(@"addObject_messages=====%@",_messages);
        [self.collectionView reloadData];
        
    }
   }
-(void)notHideSendFailureImage:(NSNotification*)notification{
    ChatMessageEntity*message = notification.object;
    if (_messages.count!=0) {
        JSQMessage*msg =[_messages lastObject];
        NSLog(@"msg=====%@",msg);
        [_messages removeLastObject];
        NSLog(@"removeLastObject_messages=====%@",_messages);
        
        msg.isHideFailureImage = message.isHideFailureImage;
        [_messages addObject:msg];
        NSLog(@"addObject_messages=====%@",_messages);
        [self.collectionView reloadData];
        
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerNotifications];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = true;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeNotifications];
    
}
-(void)dealloc
{
    NSLog(@"deallco");
}

#pragma mark - Testing

- (void)pushMainViewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:nc.topViewController animated:YES];
}


#pragma mark - Actions

- (void)receiveMessage:(NSNotification *)notify
{
    
    ChatMessageEntity *message = notify.object;
    if (![message.from isEqualToString:_roser]||![message.useagetype isEqualToString:@"normal"]||![message.type isEqualToString:@"chat"]) {
        return;
    }
    [[ContentManager sharedManager] updateUnreadMessagesWithRoser:_roser type:@"chat" isServer:false];
    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = !self.showTypingIndicator;
    
    /**
     *  Scroll to actually view the indicator
     */
    [self scrollToBottomAnimated:YES];
    
    /**
     *  Allow typing indicator to show
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        JSQMessage *newMessage = nil;
        NSDateFormatter *formmater = [[NSDateFormatter alloc] init];
        formmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *date = [formmater dateFromString:message.time];
        
        JSQMessage *msg = nil;
        CRWeekRef(self);
        if (message.souceType == SOMessageTypePhoto) {
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImageUrl:message.sourceUrl complete:^(BOOL result, UIImage *image) {
                [__self.collectionView reloadData];
            }];
            photoItem.appliesMediaViewMaskAsOutgoing = false;
            msg = [JSQMessage messageWithSenderId:message.from
                                      displayName:message.nickName
                                           avatar:message.avatar
                                            media:photoItem];
            
            
        }/*else if(message.souceType == SOMessageTypeVideo){
          CRLog(@"视频 url = %@",message.sourceUrl);
          
          
          
          }*/else if(message.souceType == SOMessageTypeAudio){
              JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithURL:CRURL(message.sourceUrl) length:[message.extra integerValue] isReadyToPlay:true];
              
              audioItem.appliesMediaViewMaskAsOutgoing = message.fromMe;
              msg = [JSQMessage messageWithSenderId:message.from
                                        displayName:message.nickName
                                             avatar:message.avatar
                                              media:audioItem];
              
          }else{
              msg = [[JSQMessage alloc] initWithSenderId:message.from
                                       senderDisplayName:message.nickName
                                                  avatar:message.avatar
                                                    date:date
                                                    text:message.text];
          }
        
        id newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        if (msg.isMediaMessage) {
            /**
             *  Last message was a media message
             */
            id<JSQMessageMediaData> copyMediaData = msg.media;
            
            if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                JSQPhotoMediaItem *photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
                photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
                
                /**
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view
                 */
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy;
            }
            /*else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
             JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
             locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
             newMediaAttachmentCopy = [locationItemCopy.location copy];
             
             locationItemCopy.location = nil;
             
             newMediaData = locationItemCopy;
             }
             else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
             JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
             videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
             newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
             
             videoItemCopy.fileURL = nil;
             videoItemCopy.isReadyToPlay = NO;
             
             newMediaData = videoItemCopy;
             }*/
            else {
                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
            }
            
            newMessage = [JSQMessage messageWithSenderId:message.from
                                             displayName:message.nickName
                                                  avatar:message.avatar
                                                   media:copyMediaData];
        }
        else {
            /**
             *  Last message was a text message
             */
            newMessage = [JSQMessage messageWithSenderId:message.from
                                             displayName:message.nickName
                                                  avatar:message.avatar
                                                    text:message.text];
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        newMessage.isHideFailureImage = message.isHideFailureImage;
        [_messages addObject:newMessage];
        [__self finishReceivingMessageAnimated:YES];
        
    });
}

- (void)sendMessage:(ChatMessageEntity *)message
{
    [[ContentManager sharedManager] updateUnreadMessagesWithRoser:_roser type:@"chat" isServer:false];
    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = false;
    
    /**
     *  Scroll to actually view the indicator
     */
    [self scrollToBottomAnimated:YES];
    
    /**
     *  Allow typing indicator to show
     */
    CRWeekRef(self);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDateFormatter *formmater = [[NSDateFormatter alloc] init];
        formmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *date = [formmater dateFromString:message.time];
        
        JSQMessage *msg = nil;
        if (message.souceType == SOMessageTypePhoto) {
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImageUrl:message.sourceUrl complete:^(BOOL result, UIImage *image) {
                [__self.collectionView reloadData];
            }];
            photoItem.appliesMediaViewMaskAsOutgoing = true;
            msg = [JSQMessage messageWithSenderId:message.from
                                      displayName:message.nickName
                                           avatar:message.avatar
                                            media:photoItem];
            
            
        }/*else if(message.souceType == SOMessageTypeVideo){
          CRLog(@"视频 url = %@",message.sourceUrl);
          
          
          
          }*/else if(message.souceType == SOMessageTypeAudio){
              JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithURL:CRURL(message.sourceUrl) length:[message.extra integerValue] isReadyToPlay:true];
              
              audioItem.appliesMediaViewMaskAsOutgoing = true;
              msg = [JSQMessage messageWithSenderId:message.from
                                        displayName:message.nickName
                                             avatar:message.avatar
                                              media:audioItem];
              
          }else{
              msg = [[JSQMessage alloc] initWithSenderId:message.from
                                       senderDisplayName:message.nickName
                                                  avatar:message.avatar
                                                    date:date
                                                    text:message.text];
          }
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        [_messages addObject:msg];

        [__self finishReceivingMessageAnimated:YES];
        
    });
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                        avatar:kCurUser.head50
                                                          date:date
                                                          text:text];
    
    [self.messages addObject:message];

    NSDateFormatter *formmater = [[NSDateFormatter alloc] init];
    formmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    UserEntity *user = kCurUser;
    NSMutableDictionary *bodyDict = [NSMutableDictionary new];
    NSString *content = text;
    [bodyDict setObject:content forKey:@"content"];
    [bodyDict setObject:[formmater stringFromDate:date] forKey:@"time"];
    [bodyDict setObject:(user.head100?user.head100:@"") forKey:@"avatar"];
    [bodyDict setObject:user.firstName forKey:@"nickname"];
    [bodyDict setObject:@"" forKey:@"url"];
    [bodyDict setObject:@"txt" forKey:@"type"];
    [bodyDict setObject:@"" forKey:@"extra"];
    [bodyDict setObject:@"normal" forKey:@"usage_type"];
    [bodyDict setObject:kCurUser.userName forKey:@"username"];
    [bodyDict setObject:text forKey:@"contet"];
    NSString *bodyJson = [_jsonWriter stringWithObject:bodyDict];
    [bodyDict removeAllObjects];
    bodyDict = nil;
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:bodyJson];
    NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
    [messageElement addAttributeWithName:@"type" stringValue:@"chat"];
    NSString *toname = [NSString convertName:_roser];
    NSString *to = [NSString stringWithFormat:@"%d|%@@%@",kCurAppID,toname,XMPP_SERVER_HOST_ME];
    [messageElement addAttributeWithName:@"to" stringValue:to];
    [messageElement addChild:body];
    [[XmppListenerManager sharedManager].xmppStream sendElement:messageElement];
    [self finishSendingMessageAnimated:YES];
}
#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    return [JSQMessagesAvatarImageFactory avatarImageWithImage:message.avatar diameter:30];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    JSQMessage *message = CRArrayObject(_messages, indexPath.item);
    if (indexPath.item == 0) {
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }else{
        JSQMessage *last = CRArrayObject(_messages, indexPath.item-1);
        if ([message.date timeIntervalSinceDate:last.date]>=60) {
            return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
        }
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _messages.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
//     NSArray *messages = [[ContentManager sharedManager] getAllMessagesWithRoser:_roser type:@"chat" isServer:false];
//    ChatMessageEntity *message = CRArrayObject(messages,indexPath.row);
    //NSLog(@"message====%@",message.isHideFailureImage);
    JSQMessage *msg =  CRArrayObject(_messages, indexPath.row);
    
      if (!msg.isMediaMessage) {
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
    }
    if ([msg.isHideFailureImage isEqualToString:@"null"] || [msg.isHideFailureImage isEqualToString:@"nil"] || msg.isHideFailureImage.length == 0) {
        cell.sendFailureImage.hidden = YES;
    }else{
     cell.sendFailureImage.hidden = [msg.isHideFailureImage intValue];
    
    }
   
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:@"Custom Action"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    JSQMessage *message = CRArrayObject(_messages, indexPath.item);
    if (indexPath.item == 0) {
        return 64;
    }else{
        JSQMessage *last = CRArrayObject(_messages, indexPath.item-1);
        if ([message.date timeIntervalSinceDate:last.date]>=60) {
            return 64;
        }
    }
    return 30;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    return 0;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    JSQMessage *message = CRArrayObject(_messages, indexPath.row);
    if ([message isMediaMessage]) {
        JSQMediaItem *media = (JSQMediaItem*)[message media];
        if ([media isKindOfClass:[JSQAudioMediaItem class]]) {
            JSQAudioMediaItem *audio = (JSQAudioMediaItem*)media;
            if ([audio.fileURL.absoluteString isEqualToString:playingAudoiItem.fileURL.absoluteString]&&playingAudoiItem.isPlaying) {
                return;
            }
            if (playingAudoiItem&&playingAudoiItem.isPlaying) {
                [playingAudoiItem stop];
                return;
            }
            [audio play];
            playingAudoiItem = audio;
            
        }else if([media isKindOfClass:[JSQPhotoMediaItem class]]){
            
            JSQPhotoMediaItem *photoItem = (JSQPhotoMediaItem*)media;
            NSString *url = photoItem.imageUrl;
            MJPhoto *photo = [[MJPhoto alloc] init];
            if ([url rangeOfString:@"http"].location!= NSNotFound) {
                photo.url = [NSURL URLWithString:url];
            }else{
                photo.fileUrl = url;
            }
            photo.srcImageView = photoItem.cachedImageView;
            MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
            browser.currentPhotoIndex = 0;
            browser.photos = @[photo];
            browser.titles = @[@""];
            browser.descrs = @[@""];
            [browser show];
        }
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

//
//
//
//
//
//
//
//
//
//
//



#pragma mark - mediaMessage

-(void)sendVoice:(NSString *)name time:(NSInteger)time{
    
    //发送音频
    UserEntity *user = kCurUser;
    ChatMessageEntity *entity = [[ChatMessageEntity alloc] init];
    entity.from = [NSString convertName:user.userName];
    entity.to = [NSString convertName:_roser];
    entity.text = name;
    entity.master = user.userName;
    entity.sourceTitle =name;
    entity.fromMe = true;
    entity.souceType = SOMessageTypeAudio;
    entity.avatar = user.head100;
    entity.time = [NSString getDateStringFromeDate:[NSDate date]];
    entity.nickName = user.firstName;
    entity.type = @"chat";
    entity.extra = [NSString stringWithFormat:@"%d",time];
    entity.sourceUrl = [RecordAudioSetting getPathByFileName:name ofType:@"amr"];
    CRWeekRef(self);
    dispatch_group_async(group, uploadqueue, ^{
        [MediaResourceManager  uploadAudioMessage:entity complete:^(BOOL result, NSArray *datas) {
            if (result) {
                [__self uploadMeidaSuccess:datas];
            }
        }];
    });
}

# pragma mark - senderImage

-(void)sendMedia:(NSDictionary *)media type:(SOMessageType)type {
    UserEntity *user =kCurUser;
    ChatMessageEntity *entity = [[ChatMessageEntity alloc] init];
    entity.from = [NSString convertName:user.userName];
    entity.to = [NSString convertName:_roser];
    entity.text = media[@"name"];
    entity.sourceTitle = media[@"name"];
    entity.souceType = SOMessageTypePhoto;
    entity.avatar = user.head100;
    entity.master = user.userName;
    entity.time = [NSString getDateStringFromeDate:[NSDate date]];
    
    entity.nickName = user.firstName;
    entity.fromMe = true;
    entity.type = @"groupchat";
    entity.extra = @"";
    entity.sourceUrl = [[self getFileDir] stringByAppendingString:CRString(@"/%@",media[@"name"])];
    CRWeekRef(self);
    [MediaResourceManager uploadImageMessage:entity complete:^(BOOL result, NSArray *datas) {
        if (result) {
            [__self uploadMeidaSuccess:datas];
        }
    }];
    
}
//  创建文件名
-(NSString*) getFileDir
{
    NSString *imgs = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/Images/"];
    NSLog(@"imgpath == %@",imgs);
    return imgs;
}


/**
 *  音频发送成功
 *
 *  @param data
 */
-(void)uploadMeidaSuccess:(id)data{
    
    CRWeekRef(self);
    if ([data count] == 2) {
        MediaEntity *media = data[0];
        ChatMessageEntity *message = data[1];
        NSString *type = nil;
        switch (message.souceType) {
            case SOMessageTypeAudio:{
                type = @"audio";
            }
                break;
            case SOMessageTypePhoto:{
                type = @"pic";
            }
                break;
            case SOMessageTypeVideo:{
                type = @"video";
            }
                break;
            default:
                break;
        }
        
        [__self sendXmppMessage:message.text date:message.time url:media.url type:type extra:message.extra];
        [__self sendMessage:message];
    }
    
}

/**
 *  xmpp消息
 *
 *  @param message 消息
 *  @param date    时间
 */
-(void)sendXmppMessage:(NSString *)message date:(NSString*)time url:(NSString *)url type:(NSString *)type extra:(NSString *)extra{
    
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return;
    }
    UserEntity *user = kCurUser;
    NSMutableDictionary *bodyDict = [NSMutableDictionary new];
    NSString *content = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [bodyDict setObject:content forKey:@"content"];
    [bodyDict setObject:time forKey:@"time"];
    [bodyDict setObject:(user.head100?user.head100:@"") forKey:@"avatar"];
    [bodyDict setObject:kCurUser.userName forKey:@"username"];
    [bodyDict setObject:user.firstName forKey:@"nickname"];
    [bodyDict setObject:url forKey:@"url"];
    [bodyDict setObject:type forKey:@"type"];
    [bodyDict setObject:extra forKey:@"extra"];
    [bodyDict setObject:self.usage_type forKey:@"usage_type"];
    NSString *bodyJson = [_jsonWriter stringWithObject:bodyDict];
    [bodyDict removeAllObjects];
    bodyDict = nil;
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:bodyJson];
    NSXMLElement *messageElement = [NSXMLElement elementWithName:@"message"];
    [messageElement addAttributeWithName:@"type" stringValue:@"chat"];
    NSString *toname = [NSString convertName:_roser];
    NSString *to = [NSString stringWithFormat:@"%d|%@@%@",kCurAppID,toname,XMPP_SERVER_HOST_ME];
    [messageElement addAttributeWithName:@"to" stringValue:to];
    [messageElement addChild:body];
    [[XmppListenerManager sharedManager].xmppStream sendElement:messageElement];
    
}


-(void)loadOlderMessages
{
    NSArray *messages = [[ContentManager sharedManager] getOlderMessagesWithRoser:_roser isServer:false type:@"chat" fromIndex:_messages.count];
    if ([messages count] == 0) {
        self.isAllLoad = true;
        self.isLoadingMore = false;
        return;
    }else{
        self.isAllLoad = false;
    }
    CRWeekRef(self);
    NSMutableArray *olderMessages = [[NSMutableArray alloc] initWithCapacity:messages.count];
    [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ChatMessageEntity *message = obj;
        NSDate *date = [NSString getDateFromeString:message.time];
        JSQMessage *msg = nil;
        if (message.souceType == SOMessageTypePhoto) {
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImageUrl:message.sourceUrl complete:^(BOOL result, UIImage *image) {
                [__self.collectionView reloadData];
            }];
            photoItem.appliesMediaViewMaskAsOutgoing = message.fromMe;
            msg = [JSQMessage messageWithSenderId:message.from
                                      displayName:message.nickName
                                           avatar:message.avatar
                                            media:photoItem];
            
        }/*else if(message.souceType == SOMessageTypeVideo){
          CRLog(@"视频 url = %@",message.sourceUrl);
          
          
          
          }*/else if(message.souceType == SOMessageTypeAudio){
              JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithURL:CRURL(message.sourceUrl) length:[message.extra integerValue] isReadyToPlay:true];
              
              audioItem.appliesMediaViewMaskAsOutgoing = message.fromMe;
              msg = [JSQMessage messageWithSenderId:message.from
                                        displayName:message.nickName
                                             avatar:message.avatar
                                              media:audioItem];
              
          }else{
              msg = [[JSQMessage alloc] initWithSenderId:message.from
                                       senderDisplayName:message.nickName
                                                  avatar:message.avatar
                                                    date:date
                                                    text:message.text];
          }
        msg.isHideFailureImage = message.isHideFailureImage;
        [olderMessages addObject:msg];
        
    }];
    NSRange range = NSMakeRange(0, [olderMessages count]);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    
    [_messages insertObjects:olderMessages atIndexes:indexSet];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[olderMessages count] inSection:0];
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:false];
    self.isLoadingMore = false;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
