//
//  RecordAudioSetting.m
//  Kaoke
//
//  Created by xiaogu on 14-9-19.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "RecordAudioSetting.h"
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@implementation RecordAudioSetting
/**
 生成当前时间字符串
 @returns 当前时间字符串
 */
+ (NSString*)getCurrentTimeString
{
    NSString *dateString = [NSString stringWithFormat:@"_%d",(int)[[NSDate date] timeIntervalSinceReferenceDate]];
    return dateString;
}
/**
 获取缓存路径
 @returns 缓存路径
 */
+ (NSString*)getCacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
}

/**
 判断文件是否存在
 @param _path 文件路径
 @returns 存在返回yes
 */
+ (BOOL)fileExistsAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:_path];
}

/**
 删除文件
 @param _path 文件路径
 @returns 成功返回yes
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

/**
 生成文件路径
 @param _fileName 文件名
 @param _type 文件类型
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[RecordAudioSetting getCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"Record/%@",_fileName]] stringByAppendingPathExtension:_type];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [[RecordAudioSetting getCacheDirectory] stringByAppendingPathComponent:@"Record"];
    if (![manager fileExistsAtPath:path]) {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return fileDirectory;
}

/**
 生成文件路径
 @param _fileName 文件名
 @returns 文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName{
    NSString* fileDirectory = [[RecordAudioSetting getCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"RecordTemp/%@",_fileName]];
    return fileDirectory;
}

/**
 获取录音设置
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   nil];
    return recordSetting;
}

@end
