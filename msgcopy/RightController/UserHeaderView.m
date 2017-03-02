//
//  UserHeaderView.m
//  msgcopy
//
//  Created by Gavin on 15/5/20.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "UserHeaderView.h"

@interface UserHeaderView()
@property(nonatomic,retain)UIButton *actionView;

@end

@implementation UserHeaderView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _actionView = [[UIButton alloc] initWithFrame:CGRectMake(1+ App3xScale(4)*2, 1+ App3xScale(4)*2, frame.size.width - (1+ App3xScale(4)*2)*2, frame.size.height - (1+ App3xScale(4)*2)*2)];
        _actionView.layer.cornerRadius = _actionView.height/2.0f;
        _actionView.clipsToBounds = true;
        [[_actionView imageView] setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:_actionView];
        self.backgroundColor = CRCOLOR_CLEAR;
    }
    return self;
}

-(void)setImage:(UIImage *)image forState:(UIControlState)state{
    [_actionView setBackgroundImage:image forState:state];
}
-(void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder
{
    [_actionView setBackgroundImageWithURL:url forState:state placeholderImage:placeholder];
}
-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event
{
    [_actionView addTarget:target action:action forControlEvents:event];
}
-(void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(contextRef,1.0f , 1.0f,1.0f, 1);
    CGContextSetRGBStrokeColor(contextRef,1.0f ,1.0f,1.0f, 1);
    CGContextAddArc(contextRef, rect.size.width/2.0f, rect.size.height/2.0f, rect.size.width/2.0f-1, 0, M_PI*2,1 );
    CGContextDrawPath(contextRef,kCGPathFillStroke);

    CGContextSetRGBFillColor(contextRef,220/255.0f , 220/255.0f, 221/255.0f, 1);
    CGContextSetRGBStrokeColor(contextRef,220/255.0f , 220/255.0f, 221/255.0f, 1);
    CGContextAddArc(contextRef, rect.size.width/2.0f, rect.size.height/2.0f, rect.size.width/2.0f - 1 -App3xScale(4), 0, M_PI*2,1 );
    CGContextDrawPath(contextRef,kCGPathFillStroke);
}
@end
