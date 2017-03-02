//  contactMenu.h
//  Kaoke
//
//  Created by xiaogu on 13-9-27.
//
//

#import <UIKit/UIKit.h>

typedef enum{
    
    LineTypeNone,//没有画线
    LineTypeUp ,// 上边画线
    LineTypeMiddle,//中间画线
    LineTypeDown,//下边画线
    
} LineType ;

@interface UICustomLineLabel : UILabel

@property (assign, nonatomic) LineType lineType;
@property (retain, nonatomic) UIColor * lineColor;


@end
