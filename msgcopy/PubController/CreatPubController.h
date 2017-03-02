//
//  CreatPubController.h
//  msgcopy
//
//  Created by wngzc on 15/8/10.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "CreateMsgController.h"

@interface CreatPubController : CreateMsgController
@property(nonatomic,copy)void(^createFinished)(BOOL result,id data);

@end
