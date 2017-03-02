//
//  FacialView.m
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacialView.h"
#import "EmotionManager.h"
#import "Emotion.h" 
#define ROWS 3
#define CLUMS 6
#define PAGE_COUNT 16
#define KEYBOARD_HIGHT 216

@implementation FacialView
@synthesize delegate;
@synthesize faces;
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.faces=[EmotionManager emotions];
        self.clipsToBounds = true;
    }
    return self;
}

-(void)loadFacialView:(int)page size:(CGSize)size
{
	//row number
    CGRect rect = [UIScreen mainScreen].bounds;
    CGFloat rowsBlank = (KEYBOARD_HIGHT - 50 - (45*ROWS))/(ROWS+1);
    CGFloat clumsBlank = (rect.size.width - (45*CLUMS))/(CLUMS+1);
	for (int i = 0; i < ROWS; i++) {
		//column numer
		for (int y = 0; y< CLUMS ; y ++) {
            
            if (i == ROWS-1 && (y == CLUMS-1 || y == CLUMS - 2)) {
                if (y == CLUMS-1) {
                    
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(clumsBlank*(y+1)+y*size.width, rowsBlank*(i+1)+i*size.height, size.width, size.height);
                    [button setImage:[UIImage imageNamed:@"face_send"] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:button];
                    
                    
                }else{
                    
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(clumsBlank*(y+1)+y*size.width, rowsBlank*(i+1)+i*size.height, size.width, size.height);
                    [button setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
                    [self addSubview:button];
                    
                    
                }
                
            }else{
                
                if (i*CLUMS+y+(page*PAGE_COUNT)<[faces count]) {
                    
                    NSDictionary *dict = faces[i*CLUMS+y+(page*PAGE_COUNT)];
                    Emotion *button = [[[NSBundle mainBundle] loadNibNamed:@"Emotion" owner:self options:nil] lastObject];
                    button.frame = CGRectMake(clumsBlank*(y+1)+y*size.width, rowsBlank*(i+1)+i*size.height, size.width, size.height);
                    button.delegate = self;
                    [button setWithData:dict];
                    [self addSubview:button];
                    
                }
            }
		}
	}
}

-(void)delete{
    
    [delegate selectedFacialView:@"删除"];

}
-(void)send{

    [delegate sendMessage];
    
}
-(void)click:(NSString*)emotion
{
    [delegate selectedFacialView:emotion];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
- (void)dealloc {
}
@end
