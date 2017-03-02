//
//  CommentToolBar.m
//  msgcopy
//
//  Created by wngzc on 15/7/31.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "CommentToolBar.h"
#import "FacialPanView.h"

#define KeyBoardAnimationInteval 0.3
#define FacialHeight 216

@interface CommentToolBar()<UITextViewDelegate,facialViewDelegate>
{
    BOOL iskeyBoardShown;
    BOOL isEmotionShown;
    CGFloat keyBoardHeight;
}

@property(nonatomic,retain)UIToolbar *toolBar;
@property(nonatomic,retain)UIView *toolBarContentView;
@property(nonatomic,retain)UITextView *textInputView;
@property(nonatomic,retain)UIButton *faceButton;
@property(nonatomic,retain)UIButton *attachButton;
@property(nonatomic,retain)FacialPanView *facialView;

@end

@implementation CommentToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, frame.size.height - 44, frame.size.width,44)];
        _toolBarContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _toolBar.width, _toolBar.height)];

        _textInputView = [[UITextView alloc] initWithFrame:CGRectMake(44, 7, frame.size.width - 88, 30)];
        _textInputView.font = MSGFont(14);
        _textInputView.delegate = self;
        
        _textInputView.layer.cornerRadius = 5;
        _textInputView.layer.borderColor = [UIColor colorFromHexRGB:@"999989"].CGColor;
        _textInputView.clipsToBounds = true;
        
        _faceButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceButton.frame = CGRectMake(0, 0, 44, 44);
        [_faceButton setImage:IconPlaceImage forState:UIControlStateNormal];
        [_faceButton addTarget:self action:@selector(addEmotion:) forControlEvents:UIControlEventTouchUpInside];
        
        _faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        [_toolBarContentView addSubview:_faceButton];
        [_toolBarContentView addSubview:_textInputView];

        
        _attachButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _attachButton.frame = CGRectMake( _toolBar.width - 44 ,0, 44, 44);
        [_attachButton setImage:IconPlaceImage forState:UIControlStateNormal];
        [_attachButton addTarget:self action:@selector(addAttach:) forControlEvents:UIControlEventTouchUpInside];
        
        _attachButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin| UIViewAutoresizingFlexibleLeftMargin;
        [_toolBarContentView addSubview:_attachButton];

        
        UIBarButtonItem *content = [[UIBarButtonItem alloc] initWithCustomView:_toolBarContentView];
        
        _toolBar.items = @[content];
        [self addSubview:_toolBar];
        
        _facialView = [[FacialPanView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, FacialHeight) target:self];
        [self addSubview:_facialView];
        [self registerNotification];

    }
    return self;
}

-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
-(void)keybordWillShown:(NSNotification*)notify
{
    iskeyBoardShown = true;
    if (isEmotionShown) {
        [self hiddenEmotion];
    }
    NSLog(@"will show");
    NSDictionary *info = [notify userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"%@",NSStringFromCGSize(keyboardSize));
    keyBoardHeight = keyboardSize.height;
    CGFloat y = self.height - keyboardSize.height - _toolBar.height;
    if (isEmotionShown) {
        return;
    }
    [UIView animateWithDuration:KeyBoardAnimationInteval animations:^{
        _toolBar.y = y;
    } completion:^(BOOL finished) {
        if (keyboardSize.height == 0) {
            [self hidden];
        }
    }];

}
-(void)keybordWillHidden:(NSNotification*)notify
{
    NSLog(@"will hidden");
    keyBoardHeight = 0;
    if (!isEmotionShown) {
        CGFloat y = self.height;
        [UIView animateWithDuration:KeyBoardAnimationInteval animations:^{
            _toolBar.y = y;
        } completion:^(BOOL finished) {
            [self hidden];
        }];
    }
}
-(void)keybordDidHidden:(NSNotification*)notify
{
    iskeyBoardShown = false;
    NSLog(@"did hidden");

}
-(void)keybordDidChange:(NSNotification*)notify
{
    NSLog(@"did change");
}

# pragma mark - facialDelegate
-(void)selectedFacialView:(NSString*)str
{
    
    if ([str isEqualToString:@"删除"]) {
        [self deleteFacial];
        return;
    }
    NSString *new = CRString(@"%@%@",_textInputView.text,str);
    _textInputView.text = new;
    [self textView:_textInputView shouldChangeTextInRange:NSMakeRange(0, 1) replacementText:new];
}
# pragma mark - 发送

-(void)sendMessage
{
    if ([_delegate respondsToSelector:@selector(submitWithMessage:)]) {
        [_delegate submitWithMessage:_textInputView.text];
    }
}
-(void)deleteFacial{
    
    NSError *error = nil;
    NSString *regTags = @"\\[[\\u4e00-\\u9fa5a-z]{1,3}\\]";       // 设计好的正则表达式，最好先在小工具里试验好
    NSString *text = _textInputView.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                  
                                                                           options:NSRegularExpressionCaseInsensitive    // 还可以加一些选项，例如：不区分大小写
                                  
                                                                             error:&error];
    
    // 执行匹配的过程
    
    NSArray *matches = [regex matchesInString:text options:0  range:NSMakeRange(0, [text length])];
    
    // 用下面的办法来遍历每一条匹配记录
    NSRange range = _textInputView.selectedRange;
    NSLog(@"loc aa  == %d, len aa == %d",range.location,range.length);
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        NSLog(@"loc  == %d, len == %d",matchRange.location,matchRange.length);
        if (range.location>=matchRange.location&&range.location<=matchRange.location+matchRange.length) {
            
            NSString *newStr = [text stringByReplacingCharactersInRange:matchRange withString:@""];
            _textInputView.text = newStr;
            [self textView:_textInputView shouldChangeTextInRange:NSMakeRange(0, 1) replacementText:newStr];
            return;
            break;
            
        }
    }
    if (text.length>0) {
        
        NSString *newText = [text substringToIndex:text.length - 1];
        _textInputView.text = newText;
        [self textView:_textInputView shouldChangeTextInRange:NSMakeRange(0, 1) replacementText:newText];
    }
    
}


# pragma mark - actions

-(void)showFrom:(UIView*)view
{
    if (!LoginState) {
        [LoginHandler showLoginControllerFromController:CRRootNavigation() complete:^(BOOL loginState) {
        }];
        return;
    }
    [view addSubview:self];
    [_textInputView becomeFirstResponder];
    
}
-(void)disMiss
{
    [_textInputView resignFirstResponder];
    [self hiddenEmotion];
}
-(void)hidden
{
    [self removeFromSuperview];
}

-(void)addEmotion:(id)sender
{
    if (isEmotionShown) {
        [self hiddenEmotion];
        [_textInputView becomeFirstResponder];
    }else{
        isEmotionShown = true;
        [self showEmotion];
        [_textInputView resignFirstResponder];
    }
}
-(void)hiddenEmotion
{
    isEmotionShown = false;
    CGFloat y = self.height;
    [UIView animateWithDuration:KeyBoardAnimationInteval animations:^{
        _facialView.y = y;
    } completion:^(BOOL finished) {
        if (!iskeyBoardShown) {
            [self hidden];
        }
    }];
}
-(void)showEmotion
{
    CGFloat y = self.height - FacialHeight;
    CGFloat ty = y - _toolBar.height;
    [UIView animateWithDuration:KeyBoardAnimationInteval animations:^{
        _facialView.y = y;
        _toolBar.y = ty;
    }];

}
-(void)addAttach:(id)sender
{
    if ([_delegate respondsToSelector:@selector(addAttach:)]) {
        [_delegate addAttach:sender];
    }
}

# pragma mark - TextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        if (self.textInputView.text.length == 0 ) {
            [CustomToast showMessageOnWindow:@"您没有输入任何内容"];
            return false;
        }
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [AppWindow addSubview:hud];
        [hud show:true];
        if (self.textInputView.text.length == 0) {
            self.textInputView.text = @"";
        }
        __block CommentEntity *comment = nil;
        NSDictionary *params = @{
                                 @"content":self.textInputView.text
                                 };
        CRWeekRef(self);
        [MSGRequestManager Post:kAPINewPubComment(_msg.mid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            comment = [CommentEntity buildInstanceByJson:data];
                //评论成功
            if ([_delegate respondsToSelector:@selector(inSertComment:)]) {
                [_delegate performSelector:@selector(inSertComment:) withObject:comment];
            }
            [__self disMiss];
            _textInputView.text = nil;
            [hud hide:true];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            [CustomToast showMessageOnWindow:msg];
        }];
        return false;
    }
    
    textView.height = textView.contentSize.height > 100 ? 100:textView.contentSize.height;
    _toolBar.height = 14 + textView.height;
    if (isEmotionShown) {
        _toolBar.y = self.height - FacialHeight - _toolBar.height;
    }else{
        _toolBar.y = self.height - keyBoardHeight - _toolBar.height;
    }
    _toolBarContentView.height = _toolBar.height;
    return true;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hiddenEmotion];
    [_textInputView resignFirstResponder];
}
-(NSString*)contentText
{
    return _textInputView.text;
}
-(void)dealloc
{
    [self removeNotification];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
