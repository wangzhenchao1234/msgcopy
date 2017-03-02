//
//  AudioPanView.h
//  Kaoke
//
//  Created by xiaogu on 14-9-18.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
//默认最大录音时间
#define kDefaultMaxRecordTime               60
@class AmrPlayer;

@protocol AudioPanDelegate <NSObject>
@optional
-(void)sendVoice:(NSString *)name time:(NSInteger)time;

@end

@interface AudioPanView : UIView<AVAudioRecorderDelegate,UIGestureRecognizerDelegate>{
    
@protected
    
    NSInteger               maxRecordTime;  //最大录音时间
    NSString                *recordFileName;//录音文件名
    NSString                *recordFilePath;//录音文件路径
    NSString                *recordArmFilePath;//录音文件路径
    NSInteger               curTime;        //当前计数,初始为0
    BOOL                    canNotSend;         //不能发送
    NSString                *originWav;         //原wav文件名
    NSString                *converArm;         //原wav文件名
    BOOL                    isRecording;
    
}
@property (nonatomic,weak)id<AudioPanDelegate> delegate;
@property (strong,nonatomic) UILabel *title;
@property (nonatomic,strong) NSTimer *timer;
@property (strong,nonatomic) UIButton *recordButton;
@property (nonatomic,strong) UIImageView *trashView;
@property (nonatomic,strong) UIImageView *listenView;
@property (strong, nonatomic)AVAudioRecorder *recorder;
@property (strong,nonatomic)AmrPlayer *audioPlayer;
- (id)initWithFrame:(CGRect)frame target:(id)target;
@end
