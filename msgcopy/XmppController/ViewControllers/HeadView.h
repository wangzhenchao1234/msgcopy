//
//  UserHeadView.h
//  msgcopy
//
//  Created by Gavin on 15/6/12.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeadView : UIView
{
    @private
    NSString *_url;
}
-(void)setImageWithUrl:(NSString *)headUrl;
@end
