//
//  MsgController.h
//  msgcopy
//
//  Created by wngzc on 15/7/7.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface MsgController : UIViewController
-(void)insertMsg:(ArticleEntity*)msg toGroup:(NSInteger)index;
@end
