//
//  KKLeafTop.m
//  Kaoke
//
//  Created by xiaogu on 14-1-7.
//
//

#import "LeafTopView.h"


//#define LHIGHT AppWindow.width*180/320

@implementation LeafTopView
- (id)initWithFrame:(CGRect)frame leaf:(LeafEntity*)leaf
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _leaf = leaf;
        self.clipsToBounds = YES;
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
        _mainScrollView.pagingEnabled = YES;
        int count = [leaf.leafTops count];
        if ([leaf.leafTops count]>=2) {
            count = [leaf.leafTops count]+2;
            _mainScrollView.contentOffset = CGPointMake(frame.size.width, 0);
        }
        _mainScrollView.contentSize = CGSizeMake(count*frame.size.width, frame.size.height);
        _mainScrollView.delegate = self;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        for (int i = 0; i<count; i++) {
            LeafTop *top;
            UIImageView *topImage = [[UIImageView alloc] initWithFrame:CGRectMake(i*frame.size.width, 0, frame.size.width, frame.size.height)];
            topImage.tag = i;
            if ([leaf.leafTops count]>=2) {
                if (i == 0) {
                    topImage.tag = leaf.leafTops.count -1;
                }else if(i == count-1){
                    topImage.tag = 0;
                }else{
                    topImage.tag = i-1;
                }
            }
            if (i == 0) {
                top  = [leaf.leafTops lastObject];
            }else if(i == count-1){
                top = leaf.leafTops[0];
            }else{
                top = leaf.leafTops[i-1];
            }
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
            [topImage addGestureRecognizer:tap];
            /**
             *  memerry stack
             */
            [topImage sd_setImageWithURL:CRURL(top.imageUrl)];
            topImage.userInteractionEnabled = true;
            [_mainScrollView addSubview:topImage];
        }
        if (count>1) {
            _mainScrollView.contentOffset = CGPointMake(frame.size.width, 0);
        }
        [self addSubview:_mainScrollView];
        if ([leaf.leafTops count]>1) {
            _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(frame.size.width - 5 - 15 - [leaf.leafTops count]*15, frame.size.height-25, 15 + [leaf.leafTops count]*15, 20)];
            _pageControl.numberOfPages = [leaf.leafTops count];
            _pageControl.currentPage = 0;
            [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:_pageControl];
        }
        //    CGSize titleSize = [leaf.title sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(200, 22) lineBreakMode:NSLineBreakByTruncatingMiddle];
        
        CGFloat titleWidth = _mainScrollView.frame.size.width - _pageControl.frame.size.width - 10;
        _title = [[UILabel alloc] initWithFrame:CGRectMake(5, frame.size.height-25,titleWidth, 20)];
        _title.backgroundColor = [UIColor clearColor];
        _title.font = [UIFont boldSystemFontOfSize:18];
        _title.textColor = [UIColor whiteColor];
        _title.shadowColor = [UIColor blackColor];
        _title.shadowOffset = CGSizeMake(1, 1);
        LeafTop *top = leaf.leafTops[0];
        _title.text = top.descr;
        [self addSubview:_title];
//        _titleBg = [[UIView alloc] initWithFrame:CGRectMake(0,frame.size.height-30 , AppWindow.width, 30)];
        _titleBg.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [self insertSubview:_titleBg belowSubview:_title];
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    }
    return self;
}

-(void)startAnimation{
    
    CGPoint pt = _mainScrollView.contentOffset;
    pt.x += self.frame.size.width;
    _pageControl.currentPage = pt.x/self.frame.size.width-1;
    LeafTop *top = _leaf.leafTops[_pageControl.currentPage];
    _title.text = top.descr;
    NSArray *tops = _leaf.leafTops;
    [UIView animateWithDuration:.5 animations:^{
        _mainScrollView.contentOffset = pt;
    } completion:^(BOOL finished) {
        
        if ([_timer isValid]) {
            if (_mainScrollView.contentOffset.x/_mainScrollView.frame.size.width==tops.count+1) {
                _pageControl.currentPage = 0;
                _mainScrollView.contentOffset =CGPointMake(_mainScrollView.frame.size.width, 0);
                LeafTop *top = _leaf.leafTops[_pageControl.currentPage];
                _title.text = top.descr;
            }
        }
    }];
}

-(void)tap:(UITapGestureRecognizer*)tap{
    
    LeafTop *top = CRArrayObject(_leaf.leafTops, tap.view.tag);
    //action
    if (top) {
        if ([top.link integerValue]!=NSNotFound&&[top.link integerValue]!=0) {
            NSInteger pid = [top.link integerValue];
            [MSGTansitionManager openPubWithID:pid withParams:nil];
        }else{
            if (!top.link) {
                return;
            }
            [MSGTansitionManager openLink:top.link];
        }
        
    }else{
        [CustomToast showMessageOnWindow:@"访问的内容不存在"];
    }

}

-(void)pageChanged:(UIPageControl*)pageControl{
    LeafTop *top = _leaf.leafTops[pageControl.currentPage];
    _mainScrollView.contentOffset = CGPointMake((pageControl.currentPage+1)*_mainScrollView.frame.size.width, 0);
    _title.text = top.descr;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.x <_mainScrollView.frame.size.width) {
        scrollView.contentOffset = CGPointMake([_leaf.leafTops count]*_mainScrollView.frame.size.width, 0);
    }
    
    if (scrollView.contentOffset.x >_mainScrollView.frame.size.width*[_leaf.leafTops count]) {
        scrollView.contentOffset = CGPointMake(scrollView.width, 0);
    }
    _pageControl.currentPage = round(scrollView.contentOffset.x/scrollView.frame.size.width - 1);
    LeafTop *top = CRArrayObject(_leaf.leafTops,_pageControl.currentPage);
    if (top) {
        _title.text = top.descr;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self pauseAnimation];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self begainAnimation];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)begainAnimation
{
    if ([_leaf.leafTops count] == 0) {
        return;
    }
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(startAnimation) userInfo:nil repeats:YES];
    }else{
        [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:3]];
    }
}

-(void)stopAnimation
{
    CRLog(@"leaftop timer invalid");
    [_timer invalidate];
    _timer = nil;

}

-(void)pauseAnimation
{
    [_timer setFireDate:[NSDate distantFuture]];
}

-(void)removeFromSuperview{
    [super removeFromSuperview];

    CRLog(@"leaftop timer invalid");
    [_timer invalidate];
    _timer = nil;

}
-(void)dealloc
{
    CRLog(@"%@",NSStringFromClass(self.class));
    
}
@end

