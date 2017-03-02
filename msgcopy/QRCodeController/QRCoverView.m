//
//  SQCoverView.m
//  Kaoke
//
//  Created by xiaogu on 14-5-23.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "QRCoverView.h"
#define nsize  240
#define place ([UIScreen mainScreen].bounds.size.width -  240)/2
#define O_Y 120
@implementation QRCoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _line = [[UIImageView alloc] initWithFrame:CGRectMake(50, 150 , 220, 1)];
        _line.image = [UIImage imageNamed:@"line.png"];
        [self addSubview:_line];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginTransparencyLayerWithRect(context, CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width ,[UIScreen mainScreen].bounds.size.height), nil);
    
    CGContextSetRGBStrokeColor(context, 1, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetRGBFillColor(context,  0, 0, 0, 0);
    CGContextAddRect(context, CGRectMake(place+1, O_Y, nsize-2, nsize - 2));
    CGContextStrokePath(context);
    
    CGPoint sPoints[10];
    sPoints[0] =CGPointMake(0, 0);
    sPoints[1] =CGPointMake([UIScreen mainScreen].bounds.size.width,0 );
    sPoints[2] =CGPointMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    sPoints[3] =CGPointMake(0, [UIScreen mainScreen].bounds.size.height);
    sPoints[4] =CGPointMake(place, O_Y+nsize -1);
    sPoints[5] =CGPointMake(place+nsize,O_Y+nsize -1);
    sPoints[6] =CGPointMake(place+nsize, O_Y+nsize -1 - nsize);
    sPoints[7] =CGPointMake(place,O_Y+nsize -1 - nsize);
    sPoints[8] =CGPointMake(place, O_Y+nsize -1);
    sPoints[9] =CGPointMake(0,[UIScreen mainScreen].bounds.size.height);
    
    CGContextSetRGBFillColor(context, 0.3, 0.3, 0.3, 0.8);
    CGContextSetLineWidth(context, 0);
    CGContextAddLines(context, sPoints, 10);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextSetRGBStrokeColor(context, 14/255.0f, 169/255.0f, 220/255.0f, 1);
    CGContextSetLineWidth(context, 5.0);
    CGContextMoveToPoint(context,place+1,O_Y-2);
    CGContextAddLineToPoint(context, place+1,O_Y+19);
    CGContextStrokePath(context);
    
    
    CGContextSetRGBStrokeColor(context, 14/255.0f, 169/255.0f, 220/255.0f, 1);
    CGContextSetLineWidth(context, 5.0);
    CGContextMoveToPoint(context, place - 1, O_Y);
    CGContextAddLineToPoint(context, place +20,O_Y);
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 14/255.0f, 169/255.0f, 220/255.0f, 1);
    CGContextSetLineWidth(context, 5.0);
    CGContextMoveToPoint(context, place+nsize+1, O_Y);
    CGContextAddLineToPoint(context,place+nsize-20,O_Y);
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 14/255.0f, 169/255.0f, 220/255.0f, 1);
    CGContextSetLineWidth(context, 5.0);
    CGContextMoveToPoint(context, place+nsize-1, O_Y-2);
    CGContextAddLineToPoint(context, place+nsize-1,O_Y+19);
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 14/255.0f, 169/255.0f, 220/255.0f, 1);
    CGContextSetLineWidth(context, 5.0);
    CGContextMoveToPoint(context, place+nsize+1, O_Y+nsize-2);
    CGContextAddLineToPoint(context, place+nsize - 20,O_Y+nsize-2);
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 14/255.0f, 169/255.0f, 220/255.0f, 1);
    CGContextSetLineWidth(context, 5.0);
    CGContextMoveToPoint(context, place + nsize-1, O_Y+nsize);
    CGContextAddLineToPoint(context,place + nsize -1,O_Y+nsize - 21);
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 14/255.0f, 169/255.0f, 220/255.0f, 1);
    CGContextSetLineWidth(context, 5.0);
    CGContextMoveToPoint(context, place+1, O_Y+nsize);
    CGContextAddLineToPoint(context, place+1,O_Y+nsize-21);
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 14/255.0f, 169/255.0f, 220/255.0f, 1);
    CGContextSetLineWidth(context, 5.0);
    CGContextMoveToPoint(context, place-1, O_Y+nsize-2);
    CGContextAddLineToPoint(context, place+22,O_Y+nsize-2);
    CGContextStrokePath(context);
    
    CGContextEndTransparencyLayer(context);
    
}
-(void)animation
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(place + 10, O_Y+10+2*num, nsize - 20, 2);
        if (2*num == nsize - 20) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(place + 10,O_Y+10+2*num, nsize - 20, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}
-(void)startAnimation{
    _line.hidden = false;
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
   timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}
-(void)backAction
{
    [timer invalidate];
    timer = nil;
    _line.hidden = YES;
}
@end
