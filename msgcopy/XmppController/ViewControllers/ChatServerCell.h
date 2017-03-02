//
//  ChatServerCell.h
//  Kaoke
//
//  Created by Gavin on 14/10/28.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ServerEntity;
@class ChatMessageEntity;
@class BadgeView;

@interface ChatServerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *serverFlag;
@property (weak, nonatomic) IBOutlet BadgeView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet UILabel *messageView;

-(void)buildByData:(ServerEntity*)server;
@end