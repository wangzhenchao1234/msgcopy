//
//  DeskTopItem.m
//  Kaoke
//
//  Created by xiaogu on 13-12-31.
//
//

#import "DeskTopItem.h"
#import "DeskTopItemModaul.h"


@implementation DeskTopItem
@synthesize title          = _title;
@synthesize image          = _image;
@synthesize cover          = _cover;
@synthesize backgroundView = _backgroundView;
@synthesize animation      = _animation;
@synthesize subTitle       = _subTitle;
@synthesize data           = _data;
@synthesize clickView      = _clickView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(id)initWithData:(DeskTopItemModaul*)data{
    self = [super init];
    if (self) {
       
        NSArray *colorArray = @[@[@"232",@"35",@"41"],@[@"238",@"153",@"33"],@[@"116",@"193",@"142"],@[@"60",@"195",@"237"],@[@"255",@"202",@"8"],@[@"29",@"121",@"186"],@[@"196",@"60",@"149"],@[@"39",@"132",@"66"]];
        NSInteger index = arc4random()%8;
        NSArray *color  = colorArray[index];
        cache     = [SDImageCache sharedImageCache];
        _title    = [[UILabel alloc] init];
        _subTitle = [[UILabel alloc] init];
        _image    = [[UIImageView alloc] init];
      
        _image.backgroundColor = [UIColor colorWithRed:[color[0] floatValue]/255 green:[color[1] floatValue]/255 blue:[color[2] floatValue]/255 alpha:1];
        //_cover = [[UIImageView alloc] init];
        _backgroundView = [[UIView alloc] init];
        _clickView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_image];
        [self addSubview:_cover];
        [self addSubview:_clickView];
        CGRect frame;
        CGRect screen = [UIScreen mainScreen].bounds;
        CGRect titleFrame;
        CGRect coverFrame;
        CGRect bgFrame;
        _title.font = MSGFont(16);
        switch (data.size) {
            case 0:{
                frame      = CGRectMake(0, 0,screen.size.width, screen.size.width*3/4);
                titleFrame = CGRectMake(5, frame.size.height - 55,frame.size.width - 10, 25);
                bgFrame    = CGRectMake(0, frame.size.height - 30 , frame.size.width-30 ,30 );
                coverFrame = CGRectMake(0, frame.size.height-frame.size.height/3,frame.size.width , frame.size.height/3);
                if (data.imageUrls.count <= 1&&data.subTitles == nil) {
                    titleFrame.origin.y = frame.size.height - 25;
                }else{
                    [self addSubview:_backgroundView];
                }
//                _title.font = [UIFont systemFontOfSize:24];
            }
                
                break;
            case 1:{
                frame      = CGRectMake(0, 0,screen.size.width, screen.size.width/3);
                titleFrame = CGRectMake(5, frame.size.height - 55,frame.size.width - 10, 25);
                bgFrame    = CGRectMake(0, frame.size.height - 30 , frame.size.width-30 ,30 );
                coverFrame = CGRectMake(0, frame.size.height-frame.size.height/3,frame.size.width , frame.size.height/3);
                if (data.imageUrls.count <= 1&&data.subTitles == nil) {
                    titleFrame.origin.y = frame.size.height - 25;
                }else{
                    [self addSubview:_backgroundView];
                }
            }
                break;
            case 2:{
                frame      = CGRectMake(0, 0,screen.size.width/3*2, screen.size.width/3);
                titleFrame = CGRectMake(5, frame.size.height - 25,frame.size.width - 10, 25);
                bgFrame    = CGRectMake(0, frame.size.height - 30 , frame.size.width-30 ,30 );
                coverFrame = CGRectMake(0, frame.size.height-frame.size.height/3,frame.size.width , frame.size.height/3);
            }
                break;
            case 3:{
                frame      = CGRectMake(0, 0,screen.size.width/3, screen.size.width/3);
                titleFrame = CGRectMake(5, frame.size.height - 25,frame.size.width - 10, 25);
                bgFrame    = CGRectMake(0, frame.size.height - 30 , frame.size.width-30 ,30 );
                coverFrame = CGRectMake(0, frame.size.height-frame.size.height/3,frame.size.width , frame.size.height/3);
            }
                break;
            case 4:{
                frame      = CGRectMake(0, 0,screen.size.width/3*2, screen.size.width/3*2);
                titleFrame = CGRectMake(5, frame.size.height - 55,frame.size.width - 10, 25);
                bgFrame    = CGRectMake(0, frame.size.height - 30 , frame.size.width -30,30 );
                coverFrame = CGRectMake(0, frame.size.height-frame.size.height/3,frame.size.width , frame.size.height/3);
                if (data.imageUrls.count <= 1&&data.subTitles == nil) {
                    titleFrame.origin.y = frame.size.height - 25;
                }else{
                    [self addSubview:_backgroundView];
                }
            }
                break;
        }
        self.frame                = frame;
        _subTitle.frame           = CGRectMake(bgFrame.origin.x+5, bgFrame.origin.y, bgFrame.size.width-10, bgFrame.size.height);
        _subTitle.backgroundColor = [UIColor clearColor];
        _subTitle.textColor       = [UIColor whiteColor];
        _subTitle.font            = MSGYHFont(14);
        if (data.imageUrls.count>0) {
            NSString *sTitle = data.subTitles[0];
            _subTitle.text   = [sTitle decodeHTMLCharacterEntities];
        }
        _title.frame                    = titleFrame;
        _backgroundView.frame           = bgFrame;
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha           = 0.6;
        _cover.frame                    = coverFrame;
        _image.frame                    = frame;
        UIImageView *shadowView         = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height*2/3, self.frame.size.width, self.frame.size.height/3)];
        shadowView.image                = [UIImage imageNamed:@"home_shadow"];
        [self addSubview:shadowView];
        _title.backgroundColor          = [UIColor clearColor];
        _title.textColor                = [UIColor whiteColor];
        _title.shadowColor              = [UIColor blackColor];
        _title.shadowOffset             = CGSizeMake(1, 1);
        _title.text                     = [data.title decodeHTMLCharacterEntities];
        _image.contentMode              = UIViewContentModeScaleAspectFill;
        _image.clipsToBounds            = YES;
        _clickView.frame                = frame;
        self.data                       = data;
        [self addSubview:_title];
        
        self.layer.borderColor = [[UIColor colorWithWhite:0.95 alpha:0.9] CGColor];
        self.layer.borderWidth = 2.5;
        if (data.imageUrls.count == 0) {
            _subTitle.text = @"无投稿";
        }else{

            NSString *sTitle = data.subTitles==nil?nil:data.subTitles[0];
            _subTitle.text   = sTitle == nil?nil:[sTitle decodeHTMLCharacterEntities];
        }
        if (data.imageUrls.count>0&&[data.imageUrls[0] length]>0) {
          [self.image sd_setImageWithURL:[NSURL URLWithString:data.imageUrls[0]] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
          } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
              image = nil;
          }];
        }
    }
    if ((data.size == 0||data.size == 1||data.size == 4)&&(data.imageUrls.count > 1)) {
        [self addSubview:_subTitle];
        [NSTimer scheduledTimerWithTimeInterval:6+data.size target:self selector:@selector(startAnimation) userInfo:nil repeats:YES];
    }
    return self;
}
-(void)startAnimation{
    
    [self.image.layer removeAllAnimations];
    _animation                = [CATransition animation];
    CATransition *transition  = [CATransition animation];
    transition.duration       = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type           = kCATransitionMoveIn;
    transition.subtype        = kCATransitionFromRight;
    transition.delegate       = self.image;
    [self.image.layer addAnimation:transition forKey:@"reView"];
    NSInteger index           = curIndex;
    if (index == [_data.imageUrls count]-1) {
        [self changeTo:0];
        curIndex = 0;
    }else{
        [self changeTo:curIndex+1];
        curIndex = curIndex+1;
    }
}
-(void)changeTo:(NSInteger)index{
    
    if ([_data.imageUrls[index] length]>0){
        [self.image sd_setImageWithURL:[NSURL URLWithString:self.data.imageUrls[index]] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType,NSURL*url) {
            image = nil;
        }];
    }
    NSString *sTitle = _data.subTitles[index];
    _subTitle.text = [sTitle decodeHTMLCharacterEntities];
    
}
-(void)dealloc{
    _title          = Nil;
    _subTitle       = Nil;
    _image          = Nil;
    _cover          = Nil;
    _backgroundView = Nil;
    _animation      = Nil;
    _data           = Nil;
    _clickView      = Nil;
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
