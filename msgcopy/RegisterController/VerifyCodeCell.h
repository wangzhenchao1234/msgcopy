//
//  VerifyCodeCell.h
//  msgcopy
//
//  Created by wngzc on 15/5/20.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MsgTableCell.h"
#import "JKCountDownButton.h"

@interface VerifyCodeCell : MsgTableCell
@property (weak, nonatomic) IBOutlet UILabel *verifyView;
@property (weak, nonatomic) IBOutlet UITextField *inputView;
@property (weak, nonatomic) IBOutlet JKCountDownButton *verifyButoon;
@property (copy, nonatomic) NSString *codeAPI;
-(void)setPlaceholder:(NSString*)placeholder;
-(NSString*)value;
@end
