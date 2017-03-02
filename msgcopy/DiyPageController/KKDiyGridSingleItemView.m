//
//  KKDiyGridSingleItemView.m
//  Kaoke
//
//  Created by wngzc on 14/11/27.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "KKDiyGridSingleItemView.h"

@interface KKDiyGridSingleItemView(){
    
    DiySingleGridEntity *curData;
    void(^doAction)(id data);

}

@end

@implementation KKDiyGridSingleItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _backgroundImageView = [[UIImageView alloc] initWithFrame:_contentView.frame];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        _backgroundImageView.clipsToBounds = true;
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _contentView.clipsToBounds = true;
        _iconView = [[UIImageView alloc] initWithFrame:frame];
        _iconView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 20, 30)];
        _titleLable.backgroundColor = [UIColor clearColor];
        _titleLable.textColor = [UIColor blackColor];
        _titleLable.font = MSGYHFont(16);
        
        [_contentView addSubview:_backgroundImageView];
        [_contentView addSubview:_iconView];
        [_contentView addSubview:_titleLable];
        [self addSubview:_contentView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick:)];
        [self addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPressReger = [[UILongPressGestureRecognizer alloc]
                                                        
                                                        initWithTarget:self action:@selector(handleLongPress:)];
       
        longPressReger.minimumPressDuration = 0.5;
        [_contentView addGestureRecognizer:longPressReger];
        
    }
    return self;
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([curData.bg_color isEqualToString:@"#000001"]) {
        
        CGPoint point = [gestureRecognizer locationInView:_contentView];
        
        [FingerWaveView showInView:self center:point];
    }

}
-(void)layoutSubviews{
    
    _backgroundImageView.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);
//    DiyIcon *icon = curData.icon;
    [_titleLable sizeToFit];
    
    CGPoint pt = CGPointMake(_contentView.frame.size.width/2.0, _contentView.frame.size.height/2.0);
    if ([curData.hor_tex_align isEqualToString:@"left"]) {
        pt.x = 0+_titleLable.frame.size.width/2.0f;
    }else if([curData.hor_tex_align isEqualToString:@"right"]){
        pt.x = _contentView.frame.size.width - _titleLable.frame.size.width/2.0f;
    }
    
    if ([curData.ver_tex_align isEqualToString:@"top"]) {
        pt.y = _titleLable.frame.size.height/2.0f;
    }else if([curData.ver_tex_align isEqualToString:@"bottom"]){
         pt.y = _contentView.frame.size.height - _titleLable.frame.size.height/2.0f;
    }
    _titleLable.center = pt;
    
    pt = _contentView.center;
    
    if ([curData.hor_ico_align isEqualToString:@"left"]) {
        pt.x = 0+_iconView.frame.size.width/2.0f;
    }else if([curData.hor_ico_align isEqualToString:@"right"]){
        pt.x = _contentView.frame.size.width - _iconView.frame.size.width/2.0f;
    }
    
    if ([curData.ver_ico_align isEqualToString:@"top"]) {
        pt.y = _iconView.frame.size.height/2.0f;
    }else if([curData.ver_ico_align isEqualToString:@"bottom"]){
        pt.y = _contentView.frame.size.height - _iconView.frame.size.height/2.0f;
    }
    _iconView.center = pt;
}
-(void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets{
    
    _contentView.frame = CGRectMake(contentEdgeInsets.left, contentEdgeInsets.top, _contentView.frame.size.width - contentEdgeInsets.left - contentEdgeInsets.right,_contentView.frame.size.height - contentEdgeInsets.bottom - contentEdgeInsets.top);
    [self setNeedsDisplay];
    
}

-(void)buildByData:(DiySingleGridEntity*)data page:(DiyPageEntity*)page action:(onClick)action{
    
    curData = data;
    doAction = action;
    _titleLable.text = data.text;
    _titleLable.font = MSGYHFont(data.font_size);
    if (data.font_color.length ==7) {
       _titleLable.textColor = [UIColor colorFromHexRGB:[data.font_color substringFromIndex:1]];
    }
    if (data.bg_color.length ==7) {
        if ([data.bg_color isEqualToString:@"#000001"]||data.bg_img) {
           
            _contentView.backgroundColor = [UIColor clearColor];
            _backgroundImageView.backgroundColor = [UIColor clearColor];
            
        }else{
        
         _contentView.backgroundColor = [UIColor colorFromHexRGB:[data.bg_color substringFromIndex:1]];
        }
       
    }
    [_iconView sd_setImageWithURL:[NSURL URLWithString:data.icon.url]];
    _iconView.frame = CGRectMake(0, 0, [data.icon.width floatValue]*SQR(page.column) ,[data.icon.height floatValue]*SQR(page.column));
    
    [_backgroundImageView sd_setImageWithURL:[NSURL URLWithString:curData.bg_img]];
    UIEdgeInsets inset = UIEdgeInsetsMake(
                                          [[data.padding valueForKey:@"top"] floatValue]*SQR(page.column),
                                          [[data.padding valueForKey:@"left"] floatValue]*SQR(page.column),
                                          [[data.padding valueForKey:@"bottom"] floatValue]*SQR(page.column),
                                          [[data.padding valueForKey:@"right"] floatValue]*SQR(page.column)
                                          );
    [self setContentEdgeInsets:inset];
    
}
-(void)itemClick:(UITapGestureRecognizer *)tap{
   
    if ([curData.bg_color isEqualToString:@"#000001"]) {
        CGPoint point = [tap locationInView:_contentView];
        
        [FingerWaveView showInView:self center:point];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            doAction(curData.action);

        });
    }else{
        doAction(curData.action);

    
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
