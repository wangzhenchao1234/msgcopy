//
//  LocalManager.h
//  Tushuo
//
//  Created by wngzc on 15/3/24.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalManager : NSObject
+(void)storeObject:(id)obj forKey:(NSString*)key;
+(id)objectForKey:(NSString*)key;

@end
