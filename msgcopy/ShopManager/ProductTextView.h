//
//  ProductTextView.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/9.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductTextView;

@protocol ProductTextViewDelegate <NSObject>
@optional
- (BOOL)textViewShouldBeginEditing:(ProductTextView *)textView;
- (BOOL)textViewShouldEndEditing:(ProductTextView *)textView;

- (void)textViewDidBeginEditing:(ProductTextView *)textView;
- (void)textViewDidEndEditing:(ProductTextView *)textView;

- (BOOL)textView:(ProductTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(ProductTextView *)textView;

- (void)textViewDidChangeSelection:(ProductTextView *)textView;

- (BOOL)textView:(ProductTextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0);
- (BOOL)textView:(ProductTextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0);
@end


@interface ProductTextView : UITextView<UITextViewDelegate>
@property(nonatomic,retain)UILabel *placeholder;
@property(nonatomic,copy)NSString *placeholderStr;
@property(nonatomic,weak)IBOutlet id<ProductTextViewDelegate> productDelegate;


@end
