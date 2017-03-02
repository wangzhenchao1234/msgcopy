//
//  NSString+ConvertDate.m
//  kaoke
//
//  Created by 谷少坤 on 13-12-7.
//  Copyright (c) 2013年 Msgcopy. All rights reserved.
//

#import "NSString+ConvertDate.h"

@implementation NSString (ConvertDate)
+(NSDate*)getDateFromeString:(NSString*)date{
    if (date == nil) {
        return nil;
    }
    NSMutableString *dateStr = [date mutableCopy];
    NSRange range = [dateStr rangeOfString:@"T"];
    if (range.location!=NSNotFound) {
         [dateStr replaceCharactersInRange:range withString:@" "];
    }
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *newDate = [dateFormater dateFromString:dateStr];
    return newDate;
}
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

+(NSString *) returnTime:(NSDate *)date
{
    
    NSTimeInterval late=[date timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha = now - late;
    
    if (cha / 3600 < 1) {
        timeString = [NSString stringWithFormat:@"%f", cha / 60];
        timeString = [timeString substringToIndex:timeString.length-7];
        if ([timeString integerValue]<=5) {
            timeString = @"刚刚";
        }else{
            timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        }
    }
    if (cha / 3600 > 1 && cha / 86400 < 1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"HH:mm"];
        timeString = [NSString stringWithFormat:@"今天 %@",[dateformatter stringFromDate:date]];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        if([timeString integerValue] < 3){
            timeString=[NSString stringWithFormat:@"%@天前", timeString];
        }else{
            NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"MM-dd"];
            timeString = [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:date]];
        }
    }
    if (cha/(86400*365)>1) {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
        [dateformatter setDateFormat:@"yyyy-MM-dd"];
        timeString = [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:date]];
    }
    return timeString;
}
+(NSString *)convertName:(NSString *)username{
    
    if (username&&username.length > 0) {
        return [username stringByReplacingOccurrencesOfString:@"@" withString:@"[at]"];
    }
    return username;
    
}
+(NSString *)userName:(NSString*)convertName{
    
    if (convertName&&convertName.length>0) {
        return [convertName stringByReplacingOccurrencesOfString:@"[at]" withString:@"@"];
    }
    return convertName;
    
}
@end
