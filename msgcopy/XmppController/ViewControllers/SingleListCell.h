//
//  SingleListCell.h
//  msgcopy
//
//  Created by wngzc on 15/5/28.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgTableCell.h"
#import "BadgeView.h"
#import "HeadView.h"

@class ChatMessageEntity;
@interface SingleListCell : MsgTableCell
{
    ChatMessageEntity *_currentMessage;
    NSDateFormatter *_formmater;
}
@property (weak, nonatomic) IBOutlet HeadView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *descrView;
@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet BadgeView *badgeView;
-(void)buildWithMessage:(ChatMessageEntity*)message;
@end
