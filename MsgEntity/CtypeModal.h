//
//  CtypeModal.h
//  msgcopy
//
//  Created by Gavin on 15/4/13.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CtypeModal : NSObject

@property (nonatomic,copy  ) NSString        * title;
@property (nonatomic,copy  ) NSString        * systitle;
@property (nonatomic       ) NSInteger       cid;

+(instancetype)buildInstanceByJson:(NSDictionary*)json;

@end
