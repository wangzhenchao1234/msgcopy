//
//  MsgContentController.m
//  msgcopy
//
//  Created by wngzc on 15/7/10.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MsgContentController.h"
#import "ShareView.h"
#import "CommentsController.h"
#import "MsgInfo.h"

@interface MsgContentController ()

@end

@implementation MsgContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(NSString*)webModalName:(NSString*)htmlPath{
    NSString *modelName = _msg.ctype.systitle;
    return modelName;
}
-(NSArray*)intilizedToolbarItems{
    
    NSMutableArray *toolbarItems = [NSMutableArray new];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    if (![WXAppID isEqualToString:@"null"]||[WXAppID length]>0||![AppKey_Sina isEqualToString:@"null"]||[AppKey_Sina length]>0) {
        UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [share setImage:[UIImage imageNamed:@"bt_share"] forState:UIControlStateNormal];
        [share addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:share];
        [toolbarItems addObject:shareItem];
        [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    }
    
    UIButton *like = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [like setImage:[UIImage imageNamed:@"bt_like"] forState:UIControlStateNormal];
    [like addTarget:self action:@selector(doLike:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *likeItem = [[UIBarButtonItem alloc] initWithCustomView:like];
    [toolbarItems addObject:likeItem];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    UIButton *more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [more setImage:[UIImage imageNamed:@"ic_more"] forState:UIControlStateNormal];
    [more addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:more];
    [toolbarItems addObject:moreItem];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    return toolbarItems;
}

/**
 *  初始化电商功能菜单
 */
-(void)buildTopToolbar{
    
    self.topMenus = [NSMutableArray new];
    if (![WXAppID isEqualToString:@"null"]||[WXAppID length]>0||![AppKey_Sina isEqualToString:@"null"]||[AppKey_Sina length]>0) {
        KxMenuItem *share = [KxMenuItem menuItem:@"分享" image:[UIImage imageNamed:@"ic_msg_share"] target:self action:@selector(doShare:)];
        [self.topMenus addObject:share];
    }
    KxMenuItem *like = [KxMenuItem menuItem:@"点赞" image:[UIImage imageNamed:@"bt_like"] target:self action:@selector(doLike:)];
    [self.topMenus addObject:like];
    
    WebAppEntity *chat = CRWebAppTitle(@"chatroom");
    WebAppEntity *server = CRWebAppTitle(@"customerservice");
    if (chat||server) {
        KxMenuItem *server = [KxMenuItem menuItem:@"咨询" image:[UIImage imageNamed:@"ic_server_black"] target:self action:@selector(connectToServer:)];
        [self.topMenus addObject:server];
    }
    KxMenuItem *more = [KxMenuItem menuItem:@"更多" image:[UIImage imageNamed:@"ic_more"] target:self action:@selector(showMore:)];
    [self.topMenus addObject:more];
    
}
/**
 *  调用初始化js
 *
 *  @param
 */
-(void)loadfinished:(NSArray*)datas{
    
    NSString *jsonStr;
    NSString *from = @"";
    if ([_msg.source length] >0) {
        from = _msg.source;
    }
    jsonStr = [NSString stringWithFormat:@"insertContent(%@,1,%d,\"%@\")",_msg.msgJson,self.currentFont,from];
    [self.webView stringByEvaluatingJavaScriptFromString:jsonStr];
    
}
/**
 * 更多
 */
-(void)showMore:(id)sender
{
    MsgInfo *info = [Utility nibWithName:@"MsgInfo" index:0];
    [info intilizedDataBy:_msg];
    info.delegate = (id<MsgInfoDelegate>)self;
    [info show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
