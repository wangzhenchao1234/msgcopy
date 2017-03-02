//
//  VideoCommentCell.h
//  msgcopy
//
//  Created by wngzc on 15/5/15.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYAttributedLabel;


@interface VideoCommentCell : UICollectionViewCell<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSDateFormatter *formmater;
    NSMutableArray *medias;
    NSArray *imagesItem;
    CommentEntity *commentData;

}
@property (weak, nonatomic) IBOutlet UIButton *headView;
@property (weak, nonatomic) IBOutlet UILabel *nickView;
@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet UIView *separatorLine;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaView;
@property (weak, nonatomic) IBOutlet TYAttributedLabel *attrView;


-(void)buildByData:(CommentEntity*)comment;
+(CGFloat)getHeightWithContent:(NSString *)content mediaCount:(NSInteger)count;
@end
