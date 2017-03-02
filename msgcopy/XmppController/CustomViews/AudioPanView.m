//
//  AudioPanView.m
//  Kaoke
//
//  Created by xiaogu on 14-9-18.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "AudioPanView.h"
#import "VoiceConverter.h"
#import "RecordAudioSetting.h"
#import "AmrPlayer.h"
#import "UIImage+JSQMessages.h"

#define keyBoardHeight 216

@implementation AudioPanView

- (id)initWithFrame:(CGRect)frame target:(id<AudioPanDelegate>)target
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = CRCOLOR_WHITE;
        self.frame = CGRectMake(0, frame.origin.y, frame.size.width, keyBoardHeight);
        self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.recordButton.frame = CGRectMake(0, 0, 80, 80);
        [self.recordButton setImage:[UIImage jsq_defaultAudioImage] forState:UIControlStateNormal];
        [self.recordButton setImage:[UIImage jsq_hilightedAudioImage] forState:UIControlStateSelected];
        self.delegate = target;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self.recordButton addTarget:self action:@selector(pressedRecordButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.recordButton addTarget:self action:@selector(pressedRecordButtonDown:) forControlEvents:UIControlEventTouchDown];
        [self.recordButton addGestureRecognizer:pan];
        CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.recordButton.center = center;
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, frame.size.width, 20)];
        self.title.text = @"按住说话";
        self.title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_title];
        [self addSubview:_recordButton];
        [self intilizedRecord];
    }
    return self;
}
-(void)pan:(UIGestureRecognizer*)pan{
    
    if (isRecording) {
        if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged){
            
            
        }else{
            
            isRecording = false;
            [self stopTimer];
        }
    }
}
-(void)intilizedRecord{
    
    originWav = @"record";
    //初始化录音
    recordFilePath = [RecordAudioSetting getPathByFileName:originWav ofType:@"wav"];
    self.recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:recordFilePath]
                                                settings:[RecordAudioSetting getAudioRecorderSettingDict]
                                                   error:nil];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    //还原计数
    curTime = 0;
    //还原发送
    canNotSend = NO;
    
}
-(void)startRecord{
    
    //准备录音
    //开始录音
    [self.recordButton setSelected:true];
    isRecording = true;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self.recorder prepareToRecord];
    [self.recorder record];
    
}
-(void)pressedRecordButtonUp:(UIButton*)sender{
    
    if (!self.timer||!self.timer.isValid||curTime<1) {
        [CustomToast showMessageOnWindow:@"按键时间太短"];
    }
    [self stopTimer];
    
}
-(void)pressedRecordButtonDown:(UIButton*)sender{
    
    self.title.text = @"0:00";
    [self startRecord];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    
}
-(void)stopTimer{
    
    [self.recordButton setSelected:false];
    [self.recorder stop];
    [self.timer invalidate];
    self.timer = nil;
    self.title.text = @"按住说话";
    
}
-(void)timer:(NSTimer*)timer{
    
    curTime ++;
    NSString *curTimeStr = [NSString stringWithFormat:@"%d:%d%d",(int)curTime/60%10,(int)curTime/10%6,curTime%10];
    self.title.text = curTimeStr;
    if (curTime >=60) {
        [self stopTimer];
    }
    
}

#pragma mark - wav转amr
- (void)wavToAmr{
    
    converArm = [NSString getmd5WithString:[[RecordAudioSetting getCurrentTimeString] stringByAppendingString:@"_amr"]];
    recordArmFilePath = [RecordAudioSetting getPathByFileName:converArm ofType:@"amr"];
    //转格式
    [VoiceConverter wavToAmr:recordFilePath amrSavePath:recordArmFilePath];
    [self.delegate sendVoice:converArm time:curTime];
    curTime = 0;

}

#pragma mark - AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    NSLog(@"录音停止");
    if (curTime<=0) {
        return;
    }
    [self wavToAmr];
    
}
- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder{
    
    curTime = 0;
    NSLog(@"录音开始");
    
}
- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags{
    
    NSLog(@"录音中断");
    curTime = 0;
    [CustomToast showMessageOnWindow:@"录制中断请重试"];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
