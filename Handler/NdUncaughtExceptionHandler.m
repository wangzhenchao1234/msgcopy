//
//  NdUncaughtExceptionHandler.m
//  Kaoke
//
//  Created by xiaogu on 13-11-25.
//
//

#import "NdUncaughtExceptionHandler.h"

NSString *applicationDocumentsDirectory() {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException *exception) {
    
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString*)kCFBundleExecutableKey];
    NSString *url = [NSString stringWithFormat:@"\n\n=============%@的异常日志=============\nname:\n%@\nreason:\n%@\ncallStackSymbols:\n%@",
                     appName,name,reason,[arr componentsJoinedByString:@"\n"]];
    NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    //除了可以选择写到应用下的某个文件，通过后续处理将信息发送到服务器等
    //还可以选择调用发送邮件的的程序，发送信息到指定的邮件地址
    //或者调用某个处理程序来处理这个信息
    
}

@implementation NdUncaughtExceptionHandler
-(NSString *)applicationDocumentsDirectory {
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
+ (void)setDefaultHandler
{
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

+ (NSUncaughtExceptionHandler*)getHandler
{
    return NSGetUncaughtExceptionHandler();
}
@end
