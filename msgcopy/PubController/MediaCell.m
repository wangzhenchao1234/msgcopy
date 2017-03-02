//
//  MediaCell.m
//  msgcopy
//
//  Created by Gavin on 15/6/30.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MediaCell.h"

@implementation MediaCell
-(void)awakeFromNib{
    _iconView.layer.cornerRadius = 5;
    _iconView.clipsToBounds = true;
    
}

-(void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        _coverView.alpha = 0.1;
    }else{
        _coverView.alpha = 0;
    }
}
@end
