//
//  ShopStoreCell.m
//  Kaoke
//
//  Created by Gavin on 15/3/10.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "ShopStoreCell.h"

@implementation ShopStoreCell

- (void)awakeFromNib {
    // Initialization code
    _logoView.clipsToBounds = true;
    _logoView.backgroundColor = [UIColor colorFromHexRGB:@"f8f8f8"];
}

-(void)buildWithData:(ShopStoreEntity*)entity
{
    [self.logoView sd_setImageWithURL:[NSURL URLWithString:entity.thumbnail.turl] placeholderImage:nil];
    self.shopTitleView.text = entity.title;
    self.productCategoryView.text = entity.descr;

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
