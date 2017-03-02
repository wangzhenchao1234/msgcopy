//
//  NSString+REG.m
//  Kaoke
//
//  Created by xiaogu on 14-10-16.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "NSString+REG.h"

@implementation NSString (REG)
+(NSArray *)itemWithRegularExpressionString:(NSString *)eString forString:(NSString*)string{
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:eString options:NSRegularExpressionCaseInsensitive error:&error];
    return [regex matchesInString:string options:0  range:NSMakeRange(0, [string length])];
    
}
@end
