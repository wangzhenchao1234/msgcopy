//
//  DeskTopItem.h
//  Kaoke
//
//  Created by xiaogu on 13-12-31.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class DeskTopItemModaul;

@interface DeskTopItem : UIView

{
    UIImage      * placeHolder;
    NSInteger    curIndex;
    SDImageCache * cache;
}
@property (nonatomic,retain) UILabel           *title;
@property (nonatomic,retain) UILabel           *subTitle;
@property (nonatomic,retain) UIImageView       *image;
@property (nonatomic,retain) UIImageView       *cover;
@property (nonatomic,retain) UIView            *backgroundView;
@property (nonatomic,retain) CATransition      *animation;
@property (nonatomic,retain) DeskTopItemModaul *data;
@property (nonatomic,retain) UIButton          *clickView;
-(id)initWithData:(DeskTopItemModaul*)data;
@end
