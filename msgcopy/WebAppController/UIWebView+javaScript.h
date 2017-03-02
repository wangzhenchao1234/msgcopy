//
//  UIWebView+javaScript.h
//  Kaoke
//
//  Created by xiaogu on 14-1-15.
//
//

#import <UIKit/UIKit.h>

@interface UIWebView (javaScript)<UIActionSheetDelegate,UIAlertViewDelegate>
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
-(void)web_console_info:(NSString *)logInfo;
@end
