//
//  UserHelperController.m
//  msgcopy
//
//  Created by Gavin on 15/6/19.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "UserHelperController.h"
#import "LauncherController.h"

@interface UserHelperController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    NSArray *_imagePaths;
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
}
@property(nonatomic,assign)BOOL ishome;

@end

@implementation UserHelperController


- (instancetype)initWithHome:(BOOL)isHome
{
    self = [super init];
    if (self) {
        _ishome = isHome;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self intilizedDataSource];
    [self loadScrollView];
    // Do any additional setup after loading the view.
}
-(void)intilizedDataSource{
    //intilizedDataSource
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/welcome.bundle"];
    _imagePaths = CRFilesForType(path, @"png");
}
-(void)loadScrollView{
    self.automaticallyAdjustsScrollViewInsets = false;
    self.navigationController.navigationBarHidden = true;
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    CGSize size = _scrollView.contentSize;
    size.width = _imagePaths.count * _scrollView.width;
    _scrollView.contentSize = size;
    [self.view addSubview:_scrollView];
    _scrollView.pagingEnabled = true;
    _scrollView.bounces = false;
    _scrollView.showsHorizontalScrollIndicator = false;
    [_imagePaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *path = obj;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
        imageView.x = idx * _scrollView.width;
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        UIImage *scaleImage = [UIImage imageByScalingImage:image toSize:_scrollView.size];
        [imageView setImage:scaleImage];
        [_scrollView addSubview:imageView];
        if(idx == _imagePaths.count-1){
            imageView.userInteractionEnabled = true;
            UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
            done.frame = CGRectMake(40, _scrollView.height - 44 - 80, imageView.width - 80, 44);
            done.backgroundColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
            [done setTitle:@"开   始" forState:UIControlStateNormal];
            [done setTitleColor:CRCOLOR_WHITE forState:UIControlStateNormal];
            done.titleLabel.font = MSGFont(17);
            done.layer.cornerRadius = 5;
            [done addTarget:self action:@selector(swp:) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:done];
        }
    }];
}

# pragma mark - 滑动手势

-(void)swp:(id)sender{
    //do something
    if (_ishome) {
        if ([AppDataManager sharedManager].splashBanner.items.count>0) {
            UIViewController *banner = [Utility controllerInStoryboard:@"Main" withIdentifier:@"AppBannerController"];
            [self.navigationController pushViewController:banner animated:true];
            return;
        }else{
            [LauncherController showHomePageController];
            return;
        }
    }
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(BOOL)shouldAutorotate{
    return false;
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
