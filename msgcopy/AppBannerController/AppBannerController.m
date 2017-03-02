//
//  AppBannerController.m
//  msgcopy
//
//  Created by wngzc on 15/7/28.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "AppBannerController.h"
#import "AppBannerCell.h"
#import "LauncherController.h"

@interface AppBannerController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    
    NSArray *banners;
    NSTimer *timer;
}


@property (weak, nonatomic) IBOutlet UIView *pannelView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;


@end

@implementation AppBannerController

static NSString * const reuseIdentifier = @"BannerCell";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configSkipButton];
    [self intilizedDataSource];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startTimer];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self timerStop];
}
-(void)intilizedDataSource{
    //intilizedDataSource
    self.navigationController.navigationBarHidden = true;
    self.automaticallyAdjustsScrollViewInsets = false;
    AppBannerEntity *splashBanner = [AppDataManager sharedManager].splashBanner;
    banners = splashBanner.items;
    _pageControl.numberOfPages = banners.count;
    _pageControl.userInteractionEnabled = false;
    [self.collectionView reloadData];
    [self scrollViewDidScroll:self.collectionView];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorFromHexRGB:kCurApp.sideBar.selected_bgcolor];
}

-(void)configSkipButton
{
    
    //config some
    [_skipButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
    [_skipButton setTitleShadowColor:CRCOLOR_BLACK forState:UIControlStateNormal];
    [_skipButton setTitleShadowOffset:CGSizeMake(1, 1)];
    [_skipButton setTitleColor:[UIColor colorWithWhite:1 alpha:1.000] forState:UIControlStateNormal];
    [_skipButton setTitle:@" 跳过 >> " forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    
    return 0;
    
}


-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0;
    
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//#warning Incomplete method implementation -- Return the number of sections
    
    return 1;

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//#warning Incomplete method implementation -- Return the number of items in the section
    
    return banners.count;

}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    BannerItem *banner = CRArrayObject(banners, indexPath.row);
    if (banner) {
        switch (banner.clickType) {
            case BannerClickTypeLink:
                [LauncherController showHomePageController];
                [MSGTansitionManager openLink:banner.clickValue];
                break;
            case BannerClickTypePub:
                [LauncherController showHomePageController];
                [MSGTansitionManager openPubWithID:[banner.clickValue integerValue] withParams:nil];
                break;
                
            default:
                break;
        }
    }
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AppBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    // Configure the cell
    BannerItem *banner = CRArrayObject(banners, indexPath.row);
    if (banner) {
        [cell.imageView sd_setImageWithURL:CRURL(banner.image)];
    }
    return cell;
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self timerPause];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
    CGFloat x = scrollView.contentOffset.x;
    if (x >= scrollView.contentSize.width - scrollView.width) {
        CGFloat x = [scrollView.panGestureRecognizer velocityInView:scrollView].x;
        if (x < -40) {
            [self timerStop];
            [self skip:nil];
        }
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger index = scrollView.contentOffset.x/scrollView.width;
    
    if (_pageControl.numberOfPages > index ) {
        _pageControl.currentPage = index;
    }
    
    BannerItem *banner = CRArrayObject(banners, index);
    if (banner) {
        _titleView.text = banner.title;
    }
    
}

- (IBAction)skip:(id)sender {
    
    [LauncherController showHomePageController];
    
}


-(void)startTimer
{
    
    AppBannerEntity *splashBanner = [AppDataManager sharedManager].splashBanner;
    NSInteger interval = splashBanner.interval;
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(changeBanner:) userInfo:nil repeats:YES];
    }else{
        [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
    }
    
}

-(void)timerPause
{
    
    [timer setFireDate:[NSDate distantFuture]];
    
}

-(void)timerStop{
    
    [timer invalidate];
    timer = nil;
    
}

# pragma mark - 切换banner

-(void)changeBanner:(NSTimer*)sender{

    //do something
    NSInteger index = self.collectionView.contentOffset.x / self.collectionView.width;
    CGFloat x = self.view.width *(index+1);
    if (x > self.collectionView.width * (banners.count) - self.collectionView.width) {
        [self timerStop];
        [self skip:nil];
        return;
    }

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(BOOL)shouldAutorotate{
    return false;
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
