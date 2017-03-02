//
//  CRKeyboardUtility.m
//
//  Created by RoundTu on 11/13/13.
//  Copyright (c) 2013 Cocoa. All rights reserved.
//

#import "CRKeyboardUtility.h"
#import "CRMacros.h"

@interface CRKeyboardManager : NSObject
{
    BOOL keyboardVisibility;
}
@property (nonatomic, readonly, getter = isKeyboardVisible) BOOL keyboardVisible;
@property (nonatomic, readonly) CGRect keyboardFrame;
+ (id)sharedManager;
@end

@implementation CRKeyboardManager
CRManager(CRKeyboardManager);

- (id)init {
    if (self=[super init]) {
        CRRegisterNotification(SELE(keyboardWillBeShown:), UIKeyboardWillShowNotification);
        CRRegisterNotification(SELE(keyboardWillBeHidden:), UIKeyboardWillHideNotification);
    }
    return self;
}

- (BOOL)isKeyboardVisible {
    return keyboardVisibility;
}

- (void)keyboardWillBeShown:(NSNotification *)notification {
    keyboardVisibility = YES;
    
    NSDictionary *info = [notification userInfo];
    _keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    keyboardVisibility = NO;
    _keyboardFrame = CGRectZero;
}


@end



@implementation CRKeyboardUtility
+ (BOOL)startObserving {
    CRKeyboardManager *keyboardMgr = [CRKeyboardManager sharedManager];
    if (keyboardMgr) {
        return YES;
    }
    return NO;
}
+ (BOOL)isKeyboardVisible {
    CRKeyboardManager *keyboardMgr = [CRKeyboardManager sharedManager];
    return keyboardMgr.keyboardVisible;
}

+ (CGRect)keyboardFrame {
    CRKeyboardManager *keyboardMgr = [CRKeyboardManager sharedManager];
    return keyboardMgr.keyboardFrame;
}


@end
