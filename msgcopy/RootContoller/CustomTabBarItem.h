//
//  CustomTabBarItem.h
//  msgcopy
//
//  Created by Gavin on 15/4/14.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabBarItem : UIView
@property(nonatomic,retain)NSString *normalImage;
@property(nonatomic,retain)NSString *selectedImage;
@property(nonatomic,retain)NSString *title;
@property(nonatomic,assign)BOOL selected;
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
