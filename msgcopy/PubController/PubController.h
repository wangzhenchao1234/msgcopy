//
//  PubController.h
//  msgcopy
//
//  Created by wngzc on 15/4/14.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PubEntity;

@interface PubController : UIViewController
@property(nonatomic,retain) PubEntity *pub; //投稿
@property (nonatomic,retain) UIWebView *webView;
@property (nonatomic,retain) UIToolbar *bottomToolBarView;
@property (nonatomic,retain) UIToolbar *topBarView;
@property (nonatomic,retain) NSMutableArray *topMenus;
@property (nonatomic,assign) NSInteger currentFont;
@property (nonatomic,retain) UIActivityIndicatorView *indicatorView;
-(void)doShare:(id)sender;
-(void)doLike:(id)sender;
-(void)showMore:(id)sender;
-(void)doArticle:(id)sender;
-(void)doComment:(id)sender;
-(void)connectToServer:(id)sender;
@end

