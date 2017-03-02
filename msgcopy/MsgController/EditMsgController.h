//
//  EditMsgController.h
//  msgcopy
//
//  Created by sh on 16/10/20.
//  Copyright © 2016年 Gavin. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CreateContentController.h"
@class MsgController;

@interface EditMsgController : CreateContentController
@property(nonatomic,retain)ArticleEntity *article;
@property(nonatomic,weak) MsgController *pushController;
@property(nonatomic,retain)NSArray *groupDicts;
@end
