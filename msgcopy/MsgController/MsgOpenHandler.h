//
//  MsgHandlerController.h
//  msgcopy
//
//  Created by wngzc on 15/7/10.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ArticleEntity;

@interface MsgOpenHandler : UIViewController
@property (nonatomic,assign)NSInteger msgid;
@property (nonatomic,retain)ArticleEntity *msg;

+(void)openWithMsgID:(NSInteger)msgID placeholderView:(UIView*)placeholder;
+(void)openWithMsg:(ArticleEntity*)Msg placeholderView:(UIView*)placeholder;

@end
