//
//  XMServerContentController.h
//  msgcopy
//
//  Created by Gavin on 15/6/17.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "JSQMessagesViewController.h"
//#import "JSQMessages.h"


@interface XMServerContentController : JSQMessagesViewController
//@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
//@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property(nonatomic,copy) NSString *roser;
@property (nonatomic,copy) NSString *usage_type;
@end
