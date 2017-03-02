//
//  LeafEntity.h
//  msgcopy
//
//  Created by Gavin on 15/4/9.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CtypeModal;
@class LimbEntity;
@class LeafTop;
@class leafPlaceholder;

@interface LeafEntity : NSObject

@property (nonatomic,assign)BOOL readonly;
@property (nonatomic,assign)BOOL isAuthor;
@property (nonatomic,assign)BOOL isInited;
@property (nonatomic,assign)BOOL isSelected;
@property (nonatomic,assign) NSInteger  idx;
@property (nonatomic,assign) NSInteger  lid;
@property (nonatomic,copy  ) NSString   *title;
@property (nonatomic,copy  ) NSString   *descr;
@property (nonatomic,retain) NSArray    *top;
@property (nonatomic,weak  ) LimbEntity *limb;
@property (nonatomic,weak  ) IconEntity *icon;
@property (nonatomic,retain) NSArray    *leafTops;
@property (nonatomic,retain) CtypeModal *ctype;
@property (nonatomic,assign) BOOL       hiddeen;
@property (nonatomic,assign) BOOL       req_permission;
@property (nonatomic,copy  ) NSString   *leafJson;
@property (nonatomic,assign) NSInteger  filterID;
@property (nonatomic,retain) leafPlaceholder *placeholder;
@property (nonatomic,retain) NSMutableArray *homePubs;
@property (nonatomic,retain) NSMutableArray * publications;



+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end

@interface LeafTop : NSObject

@property (nonatomic,copy  ) NSString  * descr;
@property (nonatomic,copy  ) NSString  * link;
@property (nonatomic,copy  ) NSString  * imageUrl;
@property (nonatomic       ) NSInteger pid;

+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end
@interface leafPlaceholder : NSObject
@property (nonatomic,copy  ) NSString  * imageUrl;
@property (nonatomic       ) NSInteger lid;

+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end
