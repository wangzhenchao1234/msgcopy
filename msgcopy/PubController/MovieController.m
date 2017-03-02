//
//  MovieController.m
//  msgcopy
//
//  Created by Gavin on 15/7/1.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MovieController.h"

NSString * const MovieParameterMinBufferedDuration = @"MovieParameterMinBufferedDuration";
NSString * const MovieParameterMaxBufferedDuration = @"MovieParameterMaxBufferedDuration";
NSString * const MovieParameterDisableDeinterlacing = @"MovieParameterDisableDeinterlacing";


////////////////////////////////////////////////////////////////////////////////

static NSString * formatTimeInterval(CGFloat seconds, BOOL isLeft)
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    NSMutableString *format = [(isLeft && seconds >= 0.5 ? @"" : @"") mutableCopy];
    if (h != 0) [format appendFormat:@"%d:%0.2d", h, m];
    else        [format appendFormat:@"%d", m];
    [format appendFormat:@":%0.2d", s];
    
    return format;
}

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSUInteger, KxMoviePlayerState) {
    
    KxMoviePlayerStateLoading, //加载中
    KxMoviePlayerStatePlaying,//播放中
    KxMoviePlayerStatePause,//暂停
    KxMoviePlayerStateError,//错误
    KxMoviePlayerStateInterrupted,//播放中
    
    KxMoviePlayerStateStop//停止
    
};


enum {
    
    KxMovieInfoSectionGeneral,
    KxMovieInfoSectionVideo,
    KxMovieInfoSectionAudio,
    KxMovieInfoSectionSubtitles,
    KxMovieInfoSectionMetadata,
    KxMovieInfoSectionCount,
};

enum {
    
    KxMovieInfoGeneralFormat,
    KxMovieInfoGeneralBitrate,
    KxMovieInfoGeneralCount,
};

////////////////////////////////////////////////////////////////////////////////

static NSMutableDictionary * gHistory;

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0


#define NormalHeight   AppWindow.height



@interface MovieController ()
{
    dispatch_queue_t  _dispatchQueue;
    NSString *titleText;
}
@property (nonatomic,retain) KxMovieDecoder *decoder;
@property (nonatomic,retain) NSMutableArray *videoFrames;
@property (nonatomic,retain) NSMutableArray *audioFrames;
@property (nonatomic,retain) NSMutableArray *subtitles;
@property (nonatomic,retain) NSData         *currentAudioFrame;
@property (nonatomic,assign) NSUInteger     currentAudioFramePos;
@property (nonatomic,assign) CGFloat        moviePosition;
@property (nonatomic,assign) BOOL           disableUpdateHUD;
@property (nonatomic,assign) NSTimeInterval tickCorrectionTime;
@property (nonatomic,assign) NSTimeInterval tickCorrectionPosition;
@property (nonatomic,assign) NSUInteger     tickCounter;
@property (nonatomic,assign) BOOL           hiddenHUD;
@property (nonatomic,assign) BOOL           fitMode;
@property (nonatomic,assign) BOOL           infoMode;
@property (nonatomic,assign) BOOL           restoreIdleTimer;
@property (nonatomic,assign) BOOL           interrupted;

@property (nonatomic,retain) KxMovieGLView  *glView;
@property (nonatomic,retain) UIImageView    *imageView;
@property (nonatomic,retain) UIView         *topBar;
@property (nonatomic,retain) UIView         *bottomBar;
@property (nonatomic,retain) UISlider       *progressSlider;
@property (nonatomic,retain) UIView         *movieBackgroundView;
@property (nonatomic,retain) UIButton       *fullScreenbtn;

@property (nonatomic,retain) UIButton        *playBtn;


@property (nonatomic,retain) UIButton        *backButton;
@property (nonatomic,retain) UILabel         *titleView;



@property (nonatomic,retain) UIButton         *doneButton;
@property (nonatomic,retain) UILabel          *progressLabel;
@property (nonatomic,retain) UILabel          *leftLabel;
@property (nonatomic,retain) UIButton         *infoButton;

@property (nonatomic,retain) UIBarButtonItem  *progressItem;
@property (nonatomic,retain) UIBarButtonItem  *druationItem;
@property (nonatomic,retain) UIBarButtonItem  *progressSliderItem;

@property (nonatomic,retain) UILabel          *subtitlesLabel;
@property (nonatomic,retain) UICollectionView *tableView;

@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic,retain) UITapGestureRecognizer  *tapGestureRecognizer;
@property (nonatomic,retain) UITapGestureRecognizer  *doubleTapGestureRecognizer;
@property (nonatomic,retain) UIPanGestureRecognizer  *panGestureRecognizer;

#ifdef DEBUG
@property (nonatomic,retain)UILabel             *messageLabel;
@property (nonatomic,assign)NSTimeInterval      debugStartTime;
@property (nonatomic,assign)NSUInteger          debugAudioStatus;
@property (nonatomic,retain)NSDate              *debugAudioStatusTS;
#endif

@property (nonatomic,assign)CGFloat             bufferedDuration;
@property (nonatomic,assign)CGFloat             minBufferedDuration;
@property (nonatomic,assign)CGFloat             maxBufferedDuration;
@property (nonatomic,assign)BOOL                buffered;
@property (nonatomic,assign )CGRect             defaultFrame;

@property (nonatomic,assign)BOOL                savedIdleTimer;

@property (nonatomic,retain ) NSDictionary       *parameters;
@property (readwrite        ) BOOL               decoding;
@property (readwrite        ) BOOL               playing;
@property (readwrite        ) BOOL               isAnimationing;
@property (readwrite,strong ) KxArtworkFrame     *artworkFrame;
@property (nonatomic,assign ) KxMoviePlayerState state;
@property (nonatomic,assign) BOOL           fullscreen;


@end

@implementation MovieController
+ (void)initialize
{
    if (!gHistory)
        gHistory = [NSMutableDictionary dictionary];
}
+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters title:(NSString*)title
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    [audioManager activateAudioSession];
    return [[MovieController alloc] initWithContentPath: path parameters: parameters title:title];
}
- (id) initWithContentPath: (NSString *) path
                parameters: (NSDictionary *) parameters title:(NSString*)title
{
    NSAssert(path.length > 0, @"empty path");
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        _moviePosition = 0;
        //        self.wantsFullScreenLayout = YES;
        titleText = title;
        _parameters = parameters;
        
        __weak MovieController *weakSelf = self;
        
        KxMovieDecoder *decoder = [[KxMovieDecoder alloc] init];
        
        decoder.interruptCallback = ^BOOL(){
            
            __strong MovieController *strongSelf = weakSelf;
            return strongSelf ? [strongSelf interruptDecoder] : YES;
        };
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSError *error = nil;
            [decoder openFile:path error:&error];
            
            __strong MovieController *strongSelf = weakSelf;
            if (strongSelf) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [strongSelf setMovieDecoder:decoder withError:error];
                });
            }
        });
    }
    return self;
}
- (BOOL)prefersStatusBarHidden { return YES; }
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - dealloc

- (void) dealloc
{
    [self pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_dispatchQueue) {
        // Not needed as of ARC.
        //        dispatch_release(_dispatchQueue);
        _dispatchQueue = NULL;
    }
    LoggerStream(1, @"%@ dealloc", self);
}
#pragma mark - loadView
- (void)loadView
{
    // LoggerStream(1, @"loadView");
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.tintColor = [UIColor blackColor];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    CGFloat width = bounds.size.width;
    
#ifdef DEBUG
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,40,width-40,40)];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textColor = [UIColor redColor];
    _messageLabel.hidden = YES;
    _messageLabel.font = MSGFont(14);
    _messageLabel.numberOfLines = 2;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_movieBackgroundView addSubview:_messageLabel];
#endif
    
    CGFloat topH = 35;
    CGFloat botH = 35;
    
    _topBar    = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, NAV_H)];
    _topBar.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.400];
    _topBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, NormalHeight-botH, width, botH)];
    _bottomBar.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.400];
    _bottomBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    
    _movieBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, NormalHeight)];
    _defaultFrame = _movieBackgroundView.frame;
    _movieBackgroundView.backgroundColor = CRCOLOR_BLACK;
    [self.view addSubview:_movieBackgroundView];
    
    _activityIndicatorView.center = _movieBackgroundView.center;
    
    [_movieBackgroundView addSubview:_topBar];
    [_movieBackgroundView addSubview:_bottomBar];
    [_movieBackgroundView addSubview:_activityIndicatorView];
    
    // top Bar
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(10, 20, 44, 44);
    _backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    [_backButton setImage:WhiteBackImage forState:UIControlStateNormal];
    
    [_backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _titleView = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, self.view.width - 120, 44)];
    _titleView.backgroundColor = CRCOLOR_CLEAR;
    _titleView.textAlignment = NSTextAlignmentCenter;
    _titleView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    _titleView.textColor = CRCOLOR_WHITE;
    _titleView.font = MSGFont(18);
    _titleView.text = titleText;

    [_topBar addSubview:_backButton];
    [_topBar addSubview:_titleView];
    
    // bottom Bar
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + 35, 1, 50, topH)];
    _progressLabel.backgroundColor = [UIColor clearColor];
    _progressLabel.opaque = NO;
    _progressLabel.adjustsFontSizeToFitWidth = NO;
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.text = @"";
    _progressLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    _progressLabel.font = MSGFont(12);
    
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(10 + 35 + 50 + 5 , 0, self.view.width - (10 + 35 + 50 + 5)*2, topH)];
    _progressSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _progressSlider.continuous = false;
    _progressSlider.value = 0;
    
    //    [_progressSlider setThumbImage:[UIImage imageNamed:@"kxmovie.bundle/sliderthumb"]
    //                          forState:UIControlStateNormal];
    
    _leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(width -(10 + 35 + 50 + 5), 0, 50, topH)];
    _leftLabel.backgroundColor = [UIColor clearColor];
    _leftLabel.opaque = NO;
    _leftLabel.adjustsFontSizeToFitWidth = NO;
    _leftLabel.textAlignment = NSTextAlignmentCenter;
    _leftLabel.textColor = [UIColor whiteColor];
    _leftLabel.text = @"";
    _leftLabel.font = MSGFont(12);
    _leftLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    
    // bottom hud
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _playBtn.frame = CGRectMake(15,0 ,35 , 35);
    [_playBtn addTarget:self action:@selector(playDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setImage:[UIImage imageNamed:@"moviePause"] forState:UIControlStateNormal];
    
    _progressItem = [[UIBarButtonItem alloc] initWithCustomView:_progressLabel];
    _progressSliderItem = [[UIBarButtonItem alloc] initWithCustomView:_progressSlider];
    _druationItem = [[UIBarButtonItem alloc] initWithCustomView:_leftLabel];
    
//    _fullScreenbtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _fullScreenbtn.frame = CGRectMake(self.view.width - 10 - 35, 0, 35, 35);
//    _fullScreenbtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    [_fullScreenbtn addTarget:self action:@selector(fullscreenClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [_fullScreenbtn setImage:[[UIImage imageNamed:@"movieFullscreen"] imageWithTintColor:CRCOLOR_WHITE] forState:UIControlStateNormal];
    
    [_bottomBar addSubview:_playBtn];
    [_bottomBar addSubview:_progressLabel];
    [_bottomBar addSubview:_progressSlider];
    [_bottomBar addSubview:_leftLabel];
    
//    [_bottomBar addSubview:_fullScreenbtn];
    
    if (_decoder) {
        
        [self setupPresentView];
        
    } else {
        
        _progressLabel.hidden = YES;
        _progressSlider.hidden = YES;
        _leftLabel.hidden = YES;
        _infoButton.hidden = YES;
    }
    self.automaticallyAdjustsScrollViewInsets = false;
    self.navigationController.navigationBar.hidden = true;
}
#pragma mark - updateBottomBar

- (void) updateBottomBar
{
    UIImage *playImage = self.playing ? [UIImage imageNamed:@"moviePause"]  : [UIImage imageNamed:@"moviePlay"] ;
    [_playBtn setImage:playImage forState:UIControlStateNormal];
    
}
#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (self.playing) {
        
        [self pause];
        [self freeBufferedFrames];
        
        if (_maxBufferedDuration > 0) {
            
            _minBufferedDuration = _maxBufferedDuration = 0;
            [self play];
            
            LoggerStream(0, @"didReceiveMemoryWarning, disable buffering and continue playing");
            
        } else {
            
            // force ffmpeg to free allocated memory
            [_decoder closeFile];
            [_decoder openFile:nil error:nil];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                        message:NSLocalizedString(@"Out of memory", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                              otherButtonTitles:nil] show];
        }
        
    } else {
        
        [self freeBufferedFrames];
        [_decoder closeFile];
        [_decoder openFile:nil error:nil];
    }
}
#pragma mark - viewDidAppear

- (void) viewDidAppear:(BOOL)animated
{
    // LoggerStream(1, @"viewDidAppear");
    
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self hiddenNavBar:true];
    [self hiddenHUD:false];
    _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
    
    if (_decoder&&_state != KxMoviePlayerStateStop) {
        
        [self restorePlay];
        
    } else {
        if (_state != KxMoviePlayerStateStop) {
            [_activityIndicatorView startAnimating];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
}
#pragma mark - viewWillDisappear

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIApplication sharedApplication].statusBarHidden = false;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenHUDAnimation) object:nil];
    [self showNavBar:false];
    [super viewWillDisappear:animated];
    _hiddenHUD = true;
    [_activityIndicatorView stopAnimating];
    
    if (_decoder) {
        [self pause];
        if (_moviePosition == 0 || _decoder.isEOF)
            [gHistory removeObjectForKey:_decoder.path];
        else if (!_decoder.isNetwork)
            [gHistory setValue:[NSNumber numberWithFloat:_moviePosition]
                        forKey:_decoder.path];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
    
    [_activityIndicatorView stopAnimating];
    _buffered = NO;
    LoggerStream(1, @"viewWillDisappear %@", self);
}

#pragma mark - roatate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = AppWindow.bounds;
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationUnknown:
        {
            frame = AppWindow.bounds;
        }
            break;
        case UIInterfaceOrientationPortrait:
        {
            frame = CGRectMake(0, 0, MIN(CGRectGetHeight(AppWindow.bounds),CGRectGetWidth(AppWindow.bounds)), MAX(CGRectGetHeight(AppWindow.bounds),CGRectGetWidth(AppWindow.bounds)));
            if (!_fullscreen) {
                return;
            }
        }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            frame = CGRectMake(0, 0, MIN(CGRectGetHeight(AppWindow.bounds),CGRectGetWidth(AppWindow.bounds)), MAX(CGRectGetHeight(AppWindow.bounds),CGRectGetWidth(AppWindow.bounds)));
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        {
            frame = CGRectMake(0, 0, MAX(CGRectGetHeight(AppWindow.bounds),CGRectGetWidth(AppWindow.bounds)), MIN(CGRectGetHeight(AppWindow.bounds),CGRectGetWidth(AppWindow.bounds)));
            
            
        }
            break;
        case UIInterfaceOrientationLandscapeRight:
        {
            frame = CGRectMake(0, 0, MAX(CGRectGetHeight(AppWindow.bounds),CGRectGetWidth(AppWindow.bounds)), MIN(CGRectGetHeight(AppWindow.bounds),CGRectGetWidth(AppWindow.bounds)));
        }
            break;
        default:
            break;
    }
    [UIView animateWithDuration:duration animations:^{
        _movieBackgroundView.frame = frame;
    }];
}

- (void) applicationWillResignActive: (NSNotification *)notification
{
    [self hiddenHUD:true];
    [self pause];
    
    LoggerStream(1, @"applicationWillResignActive");
}

#pragma mark - gesture recognizer

- (void) handleTap: (UITapGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (sender == _tapGestureRecognizer) {
            [self hiddenHUD:!_hiddenHUD];
            
        } else if (sender == _doubleTapGestureRecognizer) {
            
            UIView *frameView = [self frameView];
            
            if (frameView.contentMode == UIViewContentModeScaleAspectFit)
                frameView.contentMode = UIViewContentModeScaleAspectFill;
            else
                frameView.contentMode = UIViewContentModeScaleAspectFit;
            
        }
    }
}

- (void) handlePan: (UIPanGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        const CGPoint vt = [sender velocityInView:self.view];
        const CGPoint pt = [sender translationInView:self.view];
        const CGFloat sp = MAX(0.1, log10(fabs(vt.x)) - 1.0);
        const CGFloat sc = fabs(pt.x) * 0.33 * sp;
        if (sc > 10) {
            
            const CGFloat ff = pt.x > 0 ? 1.0 : -1.0;
            [self setMoviePosition: _moviePosition + ff * MIN(sc, 600.0)];
        }
        //LoggerStream(2, @"pan %.2f %.2f %.2f sec", pt.x, vt.x, sc);
    }
}

#pragma mark - public

-(void) play
{
    if (self.state == KxMoviePlayerStatePlaying)
        return;
    if (!_decoder.validVideo &&
        !_decoder.validAudio) {
        return;
    }
    if (_interrupted)
        return;
    
    self.playing = YES;
    self.state = KxMoviePlayerStatePlaying;
    _interrupted = NO;
    _disableUpdateHUD = NO;
    _tickCorrectionTime = 0;
    _tickCounter = 0;
    
#ifdef DEBUG
    _debugStartTime = -1;
#endif
    
    [self asyncDecodeFrames];
    [self updatePlayButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });
    
    if (_decoder.validAudio)
        [self enableAudio:YES];
    
    LoggerStream(1, @"play movie");
}

- (void) pause
{
    if (!self.playing)
        return;
    
    self.playing = NO;
    self.state = KxMoviePlayerStatePause;
    [self enableAudio:NO];
    [self updatePlayButton];
    LoggerStream(1, @"pause movie");
}

- (void) setMoviePosition: (CGFloat) position
{
    BOOL playMode = self.playing;
    
    self.playing = NO;
    self.state = KxMoviePlayerStateLoading;
    _disableUpdateHUD = YES;
    [self enableAudio:NO];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self updatePosition:position playMode:playMode];
    });
}

#pragma mark - actions

- (void) doneDidTouch: (id) sender
{
    if (self.presentingViewController || !self.navigationController)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (void) playDidTouch: (id) sender
{
    if (self.playing)
        [self pause];
    else
        [self play];
}

- (void) forwardDidTouch: (id) sender
{
    [self setMoviePosition: _moviePosition + 10];
}

- (void) rewindDidTouch: (id) sender
{
    [self setMoviePosition: _moviePosition - 10];
}

- (void) progressDidChange: (id) sender
{
    NSAssert(_decoder.duration != MAXFLOAT, @"bugcheck");
    UISlider *slider = sender;
    [self setMoviePosition:slider.value * _decoder.duration];
}

-(void)goBack:(id)sender
{
    if (_fullscreen) {
        CRWeekRef(self);
        [self setFullscreen:false complete:^(BOOL finished) {
            [__self.navigationController dismissViewControllerAnimated:true completion:nil];
        }];
    }
}

#pragma mark - private

- (void) setMovieDecoder: (KxMovieDecoder *) decoder
               withError: (NSError *) error
{
    LoggerStream(2, @"setMovieDecoder");
    
    if (!error && decoder) {
        
        _decoder        = decoder;
        _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
        _videoFrames    = [NSMutableArray array];
        _audioFrames    = [NSMutableArray array];
        
        if (_decoder.subtitleStreamsCount) {
            _subtitles = [NSMutableArray array];
        }
        
        if (_decoder.isNetwork) {
            
            _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
            
        } else {
            
            _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
        }
        
        if (!_decoder.validVideo)
            _minBufferedDuration *= 10.0; // increase for audio
        
        // allow to tweak some parameters at runtime
        if (_parameters.count) {
            
            id val;
            
            val = [_parameters valueForKey: MovieParameterMinBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _minBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: MovieParameterMaxBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _maxBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: MovieParameterDisableDeinterlacing];
            if ([val isKindOfClass:[NSNumber class]])
                _decoder.disableDeinterlacing = [val boolValue];
            
            if (_maxBufferedDuration < _minBufferedDuration)
                _maxBufferedDuration = _minBufferedDuration * 2;
        }
        
        LoggerStream(2, @"buffered limit: %.1f - %.1f", _minBufferedDuration, _maxBufferedDuration);
        
        if (self.isViewLoaded) {
            
            [self setupPresentView];
            
            _progressLabel.hidden   = NO;
            _progressSlider.hidden  = NO;
            _leftLabel.hidden       = NO;
            _infoButton.hidden      = NO;
            
            if (_activityIndicatorView.isAnimating) {
                
                [_activityIndicatorView stopAnimating];
                // if (self.view.window)
                [self restorePlay];
            }
        }
        
    } else {
        
        if (self.isViewLoaded && self.view.window) {
            
            [_activityIndicatorView stopAnimating];
            if (!_interrupted)
                [self handleDecoderMovieError: error];
        }
    }
}

- (void) restorePlay
{
    NSNumber *n = [gHistory valueForKey:_decoder.path];
    if (n)
        [self updatePosition:n.floatValue playMode:YES];
    else
        [self play];
}

-(void)setFullscreen:(BOOL)fullscreen complete:(void(^)(BOOL finished))complete
{
    _fullscreen = fullscreen;
    if (fullscreen) {
        [self.navigationController.navigationItem setHidesBackButton:true];
        [_fullScreenbtn setImage:[[UIImage imageNamed:@"movieEndFullscreen"] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationLandscapeRight;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
            CGRect frame = [self.view convertRect:_movieBackgroundView.frame toView:AppWindow];
            _movieBackgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            if (IS_BEFORE_iOS8) {
                _movieBackgroundView.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
            }
        }
    }else{
        
        [_fullScreenbtn setImage:[[UIImage imageNamed:@"movieFullscreen"] imageWithTintColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        CGRect frame = [AppWindow convertRect:_movieBackgroundView.frame toView:self.view];
        _movieBackgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        if (IS_BEFORE_iOS8) {
            _movieBackgroundView.frame = CGRectMake(0, 0, frame.size.height, frame.size.width);
        }
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
            [UIView animateWithDuration:.30 animations:^{
                _movieBackgroundView.frame = _defaultFrame;
            } completion:^(BOOL finished) {
                    complete(finished);
            }];
            
        }
    }
}
- (void) setupPresentView
{
    
    if (_decoder.validVideo) {
        _glView = [[KxMovieGLView alloc] initWithFrame:_movieBackgroundView.bounds decoder:_decoder];
        _glView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    if (!_glView) {
        
        LoggerVideo(0, @"fallback to use RGB video frame and UIKit");
        [_decoder setupVideoFrameFormat:KxVideoFrameFormatRGB];
        _imageView = [[UIImageView alloc] initWithFrame:_movieBackgroundView.bounds];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    
    UIView *frameView = [self frameView];
    frameView.contentMode = UIViewContentModeScaleAspectFit;
    frameView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    [_movieBackgroundView insertSubview:frameView atIndex:0];
    
    if (_decoder.validVideo) {
        
        [self setupUserInteraction];
        
    } else {
        
        _imageView.image = [UIImage imageNamed:@"kxmovie.bundle/music_icon.png"];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_decoder.duration == MAXFLOAT) {
        
        _leftLabel.text = @"\u221E"; // infinity
        _leftLabel.font = MSGFont(14);
        
        CGRect frame;
        
        frame = _leftLabel.frame;
        frame.origin.x += 40;
        frame.size.width -= 40;
        _leftLabel.frame = frame;
        
        frame =_progressSlider.frame;
        frame.size.width += 40;
        _progressSlider.frame = frame;
        
    } else {
        
        [_progressSlider addTarget:self
                            action:@selector(progressDidChange:)
                  forControlEvents:UIControlEventValueChanged];
    }
    
    if (_decoder.subtitleStreamsCount) {
        
        CGSize size = self.view.bounds.size;
        
        _subtitlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, size.height, size.width, 0)];
        _subtitlesLabel.numberOfLines = 0;
        _subtitlesLabel.backgroundColor = [UIColor clearColor];
        _subtitlesLabel.opaque = NO;
        _subtitlesLabel.adjustsFontSizeToFitWidth = NO;
        _subtitlesLabel.textAlignment = NSTextAlignmentCenter;
        _subtitlesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _subtitlesLabel.textColor = [UIColor whiteColor];
        _subtitlesLabel.font = MSGFont(16);
        _subtitlesLabel.hidden = YES;
        
        [_movieBackgroundView addSubview:_subtitlesLabel];
    }
    [self setFullscreen:true complete:nil];
}
- (void) setupUserInteraction
{
    UIView * view = [self frameView];
    view.userInteractionEnabled = YES;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    
    [_tapGestureRecognizer requireGestureRecognizerToFail: _doubleTapGestureRecognizer];
    
    [view addGestureRecognizer:_doubleTapGestureRecognizer];
    [view addGestureRecognizer:_tapGestureRecognizer];
    
    //    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    //    _panGestureRecognizer.enabled = NO;
    //
    //    [view addGestureRecognizer:_panGestureRecognizer];
}

- (UIView *) frameView
{
    return _glView ? _glView : _imageView;
}

- (void) audioCallbackFillData: (float *) outData
                     numFrames: (UInt32) numFrames
                   numChannels: (UInt32) numChannels
{
    //fillSignalF(outData,numFrames,numChannels);
    //return;
    
    if (_buffered) {
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }
    
    @autoreleasepool {
        
        while (numFrames > 0) {
            
            if (!_currentAudioFrame) {
                
                @synchronized(_audioFrames) {
                    
                    NSUInteger count = _audioFrames.count;
                    
                    if (count > 0) {
                        
                        KxAudioFrame *frame = _audioFrames[0];
                        
#ifdef DUMP_AUDIO_DATA
                        LoggerAudio(2, @"Audio frame position: %f", frame.position);
#endif
                        if (_decoder.validVideo) {
                            
                            const CGFloat delta = _moviePosition - frame.position;
                            
                            if (delta < -0.1) {
                                
                                memset(outData, 0, numFrames * numChannels * sizeof(float));
#ifdef DEBUG
                                LoggerStream(0, @"desync audio (outrun) wait %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 1;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                break; // silence and exit
                            }
                            
                            [_audioFrames removeObjectAtIndex:0];
                            
                            if (delta > 0.1 && count > 1) {
                                
#ifdef DEBUG
                                LoggerStream(0, @"desync audio (lags) skip %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 2;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                continue;
                            }
                            
                        } else {
                            
                            [_audioFrames removeObjectAtIndex:0];
                            _moviePosition = frame.position;
                            _bufferedDuration -= frame.duration;
                        }
                        
                        _currentAudioFramePos = 0;
                        _currentAudioFrame = frame.samples;
                    }
                }
            }
            
            if (_currentAudioFrame) {
                
                const void *bytes = (Byte *)_currentAudioFrame.bytes + _currentAudioFramePos;
                const NSUInteger bytesLeft = (_currentAudioFrame.length - _currentAudioFramePos);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    _currentAudioFramePos += bytesToCopy;
                else
                    _currentAudioFrame = nil;
                
            } else {
                
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                //LoggerStream(1, @"silence audio");
#ifdef DEBUG
                _debugAudioStatus = 3;
                _debugAudioStatusTS = [NSDate date];
#endif
                break;
            }
        }
    }
}

- (void) enableAudio: (BOOL) on
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    
    if (on && _decoder.validAudio) {
        
        audioManager.outputBlock = ^(float *outData, UInt32 numFrames, UInt32 numChannels) {
            
            [self audioCallbackFillData: outData numFrames:numFrames numChannels:numChannels];
        };
        
        [audioManager play];
        
        LoggerAudio(2, @"audio device smr: %d fmt: %d chn: %d",
                    (int)audioManager.samplingRate,
                    (int)audioManager.numBytesPerSample,
                    (int)audioManager.numOutputChannels);
        
    } else {
        
        [audioManager pause];
        audioManager.outputBlock = nil;
    }
}

- (BOOL) addFrames: (NSArray *)frames
{
    if (_decoder.validVideo) {
        
        @synchronized(_videoFrames) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeVideo) {
                    [_videoFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
        }
    }
    
    if (_decoder.validAudio) {
        
        @synchronized(_audioFrames) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeAudio) {
                    [_audioFrames addObject:frame];
                    if (!_decoder.validVideo)
                        _bufferedDuration += frame.duration;
                }
        }
        
        if (!_decoder.validVideo) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeArtwork)
                    self.artworkFrame = (KxArtworkFrame *)frame;
        }
    }
    
    if (_decoder.validSubtitles) {
        
        @synchronized(_subtitles) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeSubtitle) {
                    [_subtitles addObject:frame];
                }
        }
    }
    
    return self.playing && _bufferedDuration < _maxBufferedDuration;
}

- (BOOL) decodeFrames
{
    //NSAssert(dispatch_get_current_queue() == _dispatchQueue, @"bugcheck");
    
    NSArray *frames = nil;
    
    if (_decoder.validVideo ||
        _decoder.validAudio) {
        
        frames = [_decoder decodeFrames:0];
    }
    
    if (frames.count) {
        return [self addFrames: frames];
    }
    return NO;
}

- (void) asyncDecodeFrames
{
    if (self.decoding)
        return;
    
    __weak MovieController *weakSelf = self;
    __weak KxMovieDecoder *weakDecoder = _decoder;
    
    const CGFloat duration = _decoder.isNetwork ? .0f : 0.1f;
    
    self.decoding = YES;
    dispatch_async(_dispatchQueue, ^{
        
        {
            __strong MovieController *strongSelf = weakSelf;
            if (!strongSelf.playing)
                return;
        }
        
        BOOL good = YES;
        while (good) {
            
            good = NO;
            
            @autoreleasepool {
                
                __strong KxMovieDecoder *decoder = weakDecoder;
                
                if (decoder && (decoder.validVideo || decoder.validAudio)) {
                    
                    NSArray *frames = [decoder decodeFrames:duration];
                    if (frames.count) {
                        
                        __strong MovieController *strongSelf = weakSelf;
                        if (strongSelf)
                            good = [strongSelf addFrames:frames];
                    }
                }
            }
        }
        
        {
            __strong MovieController *strongSelf = weakSelf;
            if (strongSelf) strongSelf.decoding = NO;
        }
    });
}

- (void) tick
{
    if (_buffered && ((_bufferedDuration > _minBufferedDuration) || _decoder.isEOF)) {
        
        _tickCorrectionTime = 0;
        _buffered = NO;
        [_activityIndicatorView stopAnimating];
    }
    
    CGFloat interval = 0;
    if (!_buffered)
        interval = [self presentFrame];
    
    if (self.playing) {
        
        const NSUInteger leftFrames =
        (_decoder.validVideo ? _videoFrames.count : 0);
        if (0 == leftFrames) {
            
            if (_decoder.isEOF&&_videoFrames.count == 0) {
                [self pause];
                [self freeBufferedFrames];
                [self updatePosition:0.0 playMode:false];
                self.state = KxMoviePlayerStateStop;
                [self updateHUD];
                return;
            }
            
            if (_minBufferedDuration > 0 && !_buffered) {
                
                _buffered = YES;
                [_activityIndicatorView startAnimating];
            }
        }
        
        if (!leftFrames ||
            !(_bufferedDuration > _minBufferedDuration)) {
            
            [self asyncDecodeFrames];
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self tick];
        });
    }
    
    if ((_tickCounter++ % 3) == 0) {
        [self updateHUD];
    }
}

- (CGFloat) tickCorrection
{
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime) {
        
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    //if ((_tickCounter % 200) == 0)
    //    LoggerStream(1, @"tick correction %.4f", correction);
    
    if (correction > 1.f || correction < -1.f) {
        
        LoggerStream(1, @"tick correction reset %.2f", correction);
        correction = 0;
        _tickCorrectionTime = 0;
    }
    
    return correction;
}

- (CGFloat) presentFrame
{
    CGFloat interval = 0;
    
    if (_decoder.validVideo) {
        
        KxVideoFrame *frame;
        
        @synchronized(_videoFrames) {
            
            if (_videoFrames.count > 0) {
                
                frame = _videoFrames[0];
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
        }
        
        if (frame)
            interval = [self presentVideoFrame:frame];
        
    } else if (_decoder.validAudio) {
        
        //interval = _bufferedDuration * 0.5;
        
        if (self.artworkFrame) {
            
            _imageView.image = [self.artworkFrame asImage];
            self.artworkFrame = nil;
        }
    }
    
    if (_decoder.validSubtitles)
        [self presentSubtitles];
    
#ifdef DEBUG
    if (self.playing && _debugStartTime < 0)
        _debugStartTime = [NSDate timeIntervalSinceReferenceDate] - _moviePosition;
#endif
    
    return interval;
}

- (CGFloat) presentVideoFrame: (KxVideoFrame *) frame
{
    if (_glView) {
        
        [_glView render:frame];
        
    } else {
        
        KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB *)frame;
        _imageView.image = [rgbFrame asImage];
    }
    
    _moviePosition = frame.position;
    
    return frame.duration;
}

- (void) presentSubtitles
{
    NSArray *actual, *outdated;
    
    if ([self subtitleForPosition:_moviePosition
                           actual:&actual
                         outdated:&outdated]){
        
        if (outdated.count) {
            @synchronized(_subtitles) {
                [_subtitles removeObjectsInArray:outdated];
            }
        }
        
        if (actual.count) {
            
            NSMutableString *ms = [NSMutableString string];
            for (KxSubtitleFrame *subtitle in actual.reverseObjectEnumerator) {
                if (ms.length) [ms appendString:@"\n"];
                [ms appendString:subtitle.text];
            }
            
            if (![_subtitlesLabel.text isEqualToString:ms]) {
                
                CGSize viewSize = self.view.bounds.size;
                CGSize size = [ms sizeWithFont:_subtitlesLabel.font
                             constrainedToSize:CGSizeMake(viewSize.width, viewSize.height * 0.5)
                                 lineBreakMode:NSLineBreakByTruncatingTail];
                _subtitlesLabel.text = ms;
                _subtitlesLabel.frame = CGRectMake(0, viewSize.height - size.height - 10,
                                                   viewSize.width, size.height);
                _subtitlesLabel.hidden = NO;
            }
            
        } else {
            
            _subtitlesLabel.text = nil;
            _subtitlesLabel.hidden = YES;
        }
    }
}

- (BOOL) subtitleForPosition: (CGFloat) position
                      actual: (NSArray **) pActual
                    outdated: (NSArray **) pOutdated
{
    if (!_subtitles.count)
        return NO;
    
    NSMutableArray *actual = nil;
    NSMutableArray *outdated = nil;
    
    for (KxSubtitleFrame *subtitle in _subtitles) {
        
        if (position < subtitle.position) {
            
            break; // assume what subtitles sorted by position
            
        } else if (position >= (subtitle.position + subtitle.duration)) {
            
            if (pOutdated) {
                if (!outdated)
                    outdated = [NSMutableArray array];
                [outdated addObject:subtitle];
            }
            
        } else {
            
            if (pActual) {
                if (!actual)
                    actual = [NSMutableArray array];
                [actual addObject:subtitle];
            }
        }
    }
    
    if (pActual) *pActual = actual;
    if (pOutdated) *pOutdated = outdated;
    
    return actual.count || outdated.count;
}

- (void) updatePlayButton
{
    [self updateBottomBar];
}

- (void) updateHUD
{
    if (_disableUpdateHUD)
        return;
    
    const CGFloat duration = _decoder.duration;
    const CGFloat position = _moviePosition -_decoder.startTime;
    
    if (_progressSlider.state == UIControlStateNormal)
        _progressSlider.value = position / duration;
    _progressLabel.text = formatTimeInterval(position, NO);
    
    if (_decoder.duration != MAXFLOAT)
        _leftLabel.text = formatTimeInterval(duration - position, YES);
    
#ifdef DEBUG
    const NSTimeInterval timeSinceStart = [NSDate timeIntervalSinceReferenceDate] - _debugStartTime;
    NSString *subinfo = _decoder.validSubtitles ? [NSString stringWithFormat: @" %d",_subtitles.count] : @"";
    
    NSString *audioStatus;
    
    if (_debugAudioStatus) {
        
        if (NSOrderedAscending == [_debugAudioStatusTS compare: [NSDate dateWithTimeIntervalSinceNow:-0.5]]) {
            _debugAudioStatus = 0;
        }
    }
    
    if      (_debugAudioStatus == 1) audioStatus = @"\n(audio outrun)";
    else if (_debugAudioStatus == 2) audioStatus = @"\n(audio lags)";
    else if (_debugAudioStatus == 3) audioStatus = @"\n(audio silence)";
    else audioStatus = @"";
    
    _messageLabel.text = [NSString stringWithFormat:@"%d %d%@ %c - %@ %@ %@\n%@",
                          _videoFrames.count,
                          _audioFrames.count,
                          subinfo,
                          self.decoding ? 'D' : ' ',
                          formatTimeInterval(timeSinceStart, NO),
                          //timeSinceStart > _moviePosition + 0.5 ? @" (lags)" : @"",
                          _decoder.isEOF ? @"- END" : @"",
                          audioStatus,
                          _buffered ? [NSString stringWithFormat:@"buffering %.1f%%", _bufferedDuration / _minBufferedDuration * 100] : @""];
#endif
}

- (void) hiddenHUD: (BOOL) hidden
{
    _panGestureRecognizer.enabled = !_hiddenHUD;
    
    if (!hidden) {
        //隐藏状态 先显示
        CRWeekRef(self);
        [[UIApplication sharedApplication] setStatusBarHidden:false];
        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             CGFloat alpha = 1;
                             _topBar.alpha = alpha;
                             _bottomBar.alpha = alpha;
                         }
                         completion:^(BOOL finished) {
                             _hiddenHUD = false;
                             //显示之后3秒自动隐藏
                             [NSObject cancelPreviousPerformRequestsWithTarget:__self selector:@selector(hiddenHUDAnimation) object:nil];
                             [__self performSelector:@selector(hiddenHUDAnimation) withObject:nil afterDelay:3];
                         }];
        
    }else{
        [self hiddenHUDAnimation];
    }
}
-(void)hiddenHUDAnimation{
    CRWeekRef(self);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:__self selector:@selector(hiddenHUDAnimation) object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:true];
    [[UIApplication sharedApplication] setIdleTimerDisabled:_hiddenHUD];
    [UIView animateWithDuration:0.2
                     animations:^{
                         CGFloat alpha = 0;
                         _topBar.alpha = alpha;
                         _bottomBar.alpha = alpha;
                     }
                     completion:^(BOOL finished) {
                         _hiddenHUD = true;
                     }];
    
}
- (void) fullscreenMode: (BOOL) on
{
    _fullscreen = on;
}

- (void) setMoviePositionFromDecoder
{
    _moviePosition = _decoder.position;
}

- (void) setDecoderPosition: (CGFloat) position
{
    _decoder.position = position;
}

- (void) enableUpdateHUD
{
    _disableUpdateHUD = NO;
}

- (void) updatePosition: (CGFloat) position
               playMode: (BOOL) playMode
{
    [self freeBufferedFrames];
    
    position = MIN(_decoder.duration - 1, MAX(0, position));
    
    __weak MovieController *weakSelf = self;
    
    dispatch_async(_dispatchQueue, ^{
        
        if (playMode) {
            
            {
                __strong MovieController *strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf setDecoderPosition: position];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong MovieController *strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf play];
                }
            });
            
        } else {
            
            {
                __strong MovieController *strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf setDecoderPosition: position];
                [strongSelf decodeFrames];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong MovieController *strongSelf = weakSelf;
                if (strongSelf) {
                    
                    [strongSelf enableUpdateHUD];
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf presentFrame];
                    [strongSelf updateHUD];
                }
            });
        }
    });
}

- (void) freeBufferedFrames
{
    @synchronized(_videoFrames) {
        [_videoFrames removeAllObjects];
    }
    
    @synchronized(_audioFrames) {
        
        [_audioFrames removeAllObjects];
        _currentAudioFrame = nil;
    }
    
    if (_subtitles) {
        @synchronized(_subtitles) {
            [_subtitles removeAllObjects];
        }
    }
    
    _bufferedDuration = 0;
}
- (void) handleDecoderMovieError: (NSError *) error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (BOOL) interruptDecoder
{
    if (!_decoder)
        return NO;
    return _interrupted;
}
-(void)showNavBar:(BOOL)animated;
{
    self.navigationController.navigationBar.hidden = false;
}
-(void)hiddenNavBar:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = true;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
