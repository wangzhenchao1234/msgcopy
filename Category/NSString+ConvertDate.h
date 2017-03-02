//
//  NSString+ConvertDate.h
//  kaoke
//
//  Created by 谷少坤 on 13-12-7.
//  Copyright (c) 2013年 Msgcopy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ConvertDate)
+(NSDate*)getDateFromeString:(NSString*)date;
+(NSString*)getDateStringFromeDate:(NSDate*)date;
+(NSString *) returnTime:(NSDate *)date;
+(NSString *)convertName:(NSString *)username;
+(NSString *)userName:(NSString*)convertName;
@end
