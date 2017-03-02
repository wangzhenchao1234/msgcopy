//
//  CustomPickerView.m
//  Kaoke
//
//  Created by xiaogu on 14-2-12.
//
//

#import "CustomPickerView.h"

#define DATEHIGHT 216
static CustomPickerView *piker = nil;
@implementation CustomPickerView

+(CustomPickerView*)sharedPicker{
    if (piker == nil) {
        piker = [[CustomPickerView alloc] init];
    }
    return piker;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame                     = [UIScreen mainScreen].bounds;
        self.backgroundColor           = [UIColor colorWithWhite:0 alpha:0.3];
        main                           = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.frame.size.width,DATEHIGHT+44)];
        main.backgroundColor           = [UIColor whiteColor];
        UIView *bar                    = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        bar.backgroundColor            = [UIColor colorWithWhite:0.9 alpha:1];
        [main addSubview:bar];
        UIButton *close                = [UIButton buttonWithType:UIButtonTypeCustom];
        [close setTitle:@"取消" forState:UIControlStateNormal];
        [close setTitleColor:CRCOLOR_BLACK forState:UIControlStateNormal];
//        [close setImage:[UIImage imageNamed:@"bt_cancel"] forState:UIControlStateNormal];
        [close addTarget:self action:@selector(hidden) forControlEvents:UIControlEventTouchUpInside];
        UIButton *submmite             = [UIButton buttonWithType:UIButtonTypeCustom];
        [submmite setTitle:@"确定" forState:UIControlStateNormal];
        [submmite setTitleColor:CRCOLOR_BLACK forState:UIControlStateNormal];

//        [submmite setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
        [submmite addTarget:self action:@selector(submite:) forControlEvents:UIControlEventTouchUpInside];
        close.frame                    = CGRectMake(10,0, 44, 44);
        submmite.frame                 = CGRectMake([UIScreen mainScreen].bounds.size.width - 10 - 44,  0, 44, 44);
        [main addSubview:submmite];
        [main addSubview:close];
        currentProv                    = 0;
        NSString *path                 = [[NSBundle mainBundle]pathForResource:@"city" ofType:@"txt"];
        NSData *data                   = [NSData dataWithContentsOfFile:path];
        _datas                         = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        _datePicker                    = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, DATEHIGHT)];
        _datePicker.dataSource         = self;
        _datePicker.delegate           = self;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [main addSubview:_datePicker];
        [self addSubview:main];
    }
    return self;
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
   
    return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return _datas.count;
    }
    NSDictionary *prov = _datas[currentProv];
    NSArray *cityArray = [prov objectForKey:@"c"];
    return cityArray.count;
}
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *prov = _datas[currentProv];
    if (component == 0) {
        NSDictionary *prov = _datas[row];
        return [prov objectForKey:@"p"];
    }
    NSArray *cityArray = [prov objectForKey:@"c"];
    NSDictionary *city = cityArray[row];
    return [city objectForKey:@"n"];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        currentProv = row;
        [_datePicker reloadComponent:1];
        return;
    }
    currentCity = row;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hidden];
}
-(void)show{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    [self animatedIn];
}
-(void)animatedIn{
    [UIView animateWithDuration:.35 animations:^{
        CGRect frame   = main.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - DATEHIGHT - 44;
        main.frame     = frame;
    }];
}
-(void)hidden{
    [self animatedOut];
}
-(void)animatedOut{
    [UIView animateWithDuration:.35 animations:^{
        CGRect frame   = main.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        main.frame     = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
-(void)submite:(UIButton*)sender{
    NSDictionary *prov = _datas[currentProv];
    NSArray *cityArray = [prov objectForKey:@"c"];
    NSDictionary *city = cityArray[currentCity];
    NSArray *comString = [prov objectForKey:@"p"];
    NSArray *rowString = [city objectForKey:@"n"];
    currentData        = @[comString,rowString];
    if ([self.delegate respondsToSelector:@selector(changePickerSubmite:)]) {
        [self.delegate performSelector:@selector(changePickerSubmite:) withObject:currentData];
    }
    [self hidden];
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
