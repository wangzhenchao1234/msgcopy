//
//  XMTabBarController.m
//  msgcopy
//
//  Created by Gavin on 15/5/28.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "XMTabBarController.h"
#import "XMSingleListController.h"
#import "XMRoomListController.h"

@interface XMTabBarController ()
{
    UISegmentedControl *_segmentControl;
}
@end

@implementation XMTabBarController

-(id)init{
    
    self = [super init];
    if (self) {
        
    }
    return self;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setChildItems];
    [self setTitleView];
    // Do any additional setup after loading the view.
}
/**
 *  设置viewController
 */
-(void)setChildItems{
    
    WebAppEntity *chat = CRWebAppTitle(@"chatroom");
    WebAppEntity *chatGroup = CRWebAppTitle(@"groupchat");
    XMSingleListController *chatList = [Utility nibWithName:@"XMSingleListController" index:0];
    XMRoomListController *room =  [Utility nibWithName:@"XMRoomListController" index:0];;
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSArray *controllers = nil;
    if (chat&&chatGroup) {
        controllers = @[chatList,room];
    }else if(chat){
        controllers = @[chatList];
    }else{
        controllers = @[room];
    }
    self.viewControllers = controllers;
    self.tabBar.hidden = true;
    
}
/**
 *  设置标题
 */
-(void)setTitleView{
    
    WebAppEntity *chat = CRWebAppTitle(@"chatroom");
    WebAppEntity *chatGroup = CRWebAppTitle(@"groupchat");
    _segmentControl = [[UISegmentedControl alloc] initWithItems:@[chat.title_client?chat.title_client:@"",chatGroup.title_client?chatGroup.title_client:@""]];
    _segmentControl.selectedSegmentIndex = 0;
    _segmentControl.tintColor = [UIColor colorFromHexRGB:@"33b5e5"];
    [_segmentControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 26, 60)];
    title.font = [UIFont boldSystemFontOfSize:18];
    //聊天群聊
    if (chat&&chatGroup) {
        self.navigationItem.titleView = _segmentControl;
    }else if(chat){
        //聊天
        title.text = chat.title_client;
        self.navigationItem.titleView = title;
    }else{
        //群聊
        title.text = chatGroup.title_client;
        self.navigationItem.titleView = title;
    }
    
}
/**
 *  设置segment
 *
 *  @param seg 
 */
-(void)segmentAction:(UISegmentedControl *)seg{
    
    [self setSelectedIndex:seg.selectedSegmentIndex];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    NSLog(@"dealloc");
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
