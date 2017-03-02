//
//  UIWebView+javaScript.m
//  Kaoke
//
//  Created by xiaogu on 14-1-15.
//
//

#import "UIWebView+javaScript.h"


static BOOL diagStat = NO;
@implementation UIWebView (javaScript)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:message delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [actionSheet showInView:self];
    while (actionSheet.visible == YES) {
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    }
    return diagStat;
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
    
        diagStat = YES;
        
    }else{
    
        diagStat = NO;
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        diagStat = NO;
    }
}
-(void)web_console_info:(NSString *)logInfo{
    
    NSLog(@"web console line :%@",logInfo);
    
}
@end
