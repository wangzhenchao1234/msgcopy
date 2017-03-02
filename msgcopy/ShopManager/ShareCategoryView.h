//
//  ShareCategoryView.h
//  msgcopy
//
//  Created by Hackintosh on 15/11/11.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareCategoryView;

@protocol ShareCategoryViewDelegate <NSObject>

-(void)categoryView:(ShareCategoryView*)categoryView clickLeaf:(LeafEntity*)leaf limb:(LimbEntity*)limb;

@end


@interface ShareCategoryView : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,retain)NSMutableArray *limbs;
@property(nonatomic,retain)ShopStoreEntity *shop;
@property(nonatomic,weak)id<ShareCategoryViewDelegate>delegate;
-(void)show;
-(void)hidden;
@end
