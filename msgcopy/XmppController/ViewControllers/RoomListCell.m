//
//  RoomListCell.m
//  msgcopy
//
//  Created by wngzc on 15/5/28.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "RoomListCell.h"
#import "ChatMessageEntity.h"
#import "RoomChatEntity.h"

@implementation RoomListCell

- (void)awakeFromNib {
    // Initialization code
    self.lineLeftInset = DefaultPan;
    self.iconView.layer.cornerRadius = self.iconView.frame.size.width/2;
    self.iconView.clipsToBounds = true;
}
-(void)buildByData:(ChatMessageEntity*)message{
    
    __block NSString *groupName = message.to;
    NSArray *rooms = [HistoryContentManager sharedManager].rooms;
    [rooms enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RoomChatEntity *chat = obj;
        if ([chat.roomname isEqualToString:groupName]) {
            groupName = chat.title;
        }
    }];
    self.titleView.text = groupName;
    if (message.souceType == SOMessageTypeAudio) {
        self.descrView.text = @"[语音]";
    }else if(message.souceType == SOMessageTypePhoto){
        self.descrView.text = @"[图片]";
    }else if(message.souceType == SOMessageTypeVideo){
        self.descrView.text = @"[视频]";
    }else{
        self.descrView.text = message.text;
    }
    _formmater = [[NSDateFormatter alloc] init];
    _formmater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date = [_formmater dateFromString:message.time];
    self.timeView.text = [NSString getTimeString:date];;
    [self getUnReadMessage:message.to];
}
-(void)getUnReadMessage:(NSString*)roomName{
    //获取该用户所有未读消息
    NSInteger unreadCount = [[ContentManager sharedManager] getUnreadCountWithRoser:roomName isServer:false type:@"groupchat"];
    _badgeView.text = CRString(@"%d",unreadCount);
    _badgeView.center = CGPointMake(_iconView.x + _iconView.width, _iconView.y);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
