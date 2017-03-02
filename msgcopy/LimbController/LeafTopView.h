//
//  KKLeafTop.h
//  Kaoke
//
//  Created by xiaogu on 14-1-7.
//
//

#import <UIKit/UIKit.h>

@class LeafTop;

@interface LeafTopView : UIView<UIScrollViewDelegate>
@property (nonatomic,retain) UIScrollView *mainScrollView;
@property (nonatomic,retain) UIPageControl *pageControl;
@property (nonatomic,retain) UILabel *title;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) UIView *titleBg;
@property (nonatomic,retain) LeafEntity *leaf;
- (id)initWithFrame:(CGRect)frame leaf:(LeafEntity*)leaf;
-(void)begainAnimation;
-(void)stopAnimation;
@end
