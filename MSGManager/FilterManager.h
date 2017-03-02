//
//  FilterManager.h
//  msgcopy
//
//  Created by Gavin on 15/7/11.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterManager : NSObject
+(NSString*)curFilterName;
+(NSInteger)curFilterId;
+(void)updateCurFilter:(NSDictionary*)condition;
+(NSArray*)filterData;
+(BOOL)isValid;
@end
