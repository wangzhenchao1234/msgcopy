//
//  AmrPlayer.m
//  Kaoke
//
//  Created by xiaogu on 14-9-19.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "AmrPlayer.h"
#import "RecordAudioSetting.h"
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

#include "interf_dec.h"

const unsigned int PACKETNUM =  25;//20ms * 25 = 0.5s ,每个包25帧,可以播放0.5秒
const float KSECONDSPERBUFFER = 0.2; //每秒播放0.2个缓冲
const unsigned int AMRFRAMELEN = 32; //帧长
const unsigned int PERREADFRAME =  10;//每次读取帧数
static unsigned int gBufferSizeBytes = 0x10000;


@implementation AmrPlayer
@synthesize queue;

// 回调（Callback）函数的实现

static void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer) {
    AmrPlayer* player = (__bridge AmrPlayer*)inUserData;
    [player  audioQueueOutputWithQueue:inAQ queueBuffer:buffer];
}

//初始化方法（为NSObject中定义的初始化方法）

- (id) init {

    _isPlaying = false;
    _destate = Decoder_Interface_init();
    downloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    downloadGroup = dispatch_group_create();
    return self;

}

-(void)initFile:(char*) amrFileName
{
    
#ifdef IF2
    //short block_size[16]={ 12, 13, 15, 17, 18, 20, 25, 30, 5, 0, 0, 0, 0, 0, 0, 0 };
#else
    char magic[8];
    //short block_size[16]={ 12, 13, 15, 17, 19, 20, 26, 31, 5, 0, 0, 0, 0, 0, 0, 0 };
#endif
    
    _hasReadSize=0;
    
    _amrFile = fopen(amrFileName, "rb");
    
    
    
    int rCout=fread( magic, sizeof( char ), strlen( "#!AMR\n" ), _amrFile );
    _hasReadSize=rCout;
    if ( strncmp( magic, "#!AMR\n", strlen( "#!AMR\n" ) ) ) {
        
        fclose( _amrFile );
    }
    
    
}

//缓存数据读取方法的实现

- (void) audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
                       queueBuffer:(AudioQueueBufferRef)audioQueueBuffer {
    
    //OSStatus status;
    
    // 读取包数据
    //UInt32  numBytes;
    
    //UInt32  numPackets = numPacketsToRead;
    
    //status = AudioFileReadPackets( audioFile, NO, &numBytes, packetDescs, packetIndex, &numPackets, audioQueueBuffer->mAudioData);
    
    //-----
    short pcmBuf[1600]={0};//KSECONDSPERBUFFER * 160 * 50;
    
    int readAMRFrame = 0;
    const short block_size[16]={ 12, 13, 15, 17, 19, 20, 26, 31, 5, 0, 0, 0, 0, 0, 0, 0 };
    char analysis[32]={0};
    
    
    int rCout=0;
    // while (fread(analysis, sizeof (unsigned char), 1, file_analysis ) > 0)
    while (readAMRFrame < PERREADFRAME && (rCout=fread(analysis, sizeof (unsigned char), 1, _amrFile)))
    {
        int dec_mode = (analysis[0] >> 3) & 0x000F;
        
        int read_size = block_size[dec_mode];
        _hasReadSize += rCout;
        rCout=fread(&analysis[1], sizeof (char), read_size, _amrFile);
        
        _hasReadSize += rCout;
        
        Decoder_Interface_Decode(_destate,(unsigned char *)analysis,&pcmBuf[readAMRFrame*160],0);
        readAMRFrame ++;
    }
    
    NSLog(@"readCount:%d",_hasReadSize);
    
    if (readAMRFrame > 0) {
        
        audioQueueBuffer ->mAudioDataByteSize = readAMRFrame * 2 * 160;
        audioQueueBuffer ->mPacketDescriptionCount = readAMRFrame*160;
        memcpy(audioQueueBuffer ->mAudioData, pcmBuf, readAMRFrame * 160 *2);
        AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffer, 0, NULL);
        
    }else{
        _isPlaying = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(true);
        });
    }

}

-(void) playAmrWithUrl:(NSString *)url complet:(void(^)(BOOL success))completeBlock{
    
    complete = completeBlock;
    _url = url;
    __weak NSString *strUrl = url;
    dispatch_group_async(downloadGroup, downloadQueue, ^{
        [self downloadFileFromUrl:strUrl complet:(void(^)(BOOL success))completeBlock];
    });
    
}
-(void)downloadFileFromUrl:(NSString *)url complet:(void(^)(BOOL success))completeBlock{
    
    NSString *fileName = [NSString getmd5WithString:url];
    NSString *path = [RecordAudioSetting getPathByFileName:fileName ofType:@"amr"];
    __weak AmrPlayer *player = self;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [player startPlay:(char*)[path UTF8String]];
        });
        return;
    }
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:URL_DOMAIN];
    NSString *urlString = url;
    MKNetworkOperation *op = [engine operationWithURLString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] params:nil httpMethod:@"GET"];
    [op onCompletion:^(MKNetworkOperation *completedOperation) {
        
        BOOL success = [completedOperation.responseData writeToFile:path atomically:YES];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [player startPlay:(char*)[path UTF8String]];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(false);
            });
        }
        
    } onError:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(false);
        });
    
    }];
    [engine enqueueOperation:op];
    
}
//音频播放方法的实现

-(void) startPlay:(char*) path
{
    _isPlaying = true;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    //CFURLRef
    
    [self initFile:path];

    //--设置音频数据格式
    memset(&dataFormat, 0, sizeof(dataFormat));
    dataFormat.mFormatID = kAudioFormatLinearPCM;
    dataFormat.mSampleRate = 8000.0;
    dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    dataFormat.mBitsPerChannel = 16;
    dataFormat.mChannelsPerFrame = 1;
    dataFormat.mFramesPerPacket = 1;
    
    dataFormat.mBytesPerFrame = (dataFormat.mBitsPerChannel/8) * dataFormat.mChannelsPerFrame;
    dataFormat.mBytesPerPacket = dataFormat.mBytesPerFrame ;
    
    //---
    
    // 创建播放用的音频队列(nil:audio队列的间隙线程)
    AudioQueueNewOutput(&dataFormat, BufferCallback,(__bridge void *)(self), nil, nil, 0, &queue);
    
    //==独立线程的模式
    packetIndex = 0;
    gBufferSizeBytes = KSECONDSPERBUFFER *  2 * 160 * 50 *2; //MR122 size * 2
    
    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueAllocateBuffer(queue, gBufferSizeBytes, &buffers[i]);//&mBuffers[i]
    }
    
    //设置音量
    AudioQueueSetParameter (queue,kAudioQueueParam_Volume,1.0);
    
    //队列处理开始，此后系统会自动调用回调（Callback）函数
    AudioQueueStart(queue, nil);
    
    [self StartQueue];
}

- (UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer {
        
    short pcmBuf[1600]={0};; //KSECONDSPERBUFFER * 160 * 50
    
    int readAMRFrame = 0;
    const short block_size[16]={ 12, 13, 15, 17, 19, 20, 26, 31, 5, 0, 0, 0, 0, 0, 0, 0 };
    char analysis[32]={0};
    
    int rCout=0;
    while (readAMRFrame < PERREADFRAME && (rCout=fread(analysis, sizeof (unsigned char), 1, _amrFile)))
    {
        
        _hasReadSize += rCout;
        
        int dec_mode = (analysis[0] >> 3) & 0x000F;
        
        int read_size = block_size[dec_mode];
        rCout=fread(&analysis[1], sizeof (char), read_size, _amrFile);
        
        _hasReadSize += rCout;
        
        Decoder_Interface_Decode(_destate,(unsigned char *)analysis,&pcmBuf[readAMRFrame*160],0);
        readAMRFrame ++;
    }
    NSLog(@"readCount:%d",_hasReadSize);
    
    
    if (readAMRFrame > 0) {
        buffer ->mAudioDataByteSize = readAMRFrame * 2 * 160;
        buffer ->mPacketDescriptionCount = readAMRFrame*160;
        memcpy(buffer ->mAudioData, pcmBuf, readAMRFrame * 160 *2);
        AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
        
    }
    return readAMRFrame;
}

- (void)dealloc {
    
    AudioQueueDispose(queue, TRUE);
    Decoder_Interface_exit(_destate);
    if (_amrFile) {
        fclose( _amrFile );
    }
}

-(OSStatus)StartQueue
{   
    // prime the queue with some data before starting
    for (int i = 0; i < NUM_BUFFERS; ++i) {
        //读取包数据
        if ([self readPacketsIntoBuffer:buffers[i]] == 0) {
            break;
        }
    }
    return AudioQueueStart(queue, NULL);
}

-(OSStatus)StopQueue
{
    _isPlaying = false;
    OSStatus result = AudioQueueStop(queue, TRUE);
    if (result) {
        printf("ERROR STOPPING QUEUE!\n");
        complete(false);
    }else{
        complete(true);

    }
    return result;
}

-(OSStatus)PauseQueue
{
    _isPlaying = false;
    OSStatus result = AudioQueuePause(queue);
    
    return result;
}

@end
