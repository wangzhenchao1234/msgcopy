//
//  ShopItemCollectionCell.m
//  Kaoke
//
//  Created by Gavin on 15/3/18.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "ShopItemCollectionCell.h"

@implementation ShopItemCollectionCell
-(void)awakeFromNib{
    
    _iconView.userInteractionEnabled = false;
    _titleView.font = MSGFont(12);

}
@end
