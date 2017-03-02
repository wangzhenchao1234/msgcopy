//
//  FacialView.m
//  Kaoke
//
//  Created by xiaogu on 14-9-17.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "FacialPanView.h"
#import "EmotionManager.h"
#define keyBoardHeight 216
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@implementation FacialPanView

- (id)initWithFrame:(CGRect)frame target:(id)target
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, keyBoardHeight)];
        self.frame = CGRectMake(0, frame.origin.y, frame.size.width, keyBoardHeight);
        self.mainView.backgroundColor = [UIColor whiteColor];
        self.mainView.contentSize = CGSizeMake(3*frame.size.width, keyBoardHeight);
        self.mainView.pagingEnabled = true;
        self.mainView.delegate = self;
        self.mainView.showsVerticalScrollIndicator = false;
        self.mainView.showsHorizontalScrollIndicator = false;
        for (int i=0; i< 3; i++) {
            FacialView *fview=[[FacialView alloc] initWithFrame:CGRectMake(frame.size.width*i, 20, frame.size.width, 170)];
            [fview setBackgroundColor:[UIColor whiteColor]];
            [fview loadFacialView:i size:CGSizeMake(45, 45)];
            fview.delegate = target;
            [self.mainView addSubview:fview];
        }
        facialTarget = target;
        [self addSubview:_mainView];
        self.pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(20,keyBoardHeight-30, frame.size.width - 40, 30)];
        [self.pageControl setCurrentPage:0];
        self.pageControl.pageIndicatorTintColor=RGBACOLOR(195, 179, 163, 1);
        self.pageControl.currentPageIndicatorTintColor=RGBACOLOR(132, 104, 77, 1);
        self.pageControl.numberOfPages = 3;//指定页面个数
        [self.pageControl setBackgroundColor:[UIColor clearColor]];
        self.pageControl.userInteractionEnabled = false;
        [self addSubview:_pageControl];
    }
    return self;
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    int page = _mainView.contentOffset.x / self.frame.size.width;//通过滚动的偏移量来判断目前页面所对应的小白点
    _pageControl.currentPage = page;//pagecontroll响应值的变化
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
