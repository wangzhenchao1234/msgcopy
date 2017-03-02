//
//  ShareWeiBo.m
//  Kaoke
//
//  Created by 谷少坤 on 13-10-22.
//
//

#import "SinaPanView.h"

#define MainH 200

@implementation SinaPanView
@synthesize delegate;

static SinaPanView *panView = nil;

+(instancetype)sharedView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        panView = [Utility nibWithName:@"SinaPanView" index:0];
        [panView intilized];
    });
    return panView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)intilized{
    [self intilizedSelf];
    [self registerForKeyboardNotifications];
}
-(void)intilizedSelf{
    
    self.frame                         = [UIScreen mainScreen].bounds;
    self.frame                         = AppWindow.bounds;
    self.textCount.text                = @"可输入120字";
    self.inputView.text                = @"";
    self.backgroundColor               = [UIColor colorWithWhite:0 alpha:0.4];
    self.mainView.layer.borderColor    = [[UIColor blackColor] CGColor];
    self.backgroundColor               = [UIColor colorWithWhite:0 alpha:0.4];
    self.padView.layer.borderColor     = [[UIColor lightGrayColor] CGColor];

    self.imageView.layer.shadowColor   = [[UIColor darkGrayColor] CGColor];
    self.imageView.layer.shadowOffset  = CGSizeMake(0.5, 0.5);
    self.imageView.layer.shadowOpacity = 0.7;
    self.padView.layer.borderWidth     = 0.5;
    self.mainView.layer.borderWidth    = 0.5;
    self.padView.layer.cornerRadius    = 4;
    CGAffineTransform at               = CGAffineTransformMakeRotation(M_PI/10);
    self.mainView.frame                = CGRectMake(0, self.frame.size.height,self.frame.size.width, MainH);
    [self.imageView setTransform:at];
    _downLoadView.text = kCurApp.downloadUrl;
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardDidHideNotification object:nil];
}
- (void)keyboardDidShown:(NSNotification*)aNotification {
    keyboardIsHidden = NO;
}
- (void)keyboardDidHidden:(NSNotification*)aNotification {
    
    keyboardIsHidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil] ;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    self.mainView.y = AppWindow.height;
    [self removeFromSuperview];
}
- (void)keyboardWillShown:(NSNotification*)aNotification {
    NSDictionary* info  = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        self.mainView.frame = CGRectMake(0, self.frame.size.height-keyboardSize.height-MainH, self.frame.size.width, MainH);
    }];
}
- (void)keyboardWillHidden:(NSNotification*)aNotification {

    [UIView animateWithDuration:0.3 animations:^{
        self.mainView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, MainH);
    }];
}
- (void)keyboardDidChangeFrame:(NSNotification*)aNotification {
    NSDictionary* info  = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
    self.mainView.frame = CGRectMake(0, self.frame.size.height-keyboardSize.height-MainH, self.frame.size.width, MainH);
    }];

}
- (IBAction)close:(id)sender {
    [self disMiss];
}

- (IBAction)submite:(id)sender {
    [self close:nil];
    if ([self.delegate respondsToSelector:@selector(sendShareMessage:)]) {
        NSString *str = self.inputView.text;
        if (self.downLoadView.text) {
            str = [str stringByAppendingString:self.downLoadView.text];
        }
        [self.delegate sendShareMessage:str];
    }
}

-(void)show:(id)target{
    [self registerForKeyboardNotifications];
    self.delegate = target;
    [AppWindow addSubview:self];
    self.textCount.text = [NSString stringWithFormat:@"可输入%d字",120-[self.inputView.text length]];
    [self.inputView becomeFirstResponder];
}
-(void)disMiss{
    [self.inputView resignFirstResponder]; 
}
-(void)textViewDidChange:(UITextView *)textView{
    self.textCount.text = [NSString stringWithFormat:@"可输入%d字",120-[self.inputView.text length]];
    if ([self.inputView.text length]>120) {
//        NSMutableString *str = [self.inputView.text mutableCopy];
//        NSString *text = [str substringToIndex:120];
//        self.inputView.text = text;
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self submite:nil];
    }
    return YES;
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
