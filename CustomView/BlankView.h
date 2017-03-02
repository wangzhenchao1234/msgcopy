//
//  BlankView.h
//  msgcopy
//
//  Created by wngzc on 15/8/11.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlankView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *descrView;
@property (weak, nonatomic) IBOutlet UIButton *actionView;
+(instancetype)blanViewWith:(UIImage*)image descr:(NSString*)descr actionTitle:(NSString*)actionTitle target:(id)target selector:(SEL)selector;
@end
