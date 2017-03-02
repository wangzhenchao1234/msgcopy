//
//  MSGNavigationController.m
//  msgcopy
//
//  Created by Gavin on 15/4/7.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MSGNavigationController.h"
#import "KxMovieViewController.h"

@interface MSGNavigationController ()<UINavigationBarDelegate,UINavigationControllerDelegate>

@end

@implementation MSGNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName:MSGFont(16),NSForegroundColorAttributeName:CRCOLOR_BLACK};
    // Do any additional setup after loading the view.
}
-(NSUInteger)supportedInterfaceOrientations
{
    if ([CRRootNavigation().topViewController isKindOfClass:NSClassFromString(@"KxMovieViewController")]) {
        KxMovieViewController *movie = (KxMovieViewController*)CRRootNavigation().topViewController;
        if ([movie fullscreen])
            return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}
-(BOOL)shouldAutorotate{
    return true;
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
