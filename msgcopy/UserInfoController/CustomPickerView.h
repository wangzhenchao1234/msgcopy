//
//  CustomPickerView.h
//  Kaoke
//
//  Created by xiaogu on 14-2-12.
//
//

#import <UIKit/UIKit.h>

@protocol CustomPickerViewDelegate <NSObject>
-(void)changePickerSubmite:(NSArray*)datas;
@end

@interface CustomPickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>{
    UIView *main;
    NSArray *currentData;
    NSInteger currentProv;
    NSInteger currentCity;
}
-(void)show;
+(CustomPickerView*)sharedPicker;
@property (nonatomic,assign) id<CustomPickerViewDelegate> delegate;
@property (nonatomic,retain) UIPickerView             *datePicker;
@property (nonatomic,retain) NSArray                  *datas;
@end
