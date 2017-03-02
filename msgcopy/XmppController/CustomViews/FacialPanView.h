//
//  FacialView.h
//  Kaoke
//
//  Created by xiaogu on 14-9-17.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacialView.h"

@interface FacialPanView : UIView<UIScrollViewDelegate>{
    id facialTarget;
}
- (id)initWithFrame:(CGRect)frame target:(id)target;
@property (nonatomic,strong)UIScrollView *mainView;
@property (nonatomic,strong)UIPageControl *pageControl;
@end
