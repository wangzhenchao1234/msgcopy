//
//  CommentToolBar.h
//  msgcopy
//
//  Created by Gavin on 15/7/31.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentToolBarDelegate <NSObject>

@optional
-(void)submitWithMessage:(NSString*)message;
-(void)addAttach:(id)sender;
-(void)inSertComment:(CommentEntity*)comment;
@end

@interface CommentToolBar : UIView
@property(nonatomic,weak)id<CommentToolBarDelegate>delegate;
@property(nonatomic,retain)ArticleEntity *msg;
-(NSString*)contentText;
-(void)showFrom:(UIView*)view;
-(void)disMiss;
@end
