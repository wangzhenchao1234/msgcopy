//
//  ActionFooterView.h
//  msgcopy
//
//  Created by wngzc on 15/5/20.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionFooterView : UIView
-(void)setTitle:(NSString*)title state:(UIControlState)state;
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event;
@end
