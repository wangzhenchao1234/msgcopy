//
//  MediaPanView.h
//  Kaoke
//
//  Created by xiaogu on 14-9-18.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MediaPanDelegate <NSObject>

-(void)pressedImageButton:(id)sender;
-(void)pressedVideoButton:(id)sender;

@end


@interface MediaPanView : UIView

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UIButton *imageButton;
@property (nonatomic,strong) UIButton *videoButton;
@property (nonatomic,weak) id<MediaPanDelegate> delegate;
- (id)initWithFrame:(CGRect)frame target:(id)target;
@end
