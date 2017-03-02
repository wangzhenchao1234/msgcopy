//
//  MsgInfo.m
//  Kaoke
//
//  Created by xiaogu on 13-10-9.
//
//

#import "MsgInfo.h"
#import <QuartzCore/QuartzCore.h>
@implementation MsgInfo

-(void)awakeFromNib
{
    self.mainView.layer.borderColor     = [[UIColor lightGrayColor] CGColor];
    self.mainView.layer.borderWidth     = 1/[UIScreen mainScreen].scale;
    self.mainView.backgroundColor       = [UIColor colorWithWhite:0.98 alpha:0.95];
}
- (id)initWithFrame:(CGRect)frame
{
    self  = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)intilizedDataBy:(id)data{
    
    self.frame = [UIScreen mainScreen].bounds;
    NSDateFormatter *dateFormater       = [[NSDateFormatter alloc] init];
    [dateFormater setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"]];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if([data isMemberOfClass:[ArticleEntity class]])
    {
        ArticleEntity* msg                 = data;
        self.title.text                     = msg.title;
        self.group.text                     = msg.parent.title;
        //        NSLog(@"%@",msg.parent.title);
        self.cTime.text                     = [dateFormater stringFromDate:msg.cTime];
        self.uTime.text                     = [dateFormater stringFromDate:msg.uTime];
    }
    else if([data isMemberOfClass:[ShareEntity class]])
    {
        ShareEntity* share             = data;
        self.title.text                     = share.title;
        self.master.text                    = share.article.master.userName;
        self.cTime.text                     = [dateFormater stringFromDate:share.article.cTime];
        //        NSLog(@"%@",share.cTime);
        self.uTime.text                     = [dateFormater stringFromDate:share.article.uTime];
        ;
    }
    if([data isMemberOfClass:[PubEntity class]])
    {
        PubEntity* publication = data;
        self.title.text                     = publication.article.title;
        self.cTime.text                     = [dateFormater stringFromDate:publication.article.cTime];
        self.uTime.text                     = [dateFormater stringFromDate:publication.article.uTime];
    }
}
-(void)show{
 
    self.currentLightControl.value = [UIScreen mainScreen].brightness;
    CGRect frame = self.separaterLine.frame;
    frame.size.height = 1.0f/[UIScreen mainScreen].scale;
    self.separaterLine.frame = frame;
    frame = _separaterLinesecond.frame;
    frame.size.height = 1.0f/[UIScreen mainScreen].scale;
    self.separaterLinesecond.frame = frame;
    UIWindow *keywindow                 = [[UIApplication sharedApplication] keyWindow];
    self.mainView.frame                 = CGRectMake(0, keywindow.bounds.size.height-self.mainView.frame.size.height-50, keywindow.bounds.size.width, self.mainView.frame.size.height);
    [keywindow addSubview:self];
    [self animatedIn];
}
- (void)animatedIn
{
    self.mainView.transform             = CGAffineTransformMakeScale(0.3,0.3);
    self.mainView.alpha                 = 0;
    [UIView animateWithDuration:.35 animations:^{
    self.mainView.alpha                 = 1;
    self.mainView.transform             = CGAffineTransformMakeScale(1, 1);
    }];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self dismiss];
}
-(void)dismiss{
    [self animatedOut];
}
- (void)animatedOut
{
    [UIView animateWithDuration:.35 animations:^{
    self.mainView.transform = CGAffineTransformMakeScale(0.3, 0.3);
    self.mainView.alpha     = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}
- (IBAction)lightChanged:(id)sender {
    UISlider *slider = (UISlider*)sender;
//    NSLog(@"%f",slider.value);
    [[UIScreen mainScreen] setBrightness:slider.value];
}
- (IBAction)decreaseLight:(id)sender {
    self.currentLightControl.value -= 0.01;
    self.fontSize = [NSString stringWithFormat:@"%d",(NSInteger)(self.currentLightControl.value*100)];
    [[UIScreen mainScreen] setBrightness:self.currentLightControl.value];
    
}

- (IBAction)increaseLight:(id)sender {
    self.currentLightControl.value += 0.01;
    [[UIScreen mainScreen] setBrightness:self.currentLightControl.value];
}
- (IBAction)decreseFont:(id)sender {
    if ([self.delegate respondsToSelector:@selector(decreaseFont)]) {
        [self.delegate performSelector:@selector(decreaseFont)];
    }
}

- (IBAction)increaseFont:(id)sender {
    if ([self.delegate respondsToSelector:@selector(increaseFont)]) {
        [self.delegate performSelector:@selector(increaseFont)];
    }
}
-(void)dealloc{
    _title      = nil;
    _mainView   = nil;
    _master     = nil;
    _uTime      = nil;
    _cTime      = nil;
    _group      = nil;
    _lightDecrease = nil;
    _lightIncrease = nil;
    _fontDecrease = nil;
    _fontIncrease = nil;
    _currentLightControl = nil;
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
