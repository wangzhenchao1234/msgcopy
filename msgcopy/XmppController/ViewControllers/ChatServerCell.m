//
//  ChatServerCell.m
//  Kaoke
//
//  Created by Gavin on 14/10/28.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "ChatServerCell.h"
#import "ChatServerEntity.h"
#import "ChatMessageEntity.h"
#import "BadgeView.h"

@implementation ChatServerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)awakeFromNib
{
    // Initialization code
    self.headView.layer.cornerRadius = self.headView.frame.size.width/2;
    
}
-(void)buildByData:(ServerEntity*)server{
    
    self.title.text = server.cs_name;
    [self.headView sd_setImageWithURL:CRURL(server.headicon) placeholderImage:UserPlaceImage];
    self.timeView.text = @"";
    self.messageView.text = server.descr;
    UserEntity *curUser = kCurUser;
    NSString *username = [NSString convertName:curUser.userName];
    if ([server.username isEqualToString:curUser.userName]) {
        NSArray *messages = [[HistoryContentManager sharedManager] getAllServerHistoryWithRoser:curUser.userName from:username to:username isServer:true type:@"chat"];
        for (ChatMessageEntity *message in messages) {
            [self setMessage:message server:server];
        }
    }else{
        
        NSArray *messages = [[HistoryContentManager sharedManager] getAllServerHistoryWithRoser:curUser.userName from:username to:[NSString convertName:server.username] isServer:true type:@"chat"];
        if (messages.count == 0) {
            messages = [[HistoryContentManager sharedManager] getAllServerHistoryWithRoser:curUser.userName from:[NSString convertName:server.username] to:username isServer:true type:@"chat"];
        }
        for (ChatMessageEntity *message in messages) {
            [self setMessage:message server:server];
        }
    }
    [self resetServerFlag];
}
-(void)setMessage:(ChatMessageEntity*)message server:(ServerEntity*)server{
    
    if (!message) {
        return;
    }
    self.timeView.text = [NSString returnTime:[NSString getDateFromeString:message.time]];
    if (message.souceType == SOMessageTypeAudio) {
        self.messageView.text = @"[语音]";
    }else if(message.souceType == SOMessageTypePhoto){
        self.messageView.text = @"[图片]";
    }else if(message.souceType == SOMessageTypeVideo){
        self.messageView.text = @"[视频]";
    }else{
        self.messageView.text = message.text;
    }
    NSInteger count = [[ContentManager sharedManager] getUnreadCountWithRoser:server.username isServer:([message.useagetype isEqualToString:@"service"]? true : false) type:@"chat"];
    NSString *unCount = [NSString stringWithFormat:@"%d",count];
    _badgeView.text = unCount;
}
-(void)resetServerFlag{
    
    [self.title sizeToFit];
    CGRect serverFrame = self.serverFlag.frame;
    serverFrame.origin.x = self.title.frame.origin.x + self.title.frame.size.width + 10;
    self.serverFlag.image = [UIImage imageNamed:@"ic_server_black"];
    self.serverFlag.frame = serverFrame;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
