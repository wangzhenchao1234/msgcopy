//
//  LoginMenuCell.h
//  msgcopy
//
//  Created by wngzc on 15/5/21.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginMenuCellDelegate <NSObject>

@optional
- (void)doRegister:(id)sender;
- (void)doGetPwd:(id)sender;

@end

@interface LoginMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *passButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *separatorLine;
@property (weak, nonatomic) id<LoginMenuCellDelegate> delegate;

@end
