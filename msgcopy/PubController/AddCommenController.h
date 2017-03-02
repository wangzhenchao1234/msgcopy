//
//  AddCommentControllerTableViewController.h
//  msgcopy
//
//  Created by wngzc on 15/7/1.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateContentController.h"

@protocol AddCommenControllerDelegate <NSObject>

-(void)inSertComment:(CommentEntity*)comment;

@end

@class CommentsController;

@interface AddCommenController : CreateContentController
@property(nonatomic,weak)id<AddCommenControllerDelegate> pushController;
@property(nonatomic,retain)NSString *defaultContent;
@property(nonatomic,retain)ArticleEntity *article;
@end
