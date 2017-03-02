//
//  UserQRView.m
//  msgcopy
//
//  Created by Gavin on 15/8/12.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "UserQRView.h"

@interface UserQRView()
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation UserQRView
-(void)awakeFromNib
{
    _closeButton.layer.cornerRadius = 15;
    _closeButton.layer.borderColor = CRCOLOR_WHITE.CGColor;
    _closeButton.layer.borderWidth = 1;
    _mainView.layer.cornerRadius = 5;
    _mainView.clipsToBounds = true;
    _closeButton.clipsToBounds = true;
}
+(void)showWithQRURL:(NSString *)qrURLString
{
    UserQRView *qrView = [Utility nibWithName:@"UserQRView" index:0];
    qrView.frame = AppWindow.bounds;
    [qrView.qrImageView sd_setImageWithURL:CRURL(qrURLString)];
    qrView.alpha = 0.0f;
    [AppWindow addSubview:qrView];
    [UIView animateWithDuration:.35 animations:^{
        qrView.alpha = 1.0f;
    }];
    
}
- (IBAction)close:(id)sender {
    CRWeekRef(self);
    [UIView animateWithDuration:.35 animations:^{
        __self.alpha = 0;
    } completion:^(BOOL finished) {
        [__self removeFromSuperview];
    }];
    
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
