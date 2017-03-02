//
//  AddCommentFooterView.h
//  msgcopy
//
//  Created by wngzc on 15/7/1.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCommentFooterView : UIView<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray *_attachs;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
-(void)reloadWithAttachs:(NSMutableArray*)attachs;
@end
