//
//  WebAppController.h
//  msgcopy
//
//  Created by wngzc on 15/4/14.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^WebGoBackAction)(void);
typedef void(^WebCallBackAction)(id data);

@interface WebAppController : UIViewController
@property(nonatomic,assign)NSInteger appid;
@property(nonatomic,retain)NSDictionary *params;
@property(nonatomic,copy)WebCallBackAction callBackAction;
@property(nonatomic,copy)WebGoBackAction goBackAction;
@property(nonatomic,retain) UIWebView *webView;
@property(nonatomic,assign) NSInteger sid;
@property(nonatomic,assign)NSInteger shoplist;
@property(nonatomic,copy)NSString*desr;
@property(nonatomic,copy)NSString*imgUrl;
@property(nonatomic,copy)NSString*link;
@property(nonatomic,copy)NSString*sharetitle;
@property(nonatomic,copy)NSString*channel;
@end
