//
//  KKPubRelCell.m
//  Kaoke
//
//  Created by xiaogu on 14-9-24.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "PubRelCell.h"


@implementation PubRelCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _imageView.backgroundColor = [UIColor colorWithRed:224/255.0f green:224/255.0f blue:224/255.0f alpha:1];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = true;
        [self addSubview:_imageView];
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, frame.size.width, 30)];
        
        _titleView.backgroundColor = [UIColor colorWithWhite:.0 alpha:.6];
        _titleView.textColor = [UIColor whiteColor];
        _titleView.font = MSGFont(16);
        _titleView.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleView];
        
        _videoFlag = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _videoFlag.image = [UIImage imageNamed:@"ic_play_video"];
        _videoFlag.center = _imageView.center;
        [self addSubview:_videoFlag];

    }
    return self;
}

-(void)buildWithPub:(PubEntity *)pub{
    
    if ([pub.article.ctype.systitle isEqualToString:@"shipin"]) {
        _videoFlag.hidden = false;
    }else{
        _videoFlag.hidden = true;
    }
    NSString *url = [self getImageUrlWithPub:pub];
    if (url) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url]];
    }
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;  //对齐
    style.headIndent = 5;          //行首缩进
    style.firstLineHeadIndent = 5;//首行缩进
    style.tailIndent = -5;//行尾缩进
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:pub.article.title attributes:@{ NSParagraphStyleAttributeName : style}];
    self.titleView.attributedText = attrText;
}

-(NSString *)getImageUrlWithPub:(PubEntity*)pub{
    
    ArticleEntity *msg = pub.article;
    if (msg.thumbnail) {
        return msg.thumbnail.turl;
    }else if(msg.images.count>0){
        KaokeImage *image = msg.images[0];
        return image.ourl;
    }else if(msg.imageSet.images.count>0){
        KaokeImage *image = msg.imageSet.images[0];
        return image.ourl;
    }
    return nil;
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
