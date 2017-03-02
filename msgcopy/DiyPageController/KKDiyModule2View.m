//
//  KKDiyListView.m
//  Kaoke
//
//  Created by wngzc on 14/12/1.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "KKDiyModule2View.h"
#import "UICustomLineLabel.h"

@interface KKDiyModule2View()
{
    DiyModule2Entity *curData;
    void(^doAction)(id data);

}

@end

@implementation KKDiyModule2View

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _thumbnail = [[UIImageView alloc] init];
//        _thumbnail.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnail.clipsToBounds = true;
        _thumbnail.backgroundColor = [UIColor randomColor];
        _titleLable = [[UILabel alloc] init];
        _descr = [[UILabel alloc] init];
        _contentView = [[UIView alloc] init];
        _titleLable.font = MSGYHFont(16);
        _descr.font = MSGYHFont(12);
        _descr.numberOfLines = 0;
        _descr.textColor = [UIColor grayColor];
        _bottomLine = [[UILabel alloc] init];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
        _price = [[UILabel alloc] init];
        _price.font = MSGYHFont(13);
        _lastPrice = [[UICustomLineLabel alloc] init];
        _lastPrice.textColor = [UIColor grayColor];
        _lastPrice.font = MSGYHFont(12);
        _lastPrice.lineType = LineTypeMiddle;
        
        [self addSubview:_contentView];
        [self addSubview:_thumbnail];
        [self addSubview:_descr];
        [self addSubview:_titleLable];
        [self addSubview:_price];
        [self addSubview:_lastPrice];
        [self addSubview:_bottomLine];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClick:)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

-(void)layoutSubviews{
    
    CGPoint ct = CGPointZero;
    CGRect thumnailFrame = CGRectMake(0, 10,0 ,0);
    if (!_thumbnail.hidden) {
        _thumbnail.frame = CGRectMake(10, 15, _contentView.frame.size.height*5/4.0f, _contentView.frame.size.height - 15);
        ct = _thumbnail.center;
        ct.y = _contentView.frame.size.height/2.0f;
        _thumbnail.center = ct;
        thumnailFrame = _thumbnail.frame;
    }
    _titleLable.frame = CGRectMake(thumnailFrame.size.width + thumnailFrame.origin.x + 10, 10, _contentView.frame.size.width - thumnailFrame.size.width - thumnailFrame.origin.x - 10, 16);
    NSDictionary *attr = @{NSFontAttributeName:MSGYHFont(13)};
    
    CGSize size = [_descr.text boundingRectWithSize:CGSizeMake(_titleLable.frame.size.width, _contentView.frame.size.height - 24 - 10) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    _descr.frame= CGRectMake(_titleLable.frame.origin.x,_titleLable.frame.origin.y + _titleLable.frame.size.height + 5 ,_titleLable.frame.size.width,size.height);
    
    _lastPrice.frame = CGRectMake(_titleLable.frame.origin.x,_contentView.frame.size.height - 8 - 13,_descr.frame.size.width, 12);
    
    CGFloat y = _lastPrice.frame.origin.y;
    if (!_lastPrice.hidden) {
        y = self.frame.size.height - 13 - 14 - 12;
    }
    _price.frame = CGRectMake(self.titleLable.frame.origin.x,y, _descr.frame.size.width,13);
    _price.font = MSGYHFont(13);
    _price.textColor = [UIColor redColor];
    [_lastPrice setNeedsDisplay];
    
    CGRect frame = _bottomLine.frame;
    frame.origin.y = self.frame.size.height - 1/[UIScreen mainScreen].scale;
    frame.origin.x = _thumbnail.frame.origin.x;
    frame.size.height = 1/[UIScreen mainScreen].scale;
    frame.size.width = self.frame.size.width - _thumbnail.frame.origin.x * 2;
    _bottomLine.frame = frame;
}

-(void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets{
    
    _contentView.frame = CGRectMake(contentEdgeInsets.left, contentEdgeInsets.top, self.frame.size.width - contentEdgeInsets.left - contentEdgeInsets.right, self.frame.size.height - contentEdgeInsets.top - contentEdgeInsets.bottom);
    [self setNeedsDisplay];
    
}

-(void)buildByData:(DiyModule2Entity*)data page:(DiyPageEntity*)page action:(onClick)action {
    
    curData = data;
    doAction = action;
    NSDictionary *attr = @{NSFontAttributeName:MSGYHFont(13)};
    _thumbnail.hidden = true;
    if (data.thumbnail&&data.thumbnail.length > 0) {
        _thumbnail.hidden = false;
        [_thumbnail sd_setImageWithURL:[NSURL URLWithString:data.thumbnail]];

    }
    _titleLable.text = data.text;
    _descr.attributedText = [[NSAttributedString alloc] initWithString:data.descr?data.descr:@"" attributes:attr];
    _price.text = [NSString stringWithFormat:@"%@元",data.price];
    _lastPrice.text = [NSString stringWithFormat:@"原价:%@元",data.descr];
    _lastPrice.lineColor = [UIColor lightGrayColor];
    _lastPrice.textColor = [UIColor lightGrayColor];
    _descr.numberOfLines = 2;

    if ([data.kind isEqualToString:@"ds"]) {
        _price.hidden = true;
        if (data.price&&data.price.length>0) {
            _price.hidden = false;
        }
        _lastPrice.hidden = true;
        if (data.descr&&data.descr.length>0) {
            _lastPrice.hidden = false;
        }
        _descr.hidden = true;
    }else{
        _price.hidden = true;
        _lastPrice.hidden = true;
        _descr.hidden = false;
    }
    self.lastPrice.font = MSGYHFont(12);
    self.lastPrice.textColor = [UIColor colorWithWhite:0.769 alpha:1.000];
    UIEdgeInsets inset = UIEdgeInsetsMake(0*SQR(page.column), 0*SQR(page.column), 0*SQR(page.column), 0*SQR(page.column));
    [self setContentEdgeInsets:inset];
    
}

-(void)buildByPub:(PubEntity *)data action:(onClick)action type:(NSString*)type{
    
    _pub = data;
    doAction = action;
    _titleLable.text = _pub.article.title;
    _descr.text = _pub.article.descr;
    _price.text = [NSString stringWithFormat:@"%@元",_pub.article.descr];
    _lastPrice.text = [NSString stringWithFormat:@"原价:%@元",_pub.article.source];
    _lastPrice.lineColor = [UIColor lightGrayColor];
    _thumbnail.hidden = true;
    if (_pub.article.thumbnail.turl&&_pub.article.thumbnail.turl.length > 0) {
        _thumbnail.hidden = false;
        [_thumbnail sd_setImageWithURL:[NSURL URLWithString:_pub.article.thumbnail.turl]];
    }
    if ([type isEqualToString:@"dianshang1"]||[type isEqualToString:@"dianshang2"]) {
        _price.hidden = true;
        if (_pub.article.descr&&_pub.article.descr.length>0) {
            _price.hidden = false;
        }
        _lastPrice.hidden = true;
        if (_pub.article.source&&_pub.article.source.length>0) {
            _lastPrice.hidden = false;
        }
        _descr.hidden = true;

    }else{
        _price.hidden = true;
        _lastPrice.hidden = true;
        _descr.hidden = false;
    }
    self.lastPrice.font = MSGYHFont(12);
    self.lastPrice.textColor = [UIColor lightGrayColor];
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setContentEdgeInsets:inset];
    
}
-(void)itemClick:(UITapGestureRecognizer*)tap{
    if (_pub) {
        [MSGTansitionManager openPubWithID:_pub.pid withParams:nil];
        return;
    }
    doAction(curData.action);
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
