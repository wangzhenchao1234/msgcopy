//
//  ViewController.h
//  GSliderViewController
//
//  Created by Gavin on 15/2/6.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

//static CGPoint midPoint(CGRect r) {
//    return CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));
//}
//
//static CATransform3D CATransform3DMakePerspective(CGFloat z) {
//    CATransform3D t = CATransform3DIdentity;
//    t.m34 = - 1.0 / z;
//    return t;
//}


typedef void(^sliderAction)(BOOL finished);

typedef  NS_OPTIONS(NSInteger, GSlidType){
    
    GSliderTypeSlid = 0,
    GSliderTypeSlidAndScale,
    GSliderTypeSlidAndFlip,
    GSliderTypeAll
};

typedef NS_ENUM(NSInteger, SlidDerection) {
    
    SLIDTOLEFT = 0,
    SLIDTORIGHT
    
};
typedef NS_ENUM(NSInteger,GSlidState ){
    
    GSlidState_Normal,
    GSlidState_Right,
    GSlidState_Left
    
};

@interface GSliderViewController : UIViewController
{
    BOOL panGestureEnabled;
    BOOL tapGestureEnabled;
    
}
@property (nonatomic,strong) UIViewController *centerViewController;
@property (nonatomic,strong) UIViewController *rightViewController;
@property (nonatomic,strong) UIViewController *leftViewController;
@property (nonatomic,assign) GSlidType     slidType;
@property (nonatomic,assign) SlidDerection slidDerection;
@property (nonatomic,assign) GSlidState    slidState;
@property (nonatomic,assign) CGFloat   maxLeftPan;
@property (nonatomic,assign) CGFloat   maxRightPan;
@property (nonatomic,assign) BOOL      scaleWhenSlide;
@property (nonatomic,assign) CGFloat   scale;
@property (nonatomic,assign) CGFloat   flip;
@property (nonatomic,assign) CGFloat   leftAnimationDraution;
@property (nonatomic,assign) CGFloat   rightAnimationDraution;
@property (nonatomic,assign) CGFloat   chageDirectionPan;

-(void)disablePanGestrue;
-(void)enablePanGestrue;
-(void)disableTapGestrue;
-(void)enableTapGestrue;

-(void)showLeftWithAnimation:(BOOL)animation complete:(sliderAction)complete;
-(void)showRightWithAnimation:(BOOL)animation complete:(sliderAction)complete;
-(void)showCenterWithAnimation:(BOOL)animation complete:(sliderAction)complete;

-(void)reloadControllers;

@end

@interface UIViewController (GSliderViewController)
-(GSliderViewController*)g_sliderViewController;
@end

