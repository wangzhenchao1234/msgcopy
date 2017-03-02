//
//  InputCell.h
//  msgcopy
//
//  Created by wngzc on 15/5/20.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MsgTableCell.h"

@interface InputCell : MsgTableCell
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UITextField *textInputView;
-(void)setPlaceholder:(NSString*)placeholder;
-(NSString*)value;
@end
