//
//  CommentReusableView.h
//  msgcopy
//
//  Created by wngzc on 15/7/30.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentReusableViewDelegate <NSObject>
@optional
-(void)addComment;

@end


@interface CommentReusableView : UICollectionReusableView
@property (weak, nonatomic) id<CommentReusableViewDelegate>delegate;
@property(nonatomic,assign)CGFloat lineLeftInset;
@property(nonatomic,assign)CGFloat lineRightInset;

@end
