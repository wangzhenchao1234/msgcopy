//
//  ShareWeiBo.h
//  Kaoke
//
//  Created by 谷少坤 on 13-10-22.
//
//

#import <UIKit/UIKit.h>

@protocol SinaPanDelegate <NSObject>

-(void)sendShareMessage:(NSString *)message;

@end


@interface SinaPanView : UIView<UITextViewDelegate>{
    BOOL keyboardIsHidden;
    UIView *view;
}
@property (weak, nonatomic) id<SinaPanDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView      *padView;
@property (weak, nonatomic) IBOutlet UIView      *mainView;
@property (weak, nonatomic) IBOutlet UILabel     *textCount;
@property (weak, nonatomic) IBOutlet UILabel     *downLoadView;
@property (weak, nonatomic) IBOutlet UITextView  *inputView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton    *close;
@property (weak, nonatomic) IBOutlet UIButton    *sumbmit;

- (IBAction)close:(id)sender;
- (IBAction)submite:(id)sender;
+(instancetype)sharedView;
-(void)intilized;

-(void)show:(id)target;
-(void)disMiss;
@end
