//
//  ShareView.h
//  msgcopy
//
//  Created by Gavin on 15/6/25.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinaPanView.h"

@interface ShareView : UIView<UICollectionViewDataSource,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate,SinaPanDelegate>
{
    NSInteger _scene;
}

@property (weak, nonatomic) IBOutlet UICollectionView *menuView;

@property (nonatomic,retain) NSMutableArray *menus;
@property (nonatomic,retain) ArticleEntity *msg;
@property (nonatomic,retain) UIImage *image;
@property (nonatomic,retain) PubEntity *pub;
@property (nonatomic,weak) UIWebView *webView;
@property(nonatomic,copy)NSString*title;
@property(nonatomic,copy)NSString*loadUrl;
@property(nonatomic,copy)NSString*desr;
@property(nonatomic,copy)NSString*imgUrl;
@property(nonatomic,copy)NSString*link;
@property(nonatomic,assign)NSInteger isH5Share;
+(instancetype)sharedView;
+(void)show:(ArticleEntity*)article;
+(void)hidden;

@end
