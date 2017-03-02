//
//  DefaultListNoThumbnailCell.m
//  msgcopy
//
//  Created by Gavin on 15/8/12.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "DefaultListNoThumbnailCell.h"
#import "UICustomLineLabel.h"

#define WHScale 70/93
#define WWScale 31/100
#define Margin 10

@implementation DefaultListNoThumbnailCell

- (void)awakeFromNib {
    // Initialization code
     [super awakeFromNib];
    NSString *fontName = FontName;
    CGFloat titleHeight = CRFontRowHeight(fontName, App3xfont(13), 1);
    
    _titleView.x =  10;
    _titleView.y = 10;
    _titleView.height = titleHeight+5;
    _titleView.font = MSGYHFont(13);
    
    CGFloat otherHeight = CRFontRowHeight(fontName, App3xfont(12), 2);
    
    _descrView.x = _titleView.x;
    _descrView.height = otherHeight+5;
    _descrView.y = _titleView.y + _titleView.height;
    _descrView.font = MSGYHFont(12);
    
    _positionView.height = otherHeight/2.0f+5;
    _positionView.titleLabel.font = MSGYHFont(11);
    
}

+(CGFloat)getCellHeight{
    
    CGFloat width = (AppWindow.width - 20)*WWScale;
    CGFloat height = width * WHScale;
    return height + 20;
    
}
-(void)buildWithData:(PubEntity*)pub
{
    _titleView.text = pub.article.title;
    _descrView.text = pub.article.descr;
    NSString *fontName = FontName;
    CGFloat descrHeight = CRFontRowHeight(fontName, App3xfont(12), 2);
    _titleView.x = 10;
    _titleView.width = AppWindow.width - Margin*2;
    _descrView.x = _titleView.x;
    _descrView.width = _titleView.width;
    CGFloat maxHeight = ceil(descrHeight)+5;
    NSDictionary *attr = @{NSFontAttributeName:MSGYHFont(12)};
    CGSize descrSize = [pub.article.descr boundingRectWithSize:CGSizeMake(_descrView.width,maxHeight) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
    _descrView.height = descrSize.height;
    if (!pub.article.location) {
        _positionView.hidden = true;
    }else{
        _positionView.hidden = false;
    }
    if ([CLLocationManager locationServicesEnabled]&&pub.article.location && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)){
        CLLocation *location = [LocationManager sharedManager].baiduLocation;
        CLLocationDistance distance = [location distanceFromLocation:pub.article.location];
        NSString *distanceStr = distance>1000? CRString(@"%.02f km",distance/1000.0f):CRString(@"%.02f m",distance);
        [_positionView setTitle:distanceStr forState:UIControlStateNormal];
    }
    [self updateComment:pub.article.comment_count like:pub.article.like];
}
-(void)updateComment:(NSInteger)cmcount like:(NSInteger)likeCount
{
    _like = likeCount;
    _comment = cmcount;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSString *likeStr = CRString(@"%d",_like);
    NSString *commentStr = CRString(@"%d",_comment);
    UIImage *like = [UIImage imageNamed:@"ic_nor_likecount"];
    UIImage *comment = [UIImage imageNamed:@"ic_nor_cm_count"];
    
    CGSize likeSize = [likeStr sizeWithAttributes:@{NSFontAttributeName:MSGYHFont(11)}];
    CGSize commentSize = [commentStr sizeWithAttributes:@{NSFontAttributeName:MSGYHFont(11)}];
    
    CGFloat like_x = AppWindow.width - 10 - likeSize.width - commentSize.width - 10 - 20;
    CGFloat comment_x = like_x + 10 + 10 + likeSize.width;
    
    [like drawInRect:CGRectMake(like_x, _positionView.center.y - 4.5, 10, 9)];
    [comment drawInRect:CGRectMake(comment_x, _positionView.center.y - 4.5, 10, 9)];
    
    [likeStr drawInRect:CGRectMake(like_x+14, _positionView.center.y - likeSize.height/2.0f, likeSize.width, likeSize.height) withAttributes:@{NSForegroundColorAttributeName:[UIColor colorFromHexRGB:@"bababa"],NSFontAttributeName:MSGYHFont(11)}];
    [commentStr drawInRect:CGRectMake(comment_x+14, _positionView.center.y - commentSize.height/2.0f, commentSize.width, commentSize.height) withAttributes:@{NSForegroundColorAttributeName:[UIColor colorFromHexRGB:@"bababa"],NSFontAttributeName:MSGYHFont(11)}];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
