//
//  LocalManager.h
//  Tushuo
//
//  Created by Gavin on 15/3/24.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalManager : NSObject
+(void)storeObject:(id)obj forKey:(NSString*)key;
+(id)objectForKey:(NSString*)key;

@end
