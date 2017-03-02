//
//  LeafControllerDelegate.h
//  msgcopy
//
//  Created by wngzc on 15/7/23.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum SortRegulation
{
    SORT_NORMAL,
    SORT_GPS
    
}SortRegulation;

@protocol LeafControllerDelegate <NSObject>

@optional

@property(nonatomic,retain)NSMutableArray *leafTops;
@property(nonatomic,retain)NSMutableArray *publications;
@property(nonatomic,retain)NSMutableArray *sortPublications;
@property(nonatomic,retain)LeafEntity *leaf;
@property(nonatomic,assign)SortRegulation regulation;

-(void)refreshPublications;
-(void)morePublications;
-(void)insert:(PubEntity*)pub;
-(void)sort:(SortRegulation)regulation;
-(UITableView*)listView;
@end
