//
//  CRKeyboardUtility.h
//
//  Created by RoundTu on 11/13/13.
//  Copyright (c) 2013 Cocoa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRKeyboardUtility : NSObject

+ (BOOL)startObserving;

+ (BOOL)isKeyboardVisible;
+ (CGRect)keyboardFrame;
@end
