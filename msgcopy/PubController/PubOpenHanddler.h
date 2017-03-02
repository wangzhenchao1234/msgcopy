//
//  PubOpenHanddler.h
//  msgcopy
//
//  Created by Gavin on 15/5/5.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^openResultHanddler)(NSString *msg);

@interface PubOpenHanddler : UIViewController

@property (nonatomic,assign)NSInteger pubid;
@property (nonatomic,retain)PubEntity *pub;

+(void)openWithPubID:(NSInteger)pubID placeholderView:(UIView*)placeholder;
+(void)openWithPub:(PubEntity*)pub placeholderView:(UIView*)placeholder;

@end
