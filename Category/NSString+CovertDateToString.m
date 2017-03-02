//
//  NSString+CovertDateToString.m
//  kaoke
//
//  Created by 谷少坤 on 13-12-8.
//  Copyright (c) 2013年 Msgcopy. All rights reserved.
//

#import "NSString+CovertDateToString.h"

@implementation NSString (CovertDateToString)
+(NSString*)getDateStringFromeDate:(NSDate*)date{
    
    if (date == nil) {
        return nil;
    }
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *newDate = [dateFormater stringFromDate:date];
    return newDate;
}
@end
