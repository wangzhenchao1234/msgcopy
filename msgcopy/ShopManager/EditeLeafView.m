//
//  EditeLeafView.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/12.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "EditeLeafView.h"

@implementation EditeLeafView
-(void)awakeFromNib
{
    _mainView.layer.cornerRadius = 5;
    _mainView.clipsToBounds = true;
    _mainView.alpha = 0;
}
+(void)showEdite:(LeafEntity*)leaf complete:(void(^)(BOOL confirm))complete
{
    EditeLeafView *view = [Utility nibWithName:@"EditeLeafView" index:0];
    view.callBack = complete;
    view.frame = AppWindow.bounds;
    view.leaf = leaf;
    view.type = EditeType;
    view.inputView.text = leaf.title;
    [AppWindow addSubview:view];
    [UIView animateWithDuration:.25 animations:^{
        view.mainView.alpha = 1;
    }];
    
}
+(void)showAdd:(LimbEntity *)limb complete:(void (^)(BOOL))complete
{
    EditeLeafView *view = [Utility nibWithName:@"EditeLeafView" index:0];
    view.callBack = complete;
    view.frame = AppWindow.bounds;
    view.limb = limb;
    view.type = AddType;
    [AppWindow addSubview:view];
    [UIView animateWithDuration:.25 animations:^{
        view.mainView.alpha = 1;
    }];

}
-(void)hidden
{
    [UIView animateWithDuration:.25 animations:^{
        _mainView.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (IBAction)modify:(id)sender {
    
    if ([_inputView.text length]==0) {
        [CustomToast showMessageOnWindow:@"请输入内容"];
        return;
    }
    CRWeekRef(self);
    [MBProgressHUD showMessag:nil toView:AppWindow];
    if (_type == EditeType) {
        [MSGRequestManager MKUpdate:kAPIleaf(_leaf.lid) params:@{@"title":_inputView.text} success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
            [__self hidden];
            __self.leaf.title = __self.inputView.text;
            if (__self.callBack) {
                __self.callBack(true);
            }
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
            [CustomToast showMessageOnWindow:msg];
        }];
    }else{
        NSDictionary *params = @{
                                 @"title":_inputView.text,
                                 @"readonly":@"true",
                                 @"limb":CRString(@"%d",_limb.lid),
                                 };
        [MSGRequestManager Post:kAPICreateLeaf params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
            LeafEntity *leaf = [LeafEntity buildInstanceByJson:data];
            [_limb.leafs addObject:leaf];
            if (__self.callBack) {
                __self.callBack(true);
            }

        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [MBProgressHUD hideAllHUDsForView:AppWindow animated:false];
            [CustomToast showMessageOnWindow:msg];
        }];
    
    }
 
    
}
- (IBAction)cancel:(id)sender {
    [self hidden];
    if (_callBack) {
        _callBack(false);
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
