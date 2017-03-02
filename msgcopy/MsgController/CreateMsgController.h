//
//  CreateMsgController.h
//  msgcopy
//
//  Created by Gavin on 15/7/9.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateContentController.h"
@class MsgController;

@interface CreateMsgController : CreateContentController
@property(nonatomic,weak) MsgController *pushController;
@property(nonatomic,retain)NSArray *groupDicts;
@end
