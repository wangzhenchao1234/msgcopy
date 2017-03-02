//
//  WaterView.m
//  Water Waves
//
//  Created by wngzc on 14-5-23.
//  Copyright (c) 2014年 wngzc. All rights reserved.
//

#import "WaterView.h"

@interface WaterView ()
{
    float _currentLinePointY;
    float abs;
    float curProgress;
    float a;
    float curProgressText;
    float b;
    BOOL jia;
    NSTimer *timer;
    UILabel *_percentView;
}
@end


@implementation WaterView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        a = 1.5;
        b = 0;
        jia = NO;
        curProgress = 0;
        _currentWaterColor = [UIColor colorWithRed:86/255.0f green:202/255.0f blue:139/255.0f alpha:.7];
        _currentLinePointY = frame.size.height;
        _percentView = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height + 10, frame.size.width, 17)];
        _percentView.textAlignment = NSTextAlignmentCenter;
        _percentView.textColor = CRCOLOR_BLACK;
        _percentView.font = MSGFont(15);
        [self addSubview:_percentView];
        
    }
    return self;
}
-(void)setProgress:(CGFloat)progress{
    
    abs = (progress - curProgress)*self.frame.size.height/20;
    curProgress = progress;
    NSLog(@"progress == %f",curProgress);
    
}
-(void)startAnimation
{
   timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
}
-(void)stopAnimation
{
    [timer invalidate];
    timer = nil;
}
-(void)animateWave
{
    if (jia) {
        a += 0.01;
    }else{
        a -= 0.01;
    }
    
    
    if (a<=1) {
        jia = YES;
    }
    
    if (a>=1.5) {
        jia = NO;
    }
    if (_currentLinePointY > self.frame.size.height *(1- curProgress)) {
        _currentLinePointY -= abs;
    }
    if (_currentLinePointY<=0) {
        [self stopAnimation];
        if ([_delegate respondsToSelector:@selector(finishedLoading)]) {
            [_delegate finishedLoading];
        }
    }
    b+=0.1;
    curProgressText = (1-(_currentLinePointY/self.frame.size.height))*100;
    NSString *text = CRString(@"%.0f%%",curProgressText);
    _percentView.text = text;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    //画水
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [_currentWaterColor CGColor]);
    
    float y=_currentLinePointY;
    CGPathMoveToPoint(path, NULL, 0, y);
    for(float x=0;x<=rect.size.width;x++){
        y= a * sin( x/180*4*M_PI + 4*b/M_PI ) * 2 + _currentLinePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, rect.size.width, 0);
    CGPathAddLineToPoint(path, nil, 0, 0);
    CGPathAddLineToPoint(path, nil, 0, _currentLinePointY);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
    
}


@end
