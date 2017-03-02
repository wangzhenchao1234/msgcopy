//
//  GroupPickerView.h
//  msgcopy
//
//  Created by wngzc on 15/7/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GVPickerView;

@protocol GVPickerViewDelegate <NSObject>

@required
-(NSInteger)numberOfComponentsInPickerView:(GVPickerView *)pickerView;
-(NSInteger)pickerView:(GVPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
@optional
-(NSString*)pickerView:(GVPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
-(void)changePickerSubmite:(NSIndexPath*)indexPath;

@end

@interface GVPickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIView *main;
    NSIndexPath *curIndexPath;
}
-(void)show;
+(GVPickerView*)sharedPicker;
@property (nonatomic,weak) id<GVPickerViewDelegate> delegate;
@property (nonatomic,retain) UIPickerView *picker;

@end
