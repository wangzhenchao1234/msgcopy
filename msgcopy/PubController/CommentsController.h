//
//  CommentsController.h
//  msgcopy
//
//  Created by Gavin on 15/6/29.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsController : UITableViewController

@property(nonatomic,retain)ArticleEntity *article;
-(void)inSertComment:(CommentEntity*)comment;
@end
