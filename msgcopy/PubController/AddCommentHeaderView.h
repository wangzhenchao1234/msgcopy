//
//  AddCommentHeaderView.h
//  msgcopy
//
//  Created by Gavin on 15/7/1.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCommentHeaderView : UIView
@property(nonatomic,assign)CGFloat lineLeftInset;
@property(nonatomic,assign)CGFloat lineRightInset;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;

@end
