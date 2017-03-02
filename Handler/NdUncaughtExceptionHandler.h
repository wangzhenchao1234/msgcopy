//
//  NdUncaughtExceptionHandler.h
//  Kaoke
//
//  Created by xiaogu on 13-11-25.
//
//

#import <Foundation/Foundation.h>
@interface NdUncaughtExceptionHandler : NSObject
+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler*)getHandler;
@end
