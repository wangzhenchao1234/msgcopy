//
//  BusinessListCell.h
//  msgcopy
//
//  Created by Gavin on 15/4/16.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UICustomLineLabel;
@interface BusinessListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *priceView;
@property (weak, nonatomic) IBOutlet UICustomLineLabel*prePriceView;
@property (weak, nonatomic) IBOutlet UILabel *LikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *PLlabel;



-(void)buildWithData:(PubEntity*)pub;
+(CGFloat)getCellHeight;
@end
