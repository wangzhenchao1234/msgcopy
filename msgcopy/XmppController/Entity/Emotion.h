//
//  Emotion.h
//  Kaoke
//
//  Created by xiaogu on 13-10-11.
//
//

#import <UIKit/UIKit.h>

@interface Emotion : UIView
@property (weak)id delegate;
@property (nonatomic,copy)NSString* emotionStr;
@property (weak, nonatomic) IBOutlet UIButton *emotinButton;
-(void)setWithData:(NSDictionary*)data;
- (IBAction)click:(id)sender;

@end
