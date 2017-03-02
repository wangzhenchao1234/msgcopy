//
//  CommentCell.h
//  msgcopy
//
//  Created by wngzc on 15/6/29.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "MsgTableCell.h"

@class TYAttributedLabel;

@class CommentEntity;
@interface CommentCell : MsgTableCell<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    NSDateFormatter *formmater;
    NSMutableArray *medias;
    NSArray *imagesItem;
    CommentEntity *commentData;
}
@property (weak, nonatomic) IBOutlet UIButton *headView;
@property (weak, nonatomic) IBOutlet UILabel *nickView;
@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaView;
@property (weak, nonatomic) IBOutlet TYAttributedLabel *attrView;


-(void)buildByData:(CommentEntity*)comment;
+(CGFloat)getHeightWithContent:(NSString *)content mediaCount:(NSInteger)count;
@end
