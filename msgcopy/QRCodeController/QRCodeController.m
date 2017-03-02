//
//  KaokeSQViewController.m
//  Kaoke
//
//  Created by xiaogu on 14-5-22.
//  Copyright (c) 2014年 Msgcopy. All rights reserved.
//

#import "QRCodeController.h"
#import "QRCoverView.h"
#import "BroserController.h"

@interface QRCodeController ()<AVCaptureMetadataOutputObjectsDelegate,UIActionSheetDelegate>
{
    AVCaptureSession * _AVSession;
    UIButton *resetButton;
    QRCoverView *cover;
    UILabel *loadingView;
    UIViewController *_backVc;
    NSString *qrValue;
}
@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@end

@implementation QRCodeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor blackColor];
    [self creatToolBar];
    [cover backAction];
    [self showLoading];

    // Do any additional setup after loading the view from its nib.
}
-(void)showLoading{
    
    loadingView      = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 100)];
    loadingView.text          = @"正在初始化...";
    loadingView.textColor     = [UIColor whiteColor];
    loadingView.textAlignment = NSTextAlignmentCenter;
    loadingView.font          = MSGYHFont(18);
    loadingView.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8];
    [self.view addSubview:loadingView];
}
-(void)viewDidAppear:(BOOL)animated{
    if (!_session) {
        [self setupCamera];
    }
    [cover startAnimation];
    [_session startRunning];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [cover backAction];
    [_session stopRunning];
    
}
- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    CGRect frame = self.view.frame;
    _preview.frame = frame;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    [loadingView removeFromSuperview];
    loadingView = nil;
    [self createCaptureBounes];
    // Start
//    [_session startRunning];
}
-(void)creatToolBar{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 100, self.view.frame.size.width,100)];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.frame.size.width - 60)/2, 20, 60, 60);
    [button setTitle:@"开灯" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openAndClose:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 30;
    button.layer.borderColor = [[UIColor whiteColor] CGColor];
    button.layer.borderWidth = 1;
    [view addSubview:button];
    [self.view addSubview:view];
    button = nil;
    view = nil;
}
-(void)reset:(UIButton *)sender{
    sender.enabled = NO;
    [cover startAnimation];
    [_session startRunning];
}
-(void)createCaptureBounes{
    
    cover = [[QRCoverView alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:cover atIndex:1];
    NSString *alertString = @"将取景框对准二维码\n即可扫描";
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 200, self.view.frame.size.width, 100)];
    text.text = alertString;
    text.font = MSGYHFont(16);
    text.textColor = [UIColor whiteColor];
    text.numberOfLines = 2;
    text.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:text];
    text = nil;

}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = [metadataObject.stringValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        qrValue = stringValue;
        NSRange range = [stringValue rangeOfString:@"[msgcopy]"];
        [cover backAction];
        resetButton.enabled = YES;
        [_session stopRunning];
        if (range.location != NSNotFound) {
            
            NSString *infoString = [stringValue substringFromIndex:range.length];
            SBJsonParser *paser = [[SBJsonParser alloc] init];
            id result = [paser objectWithString:infoString];
            if ([result isKindOfClass:[NSDictionary class]]) {
                
                NSString *cmd = [result valueForKey:@"cmd"];
                SEL method = NSSelectorFromString([NSString stringWithFormat:@"%@:",cmd]);
                if ([self respondsToSelector:method]) {
                    [self performSelector:method withObject:result];
                }
                return;
            }
        }
        NSString *head = @"third/p/";
        NSRange pubRange = [stringValue rangeOfString:head];
        if (pubRange.location!=NSNotFound) {
            
            NSString *contentStr = [stringValue substringFromIndex:pubRange.location + pubRange.length];
            NSArray *parms = [contentStr componentsSeparatedByString:@"/?"];
            NSUInteger appid = 0;
            NSUInteger pubid = 0;
            if (parms.count>0) {
                pubid = [parms[0] integerValue];
            }
            if (parms.count==2) {
                NSString *appInfo = parms[1];
                if (appInfo.length>6) {
                    appid = [[appInfo substringFromIndex:7] integerValue];
                }
            }
            if (appid == kCurAppID) {
                [PubOpenHanddler openWithPubID:pubid placeholderView:nil];
            }else{
                [MSGTansitionManager openLink:qrValue];
            }
            return;
        }
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"确定要打开:\n%@",stringValue] delegate:self cancelButtonTitle:@"复制" destructiveButtonTitle:@"打开" otherButtonTitles:nil, nil];
        [sheet showInView:self.view];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [MSGTansitionManager openLink:qrValue];
        
    }else if(buttonIndex == 1){
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = qrValue;
        [self reset:nil];
        [CustomToast showMessageOnWindow:@"内容已经复制到剪切板"];
        
    }
    
}
-(void)open_webapp:(NSDictionary *)data{
    
    NSInteger aid = [[data valueForKey:@"id"] integerValue];
    NSString *appData = [data valueForKey:@"init_data"];
    if (aid&&appData) {
        NSDictionary *params = @{
                                 @"init_data":appData?appData:@"{}"
                                 };
        [MSGTansitionManager openWebappWithID:aid withParams:params goBack:nil callBack:nil];
    
    }else{
        [CustomToast showMessageOnWindow:@"获取信息失败"];
        [cover startAnimation];
        [_session startRunning];

    }
    
}

-(void)open_user_info:(NSDictionary *)data{
    
    NSString *username = [data valueForKey:@"init_data"];
    if (username) {
        
        ContactContentController *content = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ContactContentController"];
        content.userName = username;
        content.disableEdite = true;
        [self.navigationController pushViewController:content animated:true];
        
    }else{
        [CustomToast showMessageOnWindow:@"获取信息失败"];
        [cover startAnimation];
        [_session startRunning];
        
    }
    
}

-(void)openFlashlight
{
    
    AVCaptureSession * session = [[AVCaptureSession alloc]init];
    if (_device.torchMode == AVCaptureTorchModeOff&&_device.torchAvailable) {
        //Create an AV session
        // Create device input and add to current session
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        [session addInput:input];
        
        // Create video output and add to current session
        AVCaptureVideoDataOutput * output = [[AVCaptureVideoDataOutput alloc]init];
        [session addOutput:output];
        
        // Start session configuration
        [session beginConfiguration];
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOn];
        [_device setFlashMode:AVCaptureFlashModeOn];
        [_device unlockForConfiguration];
        [session commitConfiguration];
        _AVSession = session;
    }
    
}
-(void)closeFlashlight
{
    if (_device.torchMode == AVCaptureTorchModeOn&&_device.torchAvailable) {
   
        [_AVSession beginConfiguration];
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOff];
        [_device setFlashMode:AVCaptureFlashModeOff];
        [_device unlockForConfiguration];
        [_AVSession commitConfiguration];
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)openAndClose:(id)sender {
    UIButton *button = sender;
    if ([button.titleLabel.text isEqualToString:@"开灯"]) {
        [button setTitle:@"关灯" forState:UIControlStateNormal];
        [self openFlashlight];
    }else{
        [button setTitle:@"开灯" forState:UIControlStateNormal];
        [self closeFlashlight];
    }
}
-(void)dealloc{
    resetButton = nil;
    _session = nil;
    _output = nil;
    _input = nil;
    _preview = nil;
    [cover backAction];
    cover = nil;
}
@end
