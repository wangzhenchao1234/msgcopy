//
//  MsgInfo.h
//  Kaoke
//
//  Created by xiaogu on 13-10-9.
//
//

#import <UIKit/UIKit.h>

@protocol MsgInfoDelegate <NSObject>

-(void)decreaseFont;
-(void)increaseFont;

@end


@interface MsgInfo : UIView
@property (weak, nonatomic) IBOutlet UIView  *mainView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *group;
@property (weak, nonatomic) IBOutlet UILabel *cTime;
@property (weak, nonatomic) IBOutlet UILabel *uTime;
@property (weak, nonatomic) IBOutlet UILabel *master;
@property (weak, nonatomic) IBOutlet UIButton *lightDecrease;
@property (weak, nonatomic) IBOutlet UIButton *lightIncrease;
@property (weak, nonatomic) IBOutlet UIButton *fontDecrease;
@property (weak, nonatomic) IBOutlet UIButton *fontIncrease;
@property (weak, nonatomic) IBOutlet UISlider *currentLightControl;
@property (weak, nonatomic) IBOutlet UILabel *separaterLine;
@property (weak, nonatomic) IBOutlet UILabel *separaterLinesecond;
@property (nonatomic,assign) id delegate;
@property NSString *fontSize;
- (IBAction)lightChanged:(id)sender;
- (IBAction)decreaseLight:(id)sender;
- (IBAction)increaseLight:(id)sender;
- (IBAction)decreseFont:(id)sender;
- (IBAction)increaseFont:(id)sender;
-(void)intilizedDataBy:(id)data;
-(void)show;
-(void)dismiss;
@end
