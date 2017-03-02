//
//  BaseTabItemEntity.m
//  Kaoke
//
//  Created by Gavin on 15/1/15.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "BaseTabItemEntity.h"

@implementation BaseTabItemEntity

-(instancetype)initWithType:(NSString*)type title:(NSString *)title icon:(IconEntity*)icon{
    self = [super init];
    if (self) {
        self.icon = icon;
        self.title = title;
        [self registActionWithType:type];
    }
    return self;
}
-(void)doAction{
    if (doAction) {
        doAction(nil);
    }
}

-(void)registActionWithType:(NSString*)type{
    if ([type isEqualToString:@"recommend"]) {
       //打开好友推荐
        doAction = ^(id data){
            [BaseTransitionManager transitionToSMSShare];
        };
    }
}

@end

#import "RecommandController.h"

@interface BaseTransitionManager()

@end

@implementation BaseTransitionManager

+(void)transitionToSMSShare;{
    RecommandController *recommand = [[RecommandController alloc] init];
    [CRRootNavigation() pushViewController:recommand animated:true];
}
@end
