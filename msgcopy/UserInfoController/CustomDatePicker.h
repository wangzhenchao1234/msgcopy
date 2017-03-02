//
//  CustomDatePicker.h
//  Kaoke
//
//  Created by xiaogu on 14-2-12.
//
//

#import <UIKit/UIKit.h>

@protocol CustomDatePickerDelegate <NSObject>
-(void)changeDateSubmite:(NSDate*)date;
@end

@interface CustomDatePicker : UIView{
    UIView *main;
}
-(void)show;
+(CustomDatePicker*)sharedPicker;
@property (nonatomic,assign) id<CustomDatePickerDelegate> delegate;
@property (nonatomic,retain) UIDatePicker *datePicker;
@end
