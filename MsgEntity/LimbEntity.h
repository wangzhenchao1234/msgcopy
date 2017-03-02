//
//  LimbEntity.h
//  msgcopy
//
//  Created by Gavin on 15/4/9.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IconEntity;
@class MSGAppEntity;

@interface LimbEntity : NSObject
@property (nonatomic,assign) NSInteger      lid;
@property (nonatomic,assign) NSInteger      idx;
@property (nonatomic,assign)BOOL isSelected;
@property (nonatomic,assign)BOOL isOpen;
@property (nonatomic,assign) NSInteger      currentLeafId;
@property (nonatomic,retain) IconEntity     *icon;
@property (nonatomic,copy  ) NSString       * title;
@property (nonatomic,copy  ) NSString       * descr;
@property (nonatomic,weak  ) MSGAppEntity   * app;
@property (nonatomic,retain) NSMutableArray * leafs;

+(instancetype)buildInstanceByJson:(NSDictionary*)json;
-(void)addLeaf:(LeafEntity*)leaf;
@end
