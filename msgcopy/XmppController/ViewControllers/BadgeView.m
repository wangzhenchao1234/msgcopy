//
//  BadgeView.m
//  msgcopy
//
//  Created by wngzc on 15/5/28.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "BadgeView.h"
#define BadgeFont 10

@implementation BadgeView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = CRCOLOR_CLEAR;
    self.font = MSGFont(BadgeFont);
}
-(void)setText:(NSString *)text
{
    [super setText:text];
    self.hidden = !([text integerValue]>0);
    CGSize badgeSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: MSGFont(BadgeFont)}
                                         context:nil].size;
    CGRect frame = self.frame;
    if (badgeSize.width < badgeSize.height) {
        frame.size.width = MAX(self.width,self.height);
    }else{
        frame.size.width = badgeSize.width + 50;
    }
    self.frame = frame;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSString *badgeValue = self.text;
    _badgePositionAdjustment = UIOffsetMake(1, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    if ([badgeValue length]) {
        CGSize badgeSize = CGSizeZero;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            
            badgeSize = [badgeValue boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName: MSGFont(BadgeFont)}
                                                      context:nil].size;
            
        } else {
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            badgeSize = [badgeValue sizeWithFont:MSGFont(BadgeFont)
                                constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
#endif
            
        }
        
        CGFloat textOffset = 1.0f;
        CGRect badgeFrame =CGRectZero;
        
        CGRect badgeBackgroundFrame = CGRectZero;
        if (badgeSize.width < badgeSize.height) {
            badgeSize = CGSizeMake(badgeSize.height, badgeSize.height);
            badgeFrame = CGRectMake(2, 2, badgeSize.width, badgeSize.height);
            badgeBackgroundFrame =  CGRectMake(1,1,badgeSize.width + 4 - 2 * textOffset, badgeSize.height + 4 - 2 * textOffset);
        }else{
            badgeFrame = CGRectMake(4, 2, badgeSize.width, badgeSize.height);
            badgeSize = CGSizeMake(badgeSize.width, badgeSize.height);
            badgeBackgroundFrame =  CGRectMake(1,1,badgeSize.width + 8 - 2 * textOffset, badgeSize.height + 4 - 2 * textOffset);
        }

        CGContextSetFillColorWithColor(context, [CRCOLOR_RED CGColor]);
            
        if (badgeSize.width <= badgeSize.height) {
            
            CGContextFillEllipseInRect(context, badgeBackgroundFrame);
            
        }else{
            
            CGFloat radius = badgeBackgroundFrame.size.height/2.0f;
            CGFloat lefttop = badgeBackgroundFrame.origin.x + radius;
            CGFloat righttop = lefttop + badgeBackgroundFrame.size.width - badgeBackgroundFrame.size.height;
            
            CGContextMoveToPoint(context, lefttop, badgeBackgroundFrame.origin.y);
            
            CGContextAddLineToPoint(context, righttop, badgeBackgroundFrame.origin.y);
            
            CGContextAddArc(context, righttop, badgeBackgroundFrame.origin.y + radius , radius, -M_PI_2, M_PI_2, 0);
            CGContextAddLineToPoint(context,lefttop, badgeBackgroundFrame.origin.y + 2*radius);
            CGContextAddArc(context, lefttop, badgeBackgroundFrame.origin.y + radius ,radius, M_PI_2, -M_PI_2, 0);
            CGContextClosePath(context);
            CGContextSetRGBFillColor(context,1,0,0,1);
            CGContextDrawPath(context, kCGPathFill);
            
        }
        
        CGContextSetFillColorWithColor(context, [CRCOLOR_WHITE CGColor]);
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            
            NSMutableParagraphStyle *badgeTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            [badgeTextStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [badgeTextStyle setAlignment:NSTextAlignmentCenter];
            
            NSDictionary *badgeTextAttributes = @{
                                                  NSFontAttributeName: MSGFont(BadgeFont),
                                                  NSForegroundColorAttributeName:CRCOLOR_WHITE,
                                                  NSParagraphStyleAttributeName: badgeTextStyle,
                                                  };
            
            [badgeValue drawInRect:badgeFrame
                           withAttributes:badgeTextAttributes];
            
        } else {
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            [badgeValue drawInRect:badgeFrame
                                 withFont:MSGFont(BadgeFont)
                            lineBreakMode:NSLineBreakByTruncatingTail
                                alignment:NSTextAlignmentCenter];
#endif
            
        }
    }
    CGContextRestoreGState(context);
    
}

@end
