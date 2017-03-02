//
//  GridBusinessCell.h
//  msgcopy
//
//  Created by wngzc on 15/4/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICustomLineLabel;

@interface GridBusinessCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *descrView;
@property (weak, nonatomic) IBOutlet UILabel *priceView;
@property (weak, nonatomic) IBOutlet UICustomLineLabel *prePrice;
@property (weak, nonatomic) IBOutlet UILabel *LikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *PLlabel;

-(void)buildWithData:(PubEntity*)pub;
+(CGFloat)getHeigh:(PubEntity*)pub;
@end
