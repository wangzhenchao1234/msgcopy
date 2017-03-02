//
//  VirtualPayCell.h
//  Kaoke
//
//  Created by wngzc on 15/4/28.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VirtualPayEntity;

@interface VirtualPayCell : UITableViewCell
{
    NSDateFormatter *fommater;
}
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *moneyView;
@property (weak, nonatomic) IBOutlet UIView *selectedFlag;
@property (weak, nonatomic) IBOutlet UILabel *descrView;
-(void)buildWithData:(VirtualPayEntity*)data;
@end
