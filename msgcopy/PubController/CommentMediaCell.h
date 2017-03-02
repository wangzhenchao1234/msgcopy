//
//  CommentMediaCell.h
//  msgcopy
//
//  Created by Gavin on 15/7/1.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentMediaCellDelegate <NSObject>

-(void)deleteItem:(NSDictionary*)attach;

@end

@interface CommentMediaCell : UICollectionViewCell
{
    NSDictionary *attach;
}
@property (weak, nonatomic) IBOutlet UIImageView *playView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIButton *deleteView;
@property(weak,nonatomic)id<CommentMediaCellDelegate>delegate;
-(void)buildWithData:(NSDictionary*)data target:(id)target;

@end
