//
//  SingleListCell.m
//  msgcopy
//
//  Created by Gavin on 15/5/28.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "SingleListCell.h"
#import "ChatMessageEntity.h"

@implementation SingleListCell

- (void)awakeFromNib {
    // Initialization code
    self.lineLeftInset = DefaultPan;
}
-(void)buildWithMessage:(ChatMessageEntity*)message
{
    _currentMessage = message;
    if (message.fromMe) {
        NSString *nick = CRUserObj(CRString(@"%@_nick",message.to));
        if (!nick) {
            nick = message.to;
        }
        _titleView.text = nick;
    }else{
        NSString *_nick = message.nickName;
        _titleView.text = _nick;
        CRUserSetObj(_nick, CRString(@"%@_nick",message.from));
    }
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
    _timeView.text = [NSString getTimeString:date];
    if (message.avatar) {
        if (!message.fromMe) {
            [_iconView setImageWithUrl:message.avatar];
            CRUserSetObj(message.avatar,CRString(@"%@_avatar",message.from) );
        }else{
            NSString *avatar = CRUserObj(CRString(@"%@_avatar",message.to));
            [_iconView setImageWithUrl:avatar];
        }
    }
    [self getUnReadMessage];
}
-(void)getUnReadMessage{
    //获取该用户所有未读消息
    BOOL _isFromMe = [_currentMessage.from isEqualToString:kCurUserName];
    NSString *_roserName = _isFromMe == true?_currentMessage.to:_currentMessage.from;
    NSInteger unreadCount = [[ContentManager sharedManager] getUnreadCountWithRoser:_roserName isServer:false type:@"chat"];
    _badgeView.text = CRString(@"%d",unreadCount);
    _badgeView.center = CGPointMake(_iconView.x + _iconView.width, _iconView.y);
}
-(void)getUserInfo:(NSString*)username
{
    [MSGRequestManager Get:kAPIUserProfile(username) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSString *nickname = [Utility dictionaryValue:data forKey:@"first_name"];
        NSDictionary *head = [Utility dictionaryValue:data forKey:@"head"];
        NSString *imageUrl = [Utility dictionaryValue:head forKey:@"head50"];
        CRUserSetObj(nickname, CRString(@"his_%@",username));
        CRUserSetObj(imageUrl, CRString(@"his_%@_head",username));
        _titleView.text = nickname;
        [_iconView setImageWithUrl:imageUrl];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        //获取个人信息失败
        CRLog(@"error = %@, url == %@",msg,requestURL);
    }];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
