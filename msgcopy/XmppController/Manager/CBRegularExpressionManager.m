//
//  CBRegularExpressionManager.m
//  CBEmotionView
//
//  Created by ly on 8/21/13.
//  Copyright (c) 2013 ly. All rights reserved.
//

#import "CBRegularExpressionManager.h"

@implementation CBRegularExpressionManager


+ (void)itemIndexesWithPattern:(NSString *)pattern inString:(NSString *)findingString usingBlock:(void(^)(NSString *name ,NSRange range, NSInteger idx, BOOL *const stop))block
{
    if (!findingString) {
        return;
    }
    NSAssert(pattern != nil, @"%s: pattern 不可以为 nil", __PRETTY_FUNCTION__);
    NSAssert(findingString != nil, @"%s: findingString 不可以为 nil", __PRETTY_FUNCTION__);
    
    NSError *error = nil;
    NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:
                                   pattern options:NSRegularExpressionCaseInsensitive
                                   error:&error];
    
    // 查找匹配的字符串
    NSArray *result = [regExp matchesInString:findingString options:
                       NSMatchingReportCompletion range:
                       NSMakeRange(0, [findingString length])];
    
    if (error) {
        NSLog(@"ERROR: %@", result);
        return;
    }
    
    NSUInteger count = [result count];
    // 没有查找到结果，返回空数组
    if (0 == count) {
        return;
    }
    
    // 将返回数组中的 NSTextCheckingResult 的实例的 range 取出生成新的 range 数组
    for(NSInteger i = 0; i < count; i++)
    {
        BOOL *const stop = false;
        if (!stop) {
            NSRange aRange = [[result objectAtIndex:i] range];
            NSString *emotion = [findingString substringWithRange:aRange];
            block(emotion,aRange,i,stop);
        }
    }
}

@end
