//
//  SQCoverView.h
//  Kaoke
//
//  Created by xiaogu on 14-5-23.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCoverView : UIView{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}
@property (nonatomic, retain) UIImageView * line;
-(void)backAction;
-(void)startAnimation;
@end
