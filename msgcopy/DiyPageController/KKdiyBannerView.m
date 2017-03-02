//
//  KKdiyItemView.m
//  Kaoke
//
//  Created by wngzc on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "KKdiyBannerView.h"

@interface KKdiyBannerView()<UIScrollViewDelegate>
{
   
    NSTimer *timer;
    void(^doAction)(id data);
}
@property(nonatomic,retain) DiyBannerEntity *bannerData;
@end
@implementation KKdiyBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _mainScrollView = [[UIScrollView alloc] initWithFrame:_contentView.frame];
        _mainScrollView.delegate = self;
        _mainScrollView.pagingEnabled = true;
        _mainScrollView.showsHorizontalScrollIndicator = false;
        _mainScrollView.alwaysBounceHorizontal = false;
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 25, frame.size.width, 25)];
        _titleView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 20, 25)];
        _titleLable.textColor = [UIColor whiteColor];
        [_titleLable setShadowOffset:CGSizeMake(1, 1)];
        [_titleLable setShadowColor:CRCOLOR_BLACK];
        _titleLable.font = MSGYHFont(16);
        [_titleView addSubview:_titleLable];
        [_contentView addSubview:_mainScrollView];
        [_contentView addSubview:_titleView];
        [self addSubview:_contentView];
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}
-(void)layoutSubviews{
    
    _mainScrollView.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);
    [_titleLable sizeToFit];
    CGRect frame = _titleLable.frame;
    frame.size.width = _contentView.frame.size.width - 20;
    frame.origin.x = 10;
    _titleLable.frame = frame;
    
    frame = _titleView.frame;
    frame.origin.x = 0;
    frame.size.width = _contentView.frame.size.width;
    frame.origin.y = _contentView.frame.size.height - _titleView.frame.size.height;
    _titleView.frame = frame;
    CGPoint ct = _titleLable.center;
    ct.y = _titleView.frame.size.height/2.0f;
    _titleLable.center = ct;
    
}

-(void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets{
    
     _contentView.frame = CGRectMake(contentEdgeInsets.left, contentEdgeInsets.top, _contentView.frame.size.width - contentEdgeInsets.left - contentEdgeInsets.right,_contentView.frame.size.height - contentEdgeInsets.bottom - contentEdgeInsets.top);
    _mainScrollView.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);
    [self setNeedsDisplay];
    
}

-(void)buildByData:(DiyBannerEntity*)data page:(DiyPageEntity *)page action:(onClick)action{
    
    self.bannerData = data;
    doAction = action;
    UIEdgeInsets inset = UIEdgeInsetsMake(
                                          [[data.padding valueForKey:@"top"] floatValue]*SQR(page.column),
                                          [[data.padding valueForKey:@"left"] floatValue]*SQR(page.column),
                                           [[data.padding valueForKey:@"bottom"] floatValue]*SQR(page.column),
                                           [[data.padding valueForKey:@"right"] floatValue]*SQR(page.column)
                                          );
    [self setContentEdgeInsets:inset];
    
    if (data.items.count > 0) {
        _titleLable.text = [data.items[0] valueForKey:@"descr"];
        for (int i = 0;i<self.bannerData.items.count + 2 ;i++) {
            NSDictionary *item = nil;
            if (i == 0) {
                item = [self.bannerData.items lastObject];
            }
            if (i == data.items.count+1) {
                item = self.bannerData.items[0];
            }
            if (i>0&&i<self.bannerData.items.count+1) {
               item = self.bannerData.items[i-1];
            }
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*_mainScrollView.frame.size.width,0, _mainScrollView.frame.size.width,_mainScrollView.frame.size.height)];
            imageView.tag = 100 + i;
//            imageView.contentMode = UIViewContentModeScaleToFill;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick:)];\
            [imageView addGestureRecognizer:tap];
            imageView.userInteractionEnabled = true;
            [imageView sd_setImageWithURL:[item valueForKey:@"bg_img"]];
            [_mainScrollView addSubview:imageView];
        }
    }
    _titleLable.font = MSGYHFont(15);
    _titleLable.textColor  = [UIColor whiteColor];
    if (self.bannerData.items.count>0) {
        _mainScrollView.contentSize = CGSizeMake((self.bannerData.items.count+2) * _mainScrollView.frame.size.width, _mainScrollView.frame.size.height);
        CGPoint pt = _mainScrollView.contentOffset;
        pt.x = _mainScrollView.frame.size.width;
        _mainScrollView.contentOffset = pt;
        if (self.bannerData.items.count>1) {
            _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(_titleView.frame.size.width - 5 - 15 - self.bannerData.items.count*15, 0, 15 + self.bannerData.items.count*15, 25)];
//            _pageControl.backgroundColor = [UIColor clearColor];
            _pageControl.numberOfPages = self.bannerData.items.count;
            _pageControl.currentPage = 0;
            _pageControl.userInteractionEnabled = false;
            [_titleView addSubview:_pageControl];
        }
        
    }
    if ([self.bannerData.bg_color length] == 7) {
        _contentView.backgroundColor = [UIColor colorFromHexRGB:[self.bannerData.bg_color substringFromIndex:1]];
    }
    
}

-(void)itemClick:(UITapGestureRecognizer*)item{
    
    NSArray *items = self.bannerData.items;
    if (items.count > item.view.tag  - 101) {
        NSDictionary *action = [items[item.view.tag  - 101] valueForKey:@"action"];
        doAction(action);
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGPoint of = _mainScrollView.contentOffset;
    if (of.x >= _mainScrollView.contentSize.width -_mainScrollView.frame.size.width-30) {
        _pageControl.currentPage = 0;
        of.x = _mainScrollView.frame.size.width;
        _mainScrollView.contentOffset = of;
        [self changeToPage:_pageControl.currentPage];

    }else if(of.x<=30){
        _pageControl.currentPage = self.bannerData.items.count-1;
        [self changeToPage:_pageControl.currentPage];
        of.x = _mainScrollView.contentSize.width - 2*_mainScrollView.frame.size.width;
        _mainScrollView.contentOffset = of;
    }else{
        _pageControl.currentPage = roundf(_mainScrollView.contentOffset.x/_mainScrollView.frame.size.width)-1;
        [self changeToPage:_pageControl.currentPage];
    }
}
-(void)changeToPage:(NSInteger)page{
    
    if (page>= self.bannerData.items.count) {
        return;
    }
    NSDictionary *item = self.bannerData.items[page];
    _titleLable.text = [item valueForKey:@"descr"];
    
}
-(void)changeTo:(NSTimer*)timer{
    
    [UIView animateWithDuration:.3 animations:^{
        CGPoint of = _mainScrollView.contentOffset;
        of.x += _mainScrollView.frame.size.width;
        self.mainScrollView.contentOffset = of;
    } completion:^(BOOL finished) {
        CGPoint of = _mainScrollView.contentOffset;
        if (ceil(of.x) >= floor(_mainScrollView.contentSize.width -_mainScrollView.frame.size.width)) {
            _pageControl.currentPage = 0;
            of.x = _mainScrollView.frame.size.width;
            _mainScrollView.contentOffset = of;
        }else{
            _pageControl.currentPage = roundf(_mainScrollView.contentOffset.x/_mainScrollView.frame.size.width)-1;
        }
        [self changeToPage:_pageControl.currentPage];
    }];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self pauseAnimation];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startAnimation];
}

-(void)removeFromSuperview{
    
    [super removeFromSuperview];
    if (timer&&timer.isValid) {
        [timer invalidate];
        timer = nil;
    }
}
-(void)pauseAnimation
{
    [timer setFireDate:[NSDate distantFuture]];
}

-(void)startAnimation
{
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:self.bannerData.interval/1000.0f target:self selector:@selector(changeTo:) userInfo:nil repeats:YES];
    }else{
        [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.bannerData.interval/1000.0f]];
    }
}
-(void)stopAnimation
{
    if (timer&&timer.isValid) {
        [timer invalidate];
        timer = nil;
    }
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
