//
//  BannerCollectionCell.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/10.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import "BannerCollectionCell.h"

@implementation BannerCollectionCell
-(void)awakeFromNib
{   //添加此方法的目的只是在新的xcode下，当调用awakeFromNib时，系统希望调用这个[super awakeFromNib]，让系统对xib文件进行初始化，如果不调用可能在老的xcode下没影响，但是在心底xcode下会有⚠️，所以添加了会使代码更规范，http://blog.csdn.net/lengshengren/article/details/17393865
     [super awakeFromNib];
    _imageView.layer.cornerRadius = 5;
    _imageView.layer.borderWidth = 1;
    _imageView.layer.borderColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1].CGColor;
    _imageView.backgroundColor = CRCOLOR_CLEAR;

}

- (IBAction)deleteItem:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(deleteItemAtIndex:)]) {
        [_delegate deleteItemAtIndex:_indexPath];
    }

}

@end
