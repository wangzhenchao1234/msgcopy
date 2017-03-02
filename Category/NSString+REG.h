//
//  NSString+REG.h
//  Kaoke
//
//  Created by xiaogu on 14-10-16.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (REG)

+(NSArray *)itemWithRegularExpressionString:(NSString *)eString forString:(NSString*)string;

@end
