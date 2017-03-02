//
//  CenterController.h
//  msgcopy
//
//  Created by Gavin on 15/4/10.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <RDVTabBarController/RDVTabBarController.h>

@interface CenterController : RDVTabBarController
@property(nonatomic,assign) NSInteger curSelectedTab;
@property(nonatomic,retain) NSMutableArray *leftBarItems;
@property(nonatomic,retain) UIImageView *titleView;
@property(nonatomic,retain) UIBarButtonItem *rightBarButtonItem;
@property(nonatomic,retain) UIButton *rightMenuButton;
@property(nonatomic,retain) UIBarButtonItem *leftBarButtonItem;
@property(nonatomic,retain) UIBarButtonItem *filterButtonItem;

@property(nonatomic,retain) UIButton *filterButton;

/**
 *  设置viewControllers
 *
 *  @param viewControllers
 *  @param items  tabbaritems
 */
- (void)setViewControllers:(NSArray *)viewControllers tabBarItems:(NSArray*)items;
/**
 *  显示logo
 */
-(void)showTitleView;
/**
 *  隐藏logo
 */
-(void)hiddenTitleView;
/**
 *  显示标题
 *
 *  @param title 标题
 */
-(BOOL)checkPermission;
-(void)setTitle:(NSString *)title;
-(void)filterCheck;
-(void)pushCheck;
@end
