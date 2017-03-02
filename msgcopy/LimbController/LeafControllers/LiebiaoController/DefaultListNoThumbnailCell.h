//
//  DefaultListNoThumbnailCell.h
//  msgcopy
//
//  Created by wngzc on 15/8/12.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UICustomLineLabel;

@interface DefaultListNoThumbnailCell : UITableViewCell
{
    NSInteger _like;
    NSInteger _comment;
}
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *descrView;
@property (weak, nonatomic) IBOutlet  UIButton*positionView;
-(void)buildWithData:(PubEntity*)pub;
+(CGFloat)getCellHeight;
@end
