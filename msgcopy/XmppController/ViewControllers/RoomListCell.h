//
//  RoomListCell.h
//  msgcopy
//
//  Created by wngzc on 15/5/28.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgTableCell.h"
@class ChatMessageEntity;

@interface RoomListCell : MsgTableCell
{
    ChatMessageEntity *_currentMessage;
    NSDateFormatter *_formmater;
}
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet UILabel *descrView;
@property (weak, nonatomic) IBOutlet UILabel *badgeView;
-(void)buildByData:(ChatMessageEntity*)data;
@end
