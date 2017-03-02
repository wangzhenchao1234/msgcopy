//
//  LeafListView.h
//  msgcopy
//
//  Created by Gavin on 15/4/15.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeafListViewDelegate <NSObject>

-(void)changeToItem:(NSInteger)index;

@end

@interface LeafListView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) id<LeafListViewDelegate>delegate;
-(void)reloadMenuWithLeafs:(NSArray*)leafs;
-(void)switchTo:(NSInteger)index;
@end
