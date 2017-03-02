//
//  LeftCell.m
//  msgcopy
//
//  Created by Gavin on 15/4/10.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "LeftCell.h"

@implementation LeftCell

- (void)awakeFromNib {
    // Initialization code
     [super awakeFromNib];
    self.backgroundColor = CRCOLOR_CLEAR;
    self.contentView.backgroundColor = CRCOLOR_CLEAR;
    
    //config Dotview
    _dotView.frame = CGRectMake(App3xScale(27), (MSGAppHeightScale(640, 88) - App3xScale(10))/2.0f,App3xScale(10),App3xScale(10));
    _dotView.image = nil;
    _dotView.backgroundColor = CRCOLOR_CLEAR;
    _dotView.clipsToBounds = true;
    _dotView.layer.cornerRadius = App3xScale(5);
    _dotView.hidden = true;
    _dotView.image = [UIImage imageNamed:@"Dot"];
    
    //config iconview
    _iconView.frame = CGRectMake(2*_dotView.x + _dotView.width, (MSGAppHeightScale(640, 88) - App3xScale(40))/2.0f, App3xScale(40), App3xScale(40));
    _iconView.backgroundColor = CRCOLOR_CLEAR;
    
    
    //config arrowView
    UIImage *arrowImage = [UIImage imageNamed:@"ic_arrow_right"];
    UIImage *whiteImage = [arrowImage imageWithTintColor:CRCOLOR_WHITE];
    [_arrowView setImage:whiteImage forState:UIControlStateNormal];
    _arrowView.userInteractionEnabled = false;
    
    //config titleView
    _titleView.x = _iconView.x + _iconView.width + App3xScale(27);
    _titleView.y = 0;
    _titleView.width = App3xScale(SliderWidth) - _titleView.x - _arrowView.width - 8;
    _titleView.height = MSGAppHeightScale(640, 88);
    _titleView.textColor = CRCOLOR_WHITE;
    _titleView.font = MSGYHFont(14);
    CGFloat abs = AppWindow.width *(1 - 0.6) / 2.0f;
    _titleView.width = SliderWidth + abs - _titleView.x - _arrowView.width - 10;
    _arrowView.center = CGPointMake(_titleView.x + _titleView.width + 8,MSGAppHeightScale(640, 88)/2.0f);

    //config selectionView
    UIImage *_strechImage = [[UIImage imageNamed:@"bg_nav_transparent"] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    UIImageView *_selectImageView = [[UIImageView alloc] initWithImage:_strechImage];
    _selectImageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.400];
    self.selectedBackgroundView = _selectImageView;

    
    
}
-(void)buidWithData:(id)data
{
    if ([data isMemberOfClass:[HomeConfigEntity class]]) {
        _titleView.text = @"首页";
        HomeConfigEntity *home  = (HomeConfigEntity*)data;
        NSString *normal = home.icon.normal_icon;
        NSString *selected = home.icon.normal_icon;
        if ([[PermissonManager sharedManager] isCustoumFuncBarValid]) {
            normal = home.icon.selected_icon;
            selected = home.icon.normal_icon;
        }
        if (home.icon) {
            
            [_iconView sd_setImageWithURL:[NSURL URLWithString:normal] ];
            [_iconView sd_setImageWithURL:[NSURL URLWithString:selected]];
            
        }else{
            [_iconView setImage:[UIImage imageNamed:@"ic_home_white"] ];
            [_iconView setImage:[UIImage imageNamed:@"ic_home_white"]];
        }
        if (home.title) {
            _titleView.text = home.title;
        }
        
    }else if ([data isMemberOfClass:[LimbEntity class]]) {
        
        LimbEntity *limb  = (LimbEntity*)data;
        _titleView.text             = limb.title;
        [_iconView sd_setImageWithURL:[NSURL URLWithString:limb.icon.normal_icon]  placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
            image = nil;
            [_iconView sd_setImageWithURL:[NSURL URLWithString:limb.icon.selected_icon] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
                image = nil;
            }];
        }];
        
    }else if([data isMemberOfClass:[WebAppEntity class]]){
        
        WebAppEntity *app = (WebAppEntity*)data;
        _titleView.text = app.title;
        NSString *normal = app.icon.normal_icon;
        NSString *selected = app.icon.normal_icon;
        if ([[PermissonManager sharedManager] isCustoumFuncBarValid]) {
            normal = app.icon.selected_icon;
            selected = app.icon.normal_icon;
        }
        [_iconView sd_setImageWithURL:[NSURL URLWithString:normal]  placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
            image = nil;
            [_iconView sd_setImageWithURL:[NSURL URLWithString:selected] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
                image = nil;
            }];
        }];
        
    }else if([data isMemberOfClass:[DiyPageEntity class]]){
        
        DiyPageEntity *page = (DiyPageEntity*)data;
        _titleView.text = page.text;
        NSString *normal = page.icon.normal_icon;
        NSString *selected = page.icon.normal_icon;
        [_iconView sd_setImageWithURL:[NSURL URLWithString:normal]  placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
            image = nil;
            [_iconView sd_setImageWithURL:[NSURL URLWithString:selected] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
                image = nil;
            }];
        }];
        
        
    }else if([data isMemberOfClass:[ArticleEntity class]]){
        ArticleEntity *msg = (ArticleEntity*)data;
        _titleView.text = msg.title;
        NSString *normal = msg.icon.normal_icon;
        NSString *selected = msg.icon.normal_icon;
        [_iconView sd_setImageWithURL:[NSURL URLWithString:normal]  placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
            image = nil;
            [_iconView sd_setImageWithURL:[NSURL URLWithString:selected] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
                image = nil;
            }];
        }];
        
    }else if([data isMemberOfClass:[PubEntity class]]){
        PubEntity *pub = (PubEntity*)data;
        _titleView.text =pub.title;
        NSString *normal = pub.icon.normal_icon;
        NSString *selected = pub.icon.normal_icon;
        [_iconView sd_setImageWithURL:[NSURL URLWithString:normal]  placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
            image = nil;
            [_iconView sd_setImageWithURL:[NSURL URLWithString:selected] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
                image = nil;
            }];
        }];
        
    }else if([data isMemberOfClass:[BaseTabItemEntity class]]){
        
        BaseTabItemEntity *tab = (BaseTabItemEntity*)data;
        _titleView.text =tab.title;
        NSString *normal = tab.icon.normal_icon;
        NSString *selected = tab.icon.normal_icon;
        [_iconView sd_setImageWithURL:[NSURL URLWithString:normal]  placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
            image = nil;
            [_iconView sd_setImageWithURL:[NSURL URLWithString:selected] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
                image = nil;
            }];
        }];        
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    _dotView.hidden = !selected;

    // Configure the view for the selected state
}

@end
