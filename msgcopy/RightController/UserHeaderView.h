//
//  UserHeaderView.h
//  msgcopy
//
//  Created by wngzc on 15/5/20.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserHeaderView : UIView
-(void)setImage:(UIImage *)image forState:(UIControlState)state;
-(void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event;
@end
