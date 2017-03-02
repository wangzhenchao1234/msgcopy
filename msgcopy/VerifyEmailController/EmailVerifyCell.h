//
//  EmailVerifyCell.h
//  msgcopy
//
//  Created by wngzc on 15/9/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MsgTableCell.h"
#import "JKCountDownButton.h"

@interface EmailVerifyCell : MsgTableCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UITextField *inputView;
@property (weak, nonatomic) IBOutlet JKCountDownButton *verifyButoon;
@property (copy, nonatomic) NSString *codeAPI;
@property (nonatomic,retain) NSDictionary *params;
-(void)setPlaceholder:(NSString*)placeholder;
-(NSString*)value;

@end
