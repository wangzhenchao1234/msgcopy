//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQAudioMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"
#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "AmrPlayer.h"

@interface JSQAudioMediaItem ()
{
    AmrPlayer *player;
    BOOL _isPlaying;
}
@property (strong, nonatomic) UIView *cachedAudioImageView;
@property (nonatomic,assign) NSInteger timeLength;
@property (nonatomic,retain) UIImageView *animationImageView;
@end


@implementation JSQAudioMediaItem

#pragma mark - Initialization

- (instancetype)initWithURL:(NSURL *)URL length:(NSInteger)timeLength isReadyToPlay:(BOOL)isReadyToPlay
{
    self = [super init];
    if (self) {
        _fileURL = [URL copy];
        _isReadyToPlay = isReadyToPlay;
        _cachedAudioImageView = nil;
        _timeLength = timeLength;
    }
    return self;
}

- (void)dealloc
{
    _fileURL = nil;
    _cachedAudioImageView = nil;
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedAudioImageView = nil;
}

#pragma mark - Setters

- (void)setFileURL:(NSURL *)fileURL
{
    _fileURL = [fileURL copy];
    _cachedAudioImageView = nil;
}
-(void)setTimeLength:(NSInteger)timeLength
{
    _timeLength = timeLength;
    _cachedAudioImageView = nil;
}
- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
{
    _isReadyToPlay = isReadyToPlay;
    _cachedAudioImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedAudioImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (UIView *)mediaView
{
    if (self.fileURL == nil || !self.isReadyToPlay) {
        return nil;
    }
    
    NSArray *voiceBlackImages = @[[UIImage jsq_bubbleImageFromBundleWithName:@"voice_receive_icon_1@2x"],[UIImage jsq_bubbleImageFromBundleWithName:@"voice_receive_icon_2@2x"],[UIImage jsq_bubbleImageFromBundleWithName:@"voice_receive_icon_3@2x"]];
    NSArray *voiceWhiteImages = @[[UIImage jsq_bubbleImageFromBundleWithName:@"voice_receive_icon_white_1@2x"],[UIImage jsq_bubbleImageFromBundleWithName:@"voice_receive_icon_white_2@2x"],[UIImage jsq_bubbleImageFromBundleWithName:@"voice_receive_icon_white_3@2x"]];
    
    if (self.cachedAudioImageView == nil) {
        
        self.cachedAudioImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self mediaViewDisplaySize].width, [self mediaViewDisplaySize].height)];
        CGSize size = CGSizeMake(44, 44);
        UILabel *time = [[UILabel alloc] init];
        time.backgroundColor = CRCOLOR_CLEAR;
        if (self.appliesMediaViewMaskAsOutgoing) {
            _animationImageView =[[UIImageView alloc] initWithImage:[[UIImage jsq_bubbleImageFromBundleWithName:@"voice_receive_icon_white_nor@2x"] jsq_imageMaskedWithColor:CRCOLOR_WHITE]];
            _animationImageView.animationImages = voiceWhiteImages;
            _animationImageView.frame = CGRectMake([self mediaViewDisplaySize].width - 54, 0.0f, size.width, size.height);
            self.cachedAudioImageView.backgroundColor = [UIColor jsq_messageBubbleBlueColor];
            time.frame = CGRectMake(_animationImageView.x - 10, 0, 44, 44);
            time.textColor = CRCOLOR_WHITE;
        }else{
            _animationImageView =[[UIImageView alloc] initWithImage:[[UIImage jsq_bubbleImageFromBundleWithName:@"voice_receive_icon_nor@2x"] jsq_imageMaskedWithColor:CRCOLOR_BLACK]];
            _animationImageView.animationImages = voiceBlackImages;
            _animationImageView.frame = CGRectMake(10.0f, 0.0f, size.width, size.height);
            time.frame = CGRectMake(_animationImageView.x + _animationImageView.width + 10, 0, 44, 44);
            time.textColor = CRCOLOR_BLACK;
            self.cachedAudioImageView.backgroundColor = [UIColor jsq_messageBubbleLightGrayColor];

        }
        _animationImageView.animationDuration = 1.20f;
        _animationImageView.contentMode = UIViewContentModeCenter;
        _animationImageView.clipsToBounds = YES;
        time.text = CRString(@"%d\"",self.timeLength);
        time.font = MSGFont(15);
        [self.cachedAudioImageView addSubview:_animationImageView];
        [self.cachedAudioImageView addSubview:time];

        self.cachedAudioImageView.clipsToBounds = true;
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:self.cachedAudioImageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
    }
    return self.cachedAudioImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    JSQAudioMediaItem *audioItem = (JSQAudioMediaItem *)object;
    
    return [self.fileURL isEqual:audioItem.fileURL]
            && self.isReadyToPlay == audioItem.isReadyToPlay && self.timeLength == audioItem.timeLength;
}

- (NSUInteger)hash
{
    return super.hash ^ self.fileURL.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: fileURL=%@, isReadyToPlay=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.fileURL, @(self.isReadyToPlay), @(self.appliesMediaViewMaskAsOutgoing)];
}
- (CGSize)mediaViewDisplaySize
{
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//        return CGSizeMake(315.0f, 225.0f);
//    }
    
    return CGSizeMake(100, 44);
}
#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
        _timeLength = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(timeLength))] integerValue];
        _isReadyToPlay = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isReadyToPlay))];
        _animationImageView = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(animationImageView))];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
    [aCoder encodeObject:@(self.timeLength) forKey:NSStringFromSelector(@selector(timeLength))];
    [aCoder encodeBool:self.isReadyToPlay forKey:NSStringFromSelector(@selector(isReadyToPlay))];
    [aCoder encodeObject:self.animationImageView forKey:NSStringFromSelector(@selector(animationImageView))];

}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    JSQAudioMediaItem *copy = [[[self class] allocWithZone:zone] initWithURL:self.fileURL
                                                                      length:self.timeLength isReadyToPlay:self.isReadyToPlay];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}
-(void)play
{
    if (_isPlaying) {
        [self stop];
        _isPlaying = false;
    }
    [_animationImageView startAnimating];
    if (!player) {
        player = [[AmrPlayer alloc] init];
    }
    _isPlaying = true;
    [player playAmrWithUrl:_fileURL.absoluteString complet:^(BOOL success) {
        _isPlaying = false;
        if (!success) {
            [CustomToast showMessageOnWindow:@"播放失败"];
        }
        [_animationImageView stopAnimating];
    }];
        
}
-(void)stop
{
    if (_isPlaying) {
        [player StopQueue];
    }
}
-(BOOL)isPlaying{
    return _isPlaying;
}
@end
