//
//  ChatHistoryCell.m
//  Kaoke
//
//  Created by xiaogu on 14-8-18.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "ChatHistoryCell.h"
#import "ChatMessageEntity.h"
#import "ChatServerEntity.h"
#import "BadgeView.h"

@implementation ChatHistoryCell

- (void)awakeFromNib
{
    // Initialization code
     [super awakeFromNib];
    
}
-(void)buildByData:(ChatMessageEntity*)message{
    
    if (message.souceType == SOMessageTypeAudio) {
        self.descr.text = @"[语音]";
    }else if(message.souceType == SOMessageTypePhoto){
        self.descr.text = @"[图片]";
    }else if(message.souceType == SOMessageTypeVideo){
        self.descr.text = @"[视频]";
    }else{
        self.descr.text = message.text;
    }
    if (message.fromMe) {
        NSString *nick = CRUserObj(CRString(@"%@_nick",message.to));
        if (!nick) {
            nick = message.to;
        }
        _title.text = nick;
    }else{
        NSString *_nick = message.nickName;
        _title.text = _nick;
        CRUserSetObj(_nick, CRString(@"%@_nick",message.from));
    }
    self.time.text = [NSString returnTime:[NSString getDateFromeString:message.time]];
    self.headView.layer.cornerRadius = self.headView.frame.size.width/2;
    NSInteger count = [[ContentManager sharedManager] getUnreadCountWithRoser:message.fromMe?message.to:message.from isServer:[message.useagetype isEqualToString:@"service"] type:@"chat"];
    NSString *unCount = [NSString stringWithFormat:@"%d",count];
    _unreadMsg.text = unCount;
    if (message.avatar) {
        if (!message.fromMe) {
            [_headView sd_setImageWithURL:CRURL(message.avatar)];
            CRUserSetObj(message.avatar,CRString(@"%@_avatar",message.from) );
        }else{
            NSString *avatar = CRUserObj(CRString(@"%@_avatar",message.to));
            [_headView sd_setImageWithURL:CRURL(avatar)];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
