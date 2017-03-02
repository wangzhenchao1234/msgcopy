//
//  LeafItemCell.h
//  msgcopy
//
//  Created by wngzc on 15/4/16.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeafItemCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleView;
+(CGFloat)getWidth:(NSString*)title;
@end
