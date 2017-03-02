//
//  AppBannerView.m
//  Kaoke
//
//  Created by xiaogu on 14-9-9.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "AppBannerView.h"
#import "AppBannerEntity.h"

@implementation AppBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
+(AppBannerView*)buildInatanceByBanner:(AppBannerEntity*)banner target:(id)target frame:(CGRect)frame{
    AppBannerView *bannerView = [[AppBannerView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, banner.height)];
    bannerView.banner = banner;
    bannerView.clipsToBounds = YES;
    bannerView.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, banner.height)];
    bannerView.mainScrollView.pagingEnabled = YES;
    int count = [banner.items count];
    int itemCount = [banner.items count];
    if (count>=2) {
        count = count+2;
        bannerView.mainScrollView.contentOffset = CGPointMake(frame.size.width, 0);
    }
    bannerView.mainScrollView.contentSize = CGSizeMake(count*frame.size.width, banner.height);
    bannerView.mainScrollView.delegate = bannerView;
    bannerView.mainScrollView.showsHorizontalScrollIndicator = NO;
    for (int i = 0; i<count; i++) {
        TopImageView *topImage = [[TopImageView alloc] initWithFrame:CGRectMake(i*frame.size.width, 0, frame.size.width, banner.height)];
        topImage.tag = i;
        if (itemCount>=2) {
            if (i == 0) {
                topImage.tag = itemCount -1;
            }else if(i == count-1){
                topImage.tag = 0;
            }else{
                topImage.tag = i-1;
            }
        }
        BannerItem *top;
        if (i == 0) {
           top  = [banner.items lastObject];
        }else if(i == count-1){
            top = banner.items[0];
        }else{
            top = banner.items[i-1];
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:bannerView action:@selector(tap:)];
        [topImage addGestureRecognizer:tap];
        [topImage.image sd_setImageWithURL:[NSURL URLWithString:top.image] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
            image = nil;
        }];
        [bannerView.mainScrollView addSubview:topImage];
    }
    if (count>1) {
        bannerView.mainScrollView.contentOffset = CGPointMake(frame.size.width, 0);
    }
    [bannerView addSubview:bannerView.mainScrollView];
    
    CGSize titleSize;
    if (itemCount>0) {
        titleSize = [banner.descr sizeWithFont:MSGFont(18) constrainedToSize:CGSizeMake(200, 22) lineBreakMode:NSLineBreakByTruncatingMiddle];
    }
   
    if (itemCount>1) {
        bannerView.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(frame.size.width - 5 - 15 - itemCount*15, banner.height-25, 15 + itemCount*15, 20)];
        bannerView.pageControl.backgroundColor = [UIColor clearColor];
        bannerView.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        bannerView.pageControl.numberOfPages = itemCount;
        bannerView.pageControl.currentPage = 0;
        [bannerView.pageControl addTarget:bannerView action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
        [bannerView addSubview:bannerView.pageControl];
    }
    
    bannerView.title = [[UILabel alloc] initWithFrame:CGRectMake(5, banner.height-25, frame.size.width - bannerView.pageControl.frame.size.width - 10 , 20)];
    bannerView.title.backgroundColor = [UIColor clearColor];
    bannerView.title.font = MSGFont(18);
    bannerView.title.textColor = [UIColor whiteColor];
    bannerView.title.shadowColor = [UIColor blackColor];
    bannerView.title.shadowOffset = CGSizeMake(1, 1);
    BannerItem *top = banner.items[0];
    bannerView.title.text = top.title;
    [bannerView addSubview:bannerView.title];
    bannerView.titleBg = [[UIView alloc] initWithFrame:CGRectMake(0,banner.height - 30 , [UIScreen mainScreen].bounds.size.width, 30)];
//    bannerView.titleBg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    bannerView.titleBg.backgroundColor = CRCOLOR_CLEAR;
    [bannerView insertSubview:bannerView.titleBg belowSubview:bannerView.title];
    [bannerView startAnimation];
    bannerView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    bannerView.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    
    return bannerView;
}
-(void)startAnimation{
    NSInteger itemCount = [self.banner.items count];
    if (itemCount > 1&&self.banner.interval>0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.banner.interval target:self selector:@selector(doAnimation) userInfo:nil repeats:YES];
    }
}
-(void)stopAnimation{
    
    [self.timer invalidate];

}
-(void)doAnimation{
    
    CGPoint pt = self.mainScrollView.contentOffset;
    pt.x += self.frame.size.width;
    self.pageControl.currentPage = pt.x/self.frame.size.width-1;
    BannerItem *top;
    if (self.banner.items && self.banner.items.count > self.pageControl.currentPage) {
        top = self.banner.items[self.pageControl.currentPage];
    }
    self.title.text = top.title;
    
    [UIView animateWithDuration:.5 animations:^{
        self.mainScrollView.contentOffset = pt;
    } completion:^(BOOL finished) {
        if (self.mainScrollView.contentOffset.x/self.frame.size.width==self.banner.items.count+1) {
            self.pageControl.currentPage = 0;
            self.mainScrollView.contentOffset =CGPointMake(self.frame.size.width, 0);
            BannerItem *top = self.banner.items[self.pageControl.currentPage];
            self.title.text = top.title;
        }
    }];
    
}
-(void)tap:(UITapGestureRecognizer*)tap{
    
//    BannerItem *top = self.banner.items[tap.view.tag];
//    KaokeViewController *viewController = (KaokeViewController*)CRController(self);
//    if ([top.clickType isEqualToString:@"pub"]) {
//        
//        [viewController showDataWithDataID:[top.clickValue integerValue] type:PUBLICATION];
//        
//    }else if([top.clickType isEqualToString:@"weblink"]){
//        
//        KaokePublicationEntity *pub = [[KaokePublicationEntity alloc] init];
//        KaokeMsgEntity *msg = [[KaokeMsgEntity alloc] init];
//        msg.ctype = [[Ctype alloc] init];
//        msg.ctype.systitle = @"lianjie";
//        pub.article = msg;
//        msg.links = [NSMutableArray arrayWithObject:top.clickValue];
//        [viewController showData:pub];
//        
//    }
}
-(void)pageChanged:(UIPageControl*)pageControl{
    BannerItem *top = self.banner.items[pageControl.currentPage];
    self.mainScrollView.contentOffset = CGPointMake((pageControl.currentPage+1)*self.frame.size.width, 0);
    self.title.text = top.title;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (self.mainScrollView.contentOffset.x <self.mainScrollView.frame.size.width) {
        self.mainScrollView.contentOffset = CGPointMake([self.banner.items count]*self.frame.size.width, 0);
    }
    if (self.mainScrollView.contentOffset.x >self.mainScrollView.frame.size.width*[self.banner.items count]) {
        self.mainScrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
    }
    self.pageControl.currentPage = self.mainScrollView.contentOffset.x/self.frame.size.width-1;
    BannerItem *top = self.banner.items[self.pageControl.currentPage];
    self.title.text = top.title;
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
-(void)removeFromSuperview{
    [self stopAnimation];
    _mainScrollView = Nil;
    _pageControl  = Nil;
}
-(void)dealloc{
    _mainScrollView = Nil;
    _pageControl  = Nil;
    _banner = nil;

}


@end

@implementation TopImageView
@synthesize image = _image;

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *colorArray = @[@[@"232",@"35",@"41"],@[@"238",@"153",@"33"],@[@"116",@"193",@"142"],@[@"60",@"195",@"237"],@[@"255",@"202",@"8"],@[@"29",@"121",@"186"],@[@"196",@"60",@"149"],@[@"39",@"132",@"66"]];
        NSInteger index = arc4random()%8;
        NSArray *color  = colorArray[index];
        _image = [[UIImageView alloc]
                  initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_image];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.clipsToBounds = YES;
        self.image.backgroundColor = [UIColor colorWithRed:[color[0] floatValue]/255 green:[color[1] floatValue]/255 blue:[color[2] floatValue]/255 alpha:1];
    }
    return self;
}
-(void)dealloc{
    _image = Nil;
}
@end
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
