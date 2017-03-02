//
//  DiyListView.m
//  Kaoke
//
//  Created by Gavin on 14/12/3.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "KKDiyListView.h"
#import "KKDiyModule2View.h"

#define Cell_H 78

@implementation KKDiyListView

+(instancetype)buildByLeaf:(LeafEntity*)leaf frame:(CGRect)frame inset:(UIEdgeInsets)inset action:(onClick)action
{
    KKDiyListView *listView = [[KKDiyListView alloc] initWithFrame:frame];
    NSArray *publications = leaf.publications;
    
    NSInteger i = 0;
    for (PubEntity *pub in publications) {
        
        KKDiyModule2View *contentView = [[KKDiyModule2View alloc] initWithFrame:CGRectMake(inset.left,inset.top + i * Cell_H , [UIScreen mainScreen].bounds.size.width - inset.left - inset.right, Cell_H)];
        [contentView buildByPub:pub action:action type:leaf.ctype.systitle];
        [listView addSubview:contentView];
        i++;
    }
    CGRect viewframe = listView.frame;
    viewframe.origin.y = 0;
    viewframe.size.height = publications.count * Cell_H + inset.top + inset.bottom;
    listView.frame = viewframe;
    return listView;
}

@end
