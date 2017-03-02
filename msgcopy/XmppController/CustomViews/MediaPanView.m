//
//  MediaPanView.m
//  Kaoke
//
//  Created by xiaogu on 14-9-18.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "MediaPanView.h"
#define keyBoardHeight 216

@implementation MediaPanView

- (id)initWithFrame:(CGRect)frame target:(id)target
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.frame = CGRectMake(0, 0, frame.size.width, keyBoardHeight);
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/4, (216 - 80)/2 - 15, frame.size.width/2, 110)];
        self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.imageButton setImage:[UIImage imageNamed:@"bt_chat_image"] forState:UIControlStateNormal];
        [self.imageButton addTarget:target action:@selector(pressedImageButton:) forControlEvents:UIControlEventTouchUpInside];
        self.imageButton.frame = CGRectMake((frame.size.width /4-80)/2, 0, 80, 80);
        self.imageButton.enabled = false;
        [self.contentView addSubview:self.imageButton];
        
        UILabel *imageTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.imageButton.frame.origin.x, 80, 80, 30)];
        imageTitle.text = @"图片";
        imageTitle.textAlignment = NSTextAlignmentCenter;
        imageTitle.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:imageTitle];
        
        self.videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.videoButton setImage:[UIImage imageNamed:@"bt_chat_video"] forState:UIControlStateNormal];
        [self.videoButton addTarget:target action:@selector(pressedVideoButton:) forControlEvents:UIControlEventTouchUpInside];
        self.videoButton.frame = CGRectMake(frame.size.width /4 + (frame.size.width /4-80)/2, 0, 80, 80);
        [self.contentView addSubview:self.videoButton];
        self.videoButton.enabled = false;
        
        UILabel *videoTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.videoButton.frame.origin.x, 80, 80, 30)];
        videoTitle.text = @"视频";
        videoTitle.textAlignment = NSTextAlignmentCenter;
        videoTitle.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:videoTitle];
        [self addSubview:self.contentView];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
