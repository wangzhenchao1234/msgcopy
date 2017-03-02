//
//  Emotion.m
//  Kaoke
//
//  Created by xiaogu on 13-10-11.
//
//

#import "Emotion.h"

@implementation Emotion
@synthesize emotionStr;
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)setWithData:(NSDictionary*)data{
    [self.emotinButton setImage:[UIImage imageNamed:[data valueForKey:@"e_name"]]forState:UIControlStateNormal];
    self.emotinButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.emotionStr = [data valueForKey:@"e_descr"];
}

- (IBAction)click:(id)sender {
    if ([self.delegate respondsToSelector:@selector(click:)]) {
        [self.delegate performSelector:@selector(click:) withObject:self.emotionStr];
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
