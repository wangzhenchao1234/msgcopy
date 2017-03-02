//
//  ChatHistoryCell.h
//  Kaoke
//
//  Created by xiaogu on 14-8-18.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatMessageEntity;
@class BadgeView;

@interface ChatHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *descr;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet BadgeView *unreadMsg;
-(void)buildByData:(ChatMessageEntity*)message;
@end
