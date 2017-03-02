//
//  LimbEntity.m
//  msgcopy
//
//  Created by Gavin on 15/4/9.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "LimbEntity.h"

@implementation LimbEntity
-(id)init
{
    self = [super init];
    _leafs = [NSMutableArray new];
    return self;
}
-(void)addLeaf:(LeafEntity*)leaf
{
    [_leafs addObject:leaf];
    leaf.limb = self;
}

-(NSInteger) getSumSelectedLeaf
{
    NSInteger sum = 0;
    for (LeafEntity* leaf in self.leafs) {
        if([leaf isSelected])  sum++;
    }
    return sum;
}

+(instancetype)buildInstanceByJson:(NSDictionary*)json
{
    LimbEntity* limb  = [[LimbEntity alloc] init];
    limb.isOpen            = NO;
    limb.lid               = [[Utility dictionaryValue:json forKey:@"id"] integerValue];
    limb.idx               = [[Utility dictionaryValue:json forKey:@"idx"] integerValue];
    limb.title             = [Utility dictionaryValue:json forKey:@"title"];
    limb.descr             = [Utility dictionaryValue:json forKey:@"descr"];
    NSDictionary *jsonIcon = [Utility dictionaryValue:json forKey:@"icon"];
    limb.icon              = [IconEntity buildInstanceByJson:jsonIcon];
    //    limb.leafs             = [[KaokeChannelManager getInstance] leafCacheforLimb:limb];
    return limb;
}

@end
