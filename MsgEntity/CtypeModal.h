//
//  CtypeModal.h
//  msgcopy
//
//  Created by wngzc on 15/4/13.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CtypeModal : NSObject

@property (nonatomic,copy  ) NSString        * title;
@property (nonatomic,copy  ) NSString        * systitle;
@property (nonatomic       ) NSInteger       cid;

+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end
