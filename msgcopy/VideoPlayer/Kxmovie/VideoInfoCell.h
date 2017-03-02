//
//  VideoInfoCell.h
//  msgcopy
//
//  Created by wngzc on 15/5/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgCollectionCell.h"

@protocol VideoInfoCellDelegate  <NSObject>
@optional
-(void)doArticle:(id)sender;
-(void)doLike:(id)sender;

@end

@interface VideoInfoCell : MsgCollectionCell
@property(nonatomic,weak)id<VideoInfoCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *descrView;
@property (weak, nonatomic) IBOutlet UIButton *articleButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@end
