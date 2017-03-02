//
//  MCenterCell.h
//  msgcopy
//
//  Created by wngzc on 15/7/13.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCenterCell : UITableViewCell
{
    NSCalendar *myCal;
    NSDictionary *numAttr;
    NSDictionary *textAttr;
    NSDateFormatter *formatter;
    NSMutableParagraphStyle *style;
    SBJsonParser *parser;
}
@property (weak, nonatomic) IBOutlet UILabel *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *descrView;
@property (weak, nonatomic) IBOutlet UILabel *timeView;
-(void)buildWithData:(MessageEntity*)data;

@end
