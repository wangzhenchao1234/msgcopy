//
//  BusinessListCell.h
//  msgcopy
//
//  Created by wngzc on 15/4/16.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UICustomLineLabel;
@interface DefaultListCell : UITableViewCell
{
    NSInteger _like;
    NSInteger _comment;
}
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *descrView;
@property (weak, nonatomic) IBOutlet  UIButton*positionView;
@property (weak, nonatomic) IBOutlet UILabel *cmCount;
-(void)buildWithData:(PubEntity*)pub;
+(CGFloat)getCellHeight;
@end
