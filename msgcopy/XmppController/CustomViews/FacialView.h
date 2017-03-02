//
//  FacialView.h
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol facialViewDelegate
@optional
-(void)selectedFacialView:(NSString*)str;
-(void)sendMessage;

@end


@interface FacialView : UIView
@property(nonatomic,weak)id<facialViewDelegate>delegate;
@property(nonatomic,copy)NSArray *faces;
-(void)loadFacialView:(int)page size:(CGSize)size;

@end
