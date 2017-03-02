//
//  BaseTabItemEntity.h
//  Kaoke
//
//  Created by Gavin on 15/1/15.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseTabItemEntity : NSObject
{
    void(^doAction)(id data);
}

@property(nonatomic,retain)IconEntity *icon;
@property(nonatomic,retain)NSString *title;
-(instancetype)initWithType:(NSString*)type title:(NSString*)title icon:(IconEntity*)icon;
-(void)doAction;
@end
@interface BaseTransitionManager : NSObject
+(void)transitionToSMSShare;
@end
