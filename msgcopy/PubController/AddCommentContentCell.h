//
//  AddCommentContentCell.h
//  msgcopy
//
//  Created by Gavin on 15/7/1.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgTableCell.h"

@protocol  AddCommentContentCellDelegate<NSObject>

-(void)adjustFrame:(id)sender;

@end

@interface AddCommentContentCell : MsgTableCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstranit;
@property(nonatomic,retain)NSDictionary *textAttr;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *placeholder;
@property (weak, nonatomic) id<AddCommentContentCellDelegate>deletate;
@end
