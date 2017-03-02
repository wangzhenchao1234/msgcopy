//
//  ViewController.m
//  GSliderViewController
//
//  Created by Gavin on 15/2/6.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "GSliderViewController.h"

@interface GSliderViewController ()<UIGestureRecognizerDelegate>
{
    CGPoint slidBegin;
    CGPoint slidEnd;
    CGPoint slidChange;
    
    CGFloat centerBegin;
    CGAffineTransform _centerTransform;
    CATransform3D _centerTransfom3D;
//    CGFloat rightBegin;
//    CGFloat leftBegin;
    
}
@property(nonatomic,retain)UIPanGestureRecognizer* panGesture;
@property(nonatomic,retain)UITapGestureRecognizer* tapGesture;
@property(nonatomic,retain)UINavigationBar       * gNaviBar;
@property(nonatomic,assign)CGRect                gNaviBarFrame;
@property(nonatomic,retain)UIViewController *oldRightController;
@property(nonatomic,retain)UIViewController *oldLeftController;
@property(nonatomic,retain)UIViewController *oldCenterController;

@end

@implementation GSliderViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        panGestureEnabled = true;
        tapGestureEnabled = true;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /**
     *  导航栏透明
     */
    [Utility setTransparentNavigation:CRRootNavigation() navBarTransparent:TransParentNavBg];
    CRRootNavigation().navigationBar.hidden = true;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    /**
     *  导航栏不透明
     */
    CRRootNavigation().navigationBar.hidden = false;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addPanGesture];
    [self defaultOptions];
    [self loadChildControllers];
    [self addObservers];
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark - 加载手势
/**
 *  加载手势
 */
-(void)addPanGesture{
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:_panGesture];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    _tapGesture.delegate = self;
    [self.view addGestureRecognizer:_tapGesture];
    _panGesture.enabled = panGestureEnabled;
    _tapGesture.enabled = tapGestureEnabled;
}
/**
 *  禁用手势
 */
-(void)disablePanGestrue
{
   _panGesture.enabled = false;
    panGestureEnabled = false;
}
/**
 *  开启手势
 */
-(void)enablePanGestrue
{
    _panGesture.enabled  = true;
    panGestureEnabled = true;
}
/**
 *  禁用手势
 */
-(void)disableTapGestrue
{
    _tapGesture.enabled  =false;
    tapGestureEnabled = false;
}
/**
 *  开启手势
 */
-(void)enableTapGestrue
{
    _tapGesture.enabled  =true;
    tapGestureEnabled = true;
}
#pragma mark - 手势代理
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{

    CGPoint pt = [touch locationInView:self.view];
    CGFloat abs = (self.view.frame.size.width - self.view.frame.size.width * _scale) / 2.0f;
    if (_slidState == GSlidState_Left) {
        if (pt.x >= _maxLeftPan + abs) {
            return true;
        }
    }else if(_slidState == GSlidState_Right){
        if (pt.x <=  self.view.frame.size.width - _maxRightPan - abs) {
            return true;
        }
    }
    return false;
}
#pragma mark - 加载默认设置
/**
 *  加载默认设置
 */

-(void)defaultOptions{
    
    _maxRightPan = self.view.frame.size.width*2/3.0f;
    _maxLeftPan = self.view.frame.size.width*2/3.0f;
    _scale = 0.8;
    _flip = 0;
    _rightAnimationDraution = .35f;
    _leftAnimationDraution = .35;
    _chageDirectionPan = 80;
    _centerTransform =  self.view.transform;
    _centerTransfom3D = self.view.layer.transform;
    self.view.backgroundColor = CRCOLOR_WHITE;
//    self.view.layer.sublayerTransform = CATransform3DMakePerspective(1000);
    
}
#pragma mark - 加载子viewController
/**
 *  加载子viewController
 */
-(void)loadChildControllers
{
    if (_leftViewController) {
        [self addChildViewController:_leftViewController];
        [self.view addSubview:_leftViewController.view];
        _oldLeftController = _leftViewController;
    }
    if (_rightViewController) {
        [self addChildViewController:_rightViewController];
        [self.view addSubview:_rightViewController.view];
        _oldRightController = _rightViewController;
    }
    if (_centerViewController) {
        [self addChildViewController:_centerViewController];
        [self.view addSubview:_centerViewController.view];
        _centerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _oldCenterController = _centerViewController;
    }
}
-(void)reloadControllers
{
    [_leftViewController.view removeFromSuperview];
    [_leftViewController removeFromParentViewController];
    [_rightViewController.view removeFromSuperview];
    [_rightViewController removeFromParentViewController];
    [_centerViewController.view removeFromSuperview];
    [_centerViewController removeFromParentViewController];
 
    [self loadChildControllers];
    
}
#pragma mark - 设置监听
/**
 *  设置监听
 */

-(void)addObservers
{
    [_centerViewController.view addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}
#pragma mark - 设置打开效果
/**
 *  设置打开效果
 */
-(void)setSlidType:(GSlidType)slidType{
    _slidType = slidType;
}

/**
 *  中栏
 *
 *  @param centerViewController
 */
-(void)setCenterViewController:(UIViewController *)centerViewController
{
    [self setCenterContetViewController:centerViewController];
}
/**
 *  左栏
 *
 *  @param leftViewController
 */
-(void)setLeftViewController:(UIViewController *)leftViewController
{
    [self setLeftContetViewController:leftViewController];
}
/**
 *  右栏
 *
 *  @param rightViewController
 */
-(void)setRightViewController:(UIViewController *)rightViewController
{
    [self setRightContetViewController:rightViewController];
}
#pragma mark - 设置中栏
/**
 *  设置中栏
 */

-(void)setCenterContetViewController:(UIViewController*)center
{
    if (_oldCenterController) {
        [_oldCenterController.view removeFromSuperview];
        [_oldCenterController removeObserver:self forKeyPath:@"center"];
        [_oldCenterController removeFromParentViewController];
    }
    _oldCenterController = nil;
    _centerViewController = center;

}
#pragma mark - 设置左栏
/**
 *  设置左栏
 */
-(void)setLeftContetViewController:(UIViewController*)left
{
    if (_oldLeftController) {
        [_oldLeftController.view removeFromSuperview];
        [_oldLeftController removeFromParentViewController];
    }
    _oldLeftController = nil;
    _leftViewController = left;
    
}
#pragma mark - 设置右栏
/**
 *  设置右栏
 */
-(void)setRightContetViewController:(UIViewController*)right
{
    if (_oldRightController) {
        [_oldRightController.view removeFromSuperview];
        [_oldRightController removeFromParentViewController];
    }
    _oldRightController = nil;
    _rightViewController = right;
}
#pragma mark - 显示阴影

/**
 *  显示阴影
 */
-(void)showShadow{
//    _centerViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
//    _centerViewController.view.layer.shadowRadius = 6.0f;
//    _centerViewController.view.layer.shadowOpacity = .4f;
//    _centerViewController.view.layer.shadowOffset = CGSizeZero;
}
#pragma mark - 隐藏阴影

/**
 *  隐藏阴影
 */
-(void)hiddenShadow{
//    _centerViewController.view.layer.shadowRadius = 0;
//    _centerViewController.view.layer.shadowOpacity = 0;;
//    _centerViewController.view.layer.shadowOffset = CGSizeZero;
}
#pragma mark - 点击手势

/**
 *  点击手势
 *
 *  @return tap
 */
-(void)tap:(UITapGestureRecognizer*)tap{
    CGPoint pt = [tap locationInView:self.view];
    CGFloat abs = (self.view.frame.size.width - self.view.frame.size.width * _scale) / 2.0f;
    if (_slidState == GSlidState_Left) {
        if (pt.x >= _maxLeftPan + abs) {
            [self showCenterWithAnimation:true complete:nil];
        }
    }else if(_slidState == GSlidState_Right){
        if (pt.x <=  self.view.frame.size.width - _maxRightPan - abs) {
            [self showCenterWithAnimation:true complete:nil];
        }
    }
}
#pragma mark - 拖动手势
/**
 *  拖动手势
 *
 *  @param pan 
 */
-(void)pan:(UIPanGestureRecognizer*)pan{
    
    CGPoint volocity = [pan velocityInView:self.view];
    
    if (volocity.x>0) {
        _slidDerection = SLIDTORIGHT;
    }else{
        _slidDerection = SLIDTOLEFT;
    }
    CGFloat gap = 0.0f;
    CGFloat centerX = _centerViewController.view.center.x;
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        slidBegin = [pan locationInView:self.view];
        centerBegin = _centerViewController.view.center.x;
        
    }else if(pan.state == UIGestureRecognizerStateChanged){
        
        slidChange = [pan locationInView:self.view];
        gap =  slidChange.x - slidBegin.x;
        centerX = centerBegin + gap;
//        NSLog(@"x == %f",centerX);
        if (centerX<self.view.center.x&&_rightViewController) {
            [_rightViewController viewWillAppear:true];
            [self showShadow];
            [self.view insertSubview:_rightViewController.view belowSubview:_centerViewController.view];
            
        }else if (centerX>self.view.center.x&&_leftViewController) {
            
            [_leftViewController viewWillAppear:true];
            [self showShadow];
            [self.view insertSubview:_leftViewController.view belowSubview:_centerViewController.view];
            
        }
        CGPoint ct = _centerViewController.view.center;
        ct.x = centerX;
        if ((centerX > self.view.center.x&&!_leftViewController)||(centerX<self.view.center.x&&!_rightViewController)){
            ct.x = self.view.center.x;
        }
        _centerViewController.view.center = ct;

    }else{
        
        slidEnd = [pan locationInView:self.view];
        if (_slidDerection == SLIDTOLEFT) {
            
            if (_centerViewController.view.center.x >= -_chageDirectionPan+self.view.center.x) {
                [self slidTo:0  animation:true complete:nil];
            }else{
                [self slidTo:-_maxLeftPan animation:true complete:nil];
            }
            
        }else{
            
            if (_centerViewController.view.center.x<=_chageDirectionPan + self.view.center.x) {
                [self slidTo:0 animation:true complete:nil];
            }else{
                [self slidTo:_maxRightPan animation:true complete:nil];
            }
            
        }
        
    }
    
}
#pragma mark - KVO
/**
 *  KVO 监听
 *
 *  @param keyPath 监听键
 *  @param object  监听对象
 *  @param change  触发值
 *  @param context context
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (object == _centerViewController.view) {
        if (_slidType == GSliderTypeSlidAndScale || _slidType == GSliderTypeAll) {
//            NSLog(@" x == %f y == %f",_centerViewController.view.center.x,_centerViewController.view.center.y);
            if (_scale < 1&&_centerViewController.view.center.x >= - _maxRightPan + self.view.center.x&&_centerViewController.view.center.x <= _maxLeftPan+self.view.center.x ) {
                CGFloat abs = fabs(_centerViewController.view.center.x - self.view.center.x);
                CGFloat curScale = _slidDerection == SLIDTOLEFT?abs/_maxRightPan:abs/_maxLeftPan;
                curScale *= (1-_scale);
                curScale = 1-curScale;
                CGAffineTransform newTransform = CGAffineTransformScale(_centerTransform, curScale, curScale);
                _centerViewController.view.transform = newTransform;
            }
        }
        
        if ( _slidType == GSliderTypeSlidAndFlip || _slidType == GSliderTypeAll) {
            
//            if (_flip < 1&&_centerViewController.view.center.x >= - _maxRightPan + self.view.center.x&&_centerViewController.view.center.x <= _maxLeftPan+self.view.center.x ) {
//                
//                CGFloat abs = fabs(_centerViewController.view.center.x - self.view.center.x);
//                CGFloat curFlip = _slidDerection == SLIDTOLEFT?abs/_maxRightPan:abs/_maxLeftPan;
//                curFlip *= (1-_flip);
//                curFlip = _slidDerection == SLIDTOLEFT ? -curFlip : curFlip;
//                NSLog(@" flip == %f",curFlip);
//
//            
//                _centerViewController.view.layer.transform = CATransform3DMakeRotation(curFlip, 0.0, 1.0, 0);
//
//
//            }
        }
    }
}
#pragma mark - 显示中栏
/**
 *  显示中栏
 *
 *  @param animation 动画
 *  @param complete  完成后执行
 */
-(void)showCenterWithAnimation:(BOOL)animation complete:(sliderAction)complete{
    if (!_centerViewController) {
        return;
    }
    [self slidTo:0 animation:true complete:complete];

}
#pragma mark - 显示左栏
/**
 *  显示左栏
 *
 *  @param animation 动画
 *  @param complete  完成后执行
 */
-(void)showLeftWithAnimation:(BOOL)animation complete:(sliderAction)complete{
    
    if (!_leftViewController) {
        return;
    }
    if (_slidState == GSlidState_Left) {
        [self showCenterWithAnimation:animation complete:complete];
        return;
    }
    [self slidTo:_maxLeftPan animation:true complete:complete];
    
}
#pragma mark - 显示右栏

/**
 *  显示右栏
 *
 *  @param animation 动画
 *  @param complete  完成执行
 */
-(void)showRightWithAnimation:(BOOL)animation complete:(sliderAction)complete{
    if (!_rightViewController) {
        return;
    }
    [self slidTo:-_maxRightPan animation:true complete:complete];
    
}
/**
 *  滑动动作
 *
 *  @param point    重点位置
 *  @param animated 动画
 *  @param complete 完成
 */
-(void)slidTo:(CGFloat)point animation:(BOOL)animated complete:(sliderAction)complete{
    
    CGFloat duration = point > 0 ? _rightAnimationDraution : -_leftAnimationDraution;
    CGPoint ct = _centerViewController.view.center;
    ct.x = point + self.view.center.x;
    [UIView animateWithDuration:duration animations:^{
        
        _centerViewController.view.center = ct ;
        
    } completion:^(BOOL finished) {
        
        if (point>0) {
            [_leftViewController viewDidAppear:true];
            _slidState = GSlidState_Left;
            _centerViewController.view.userInteractionEnabled = false;
        }else if(point<0){
            [_rightViewController viewDidAppear:true];
            _slidState = GSlidState_Right;
            _centerViewController.view.userInteractionEnabled = false;
        }else{
            [self hiddenShadow];
            [_centerViewController viewDidAppear:true];
            _slidState = GSlidState_Normal;
            _centerViewController.view.userInteractionEnabled = true;
        }
        if (complete) {
            complete(finished);
        }
        
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    if (_slidType == GSliderTypeSlid&&_centerViewController) {
        [_centerViewController.view removeObserver:self forKeyPath:@"center"];
    }
}
@end

/**
 *  childviewcontroller 获取sliderController
 */
@implementation UIViewController (GSliderViewController)

-(GSliderViewController*)g_sliderViewController{
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController != nil) {
        if([parentViewController isKindOfClass:[GSliderViewController class]]){
            return (GSliderViewController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}


@end
