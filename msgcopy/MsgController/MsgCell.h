//
//  MsgCell.h
//  msgcopy
//
//  Created by Gavin on 15/7/7.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgCellContentView.h"

@interface MsgCell : UITableViewCell
@property (weak, nonatomic) IBOutlet MsgCellContentView *cellContentView;
-(void)buildWithData:(ArticleEntity*)data;
+(CGFloat)cellHeight;
@end
