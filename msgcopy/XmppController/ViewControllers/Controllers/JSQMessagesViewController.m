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

#import "JSQMessagesViewController.h"

#import "JSQMessagesCollectionViewFlowLayoutInvalidationContext.h"

#import "JSQMessageData.h"
#import "JSQMessageBubbleImageDataSource.h"
#import "JSQMessageAvatarImageDataSource.h"

#import "JSQMessagesCollectionViewCellIncoming.h"
#import "JSQMessagesCollectionViewCellOutgoing.h"

#import "JSQMessagesTypingIndicatorFooterView.h"
#import "JSQMessagesLoadEarlierHeaderView.h"

#import "JSQMessagesToolbarContentView.h"
#import "JSQMessagesInputToolbar.h"
#import "JSQMessagesComposerTextView.h"

#import "JSQMessagesTimestampFormatter.h"

#import "NSString+JSQMessages.h"
#import "UIColor+JSQMessages.h"
#import "UIDevice+JSQMessages.h"
#import "NSBundle+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "TYAttributedLabel.h"
#import "TYImageStorage.h"
#import "TYTextStorage.h"
#import "RegexKitLite.h"
#import "EmotionManager.h"
#import "CBRegularExpressionManager.h"

#import "RecordAudioSetting.h"
#import "AudioPanView.h"
#import "FacialPanView.h"

#import "ChatMessageEntity.h"

static void * kJSQMessagesKeyValueObservingContext = &kJSQMessagesKeyValueObservingContext;



@interface JSQMessagesViewController () <JSQMessagesInputToolbarDelegate,
JSQMessagesKeyboardControllerDelegate,AudioPanDelegate,facialViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>{

    BOOL _isHide;

}

@property (weak, nonatomic) IBOutlet JSQMessagesCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet JSQMessagesInputToolbar *inputToolbar;
@property (nonatomic,retain) AudioPanView *audioPan;
@property (nonatomic,retain) FacialPanView *facialPan;
@property(nonatomic,strong)UIView*window;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomLayoutGuide;
@property (nonatomic,assign) BOOL isAudioShow;
@property (nonatomic,assign) BOOL isFacialShow;

@property (weak, nonatomic) UIView *snapshotView;

@property (assign, nonatomic) BOOL jsq_isObserving;

@property (strong, nonatomic) NSIndexPath *selectedIndexPathForMenu;
@property (strong, nonatomic) UIView *disconnectFlag;

- (void)jsq_configureMessagesViewController;

- (NSString *)jsq_currentlyComposedMessageText;

- (void)jsq_handleDidChangeStatusBarFrameNotification:(NSNotification *)notification;
- (void)jsq_didReceiveMenuWillShowNotification:(NSNotification *)notification;
- (void)jsq_didReceiveMenuWillHideNotification:(NSNotification *)notification;

- (void)jsq_updateKeyboardTriggerPoint;
- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant;

- (void)jsq_handleInteractivePopGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

- (BOOL)jsq_inputToolbarHasReachedMaximumHeight;
- (void)jsq_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy;
- (void)jsq_adjustInputToolbarHeightConstraintByDelta:(CGFloat)dy;
- (void)jsq_scrollComposerTextViewToBottomAnimated:(BOOL)animated;

- (void)jsq_updateCollectionViewInsets;
- (void)jsq_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom;

- (BOOL)jsq_isMenuVisible;

- (void)jsq_addObservers;
- (void)jsq_removeObservers;

- (void)jsq_registerForNotifications:(BOOL)registerForNotifications;

- (void)jsq_addActionToInteractivePopGestureRecognizer:(BOOL)addAction;
@end



@implementation JSQMessagesViewController

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([JSQMessagesViewController class])
                          bundle:[NSBundle bundleForClass:[JSQMessagesViewController class]]];
}

+ (instancetype)messagesViewController
{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([JSQMessagesViewController class])
                                          bundle:[NSBundle bundleForClass:[JSQMessagesViewController class]]];
}

#pragma mark - Initialization

- (void)jsq_configureMessagesViewController
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.jsq_isObserving = NO;
    
    self.toolbarHeightConstraint.constant = self.inputToolbar.preferredDefaultHeight;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.inputToolbar.delegate = self;
    self.inputToolbar.contentView.textView.placeHolder = [NSBundle jsq_localizedStringForKey:@"new_message"];
    self.inputToolbar.contentView.textView.delegate = self;
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    self.outgoingCellIdentifier = [JSQMessagesCollectionViewCellOutgoing cellReuseIdentifier];
    self.outgoingMediaCellIdentifier = [JSQMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier];
    
    self.incomingCellIdentifier = [JSQMessagesCollectionViewCellIncoming cellReuseIdentifier];
    self.incomingMediaCellIdentifier = [JSQMessagesCollectionViewCellIncoming mediaCellReuseIdentifier];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];

    
    self.showTypingIndicator = NO;
    
    self.showLoadEarlierMessagesHeader = NO;
    
    self.topContentAdditionalInset = 0.0f;
    
    [self jsq_updateCollectionViewInsets];
    
    self.keyboardController = [[JSQMessagesKeyboardController alloc] initWithTextView:self.inputToolbar.contentView.textView
                                                                          contextView:self.view
                                                                 panGestureRecognizer:nil
                                                                             delegate:self];
    self.audioPan = [[AudioPanView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(AppWindow.bounds), CGRectGetWidth(AppWindow.bounds), CGRectGetHeight(AppWindow.bounds)) target:self];
    self.facialPan = [[FacialPanView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(AppWindow.bounds), CGRectGetWidth(AppWindow.bounds), CGRectGetHeight(AppWindow.bounds)) target:self];
    [self.view addSubview:_audioPan];
    [self.view addSubview:_facialPan];
}

- (void)dealloc
{
    [self jsq_registerForNotifications:NO];
    [self jsq_removeObservers];
    
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    _collectionView = nil;
    
    _inputToolbar.contentView.textView.delegate = nil;
    _inputToolbar.delegate = nil;
    _inputToolbar = nil;
    
    _toolbarHeightConstraint = nil;
    _toolbarBottomLayoutGuide = nil;
    
    _senderId = nil;
    _senderDisplayName = nil;
    _outgoingCellIdentifier = nil;
    _incomingCellIdentifier = nil;
    
    [_keyboardController endListeningForKeyboard];
    _keyboardController = nil;
}

#pragma mark - Setters

- (void)setShowTypingIndicator:(BOOL)showTypingIndicator
{
    if (_showTypingIndicator == showTypingIndicator) {
        return;
    }
    
    _showTypingIndicator = showTypingIndicator;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setShowLoadEarlierMessagesHeader:(BOOL)showLoadEarlierMessagesHeader
{
    if (_showLoadEarlierMessagesHeader == showLoadEarlierMessagesHeader) {
        return;
    }
    
    _showLoadEarlierMessagesHeader = showLoadEarlierMessagesHeader;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}

- (void)setTopContentAdditionalInset:(CGFloat)topContentAdditionalInset
{
    _topContentAdditionalInset = topContentAdditionalInset;
    [self jsq_updateCollectionViewInsets];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[[self class] nib] instantiateWithOwner:self options:nil];
    
    [self jsq_configureMessagesViewController];
    [self jsq_registerForNotifications:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSParameterAssert(self.senderId != nil);
    NSParameterAssert(self.senderDisplayName != nil);
    
    [super viewWillAppear:animated];
    [self.view layoutIfNeeded];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToBottomAnimated:NO];
            [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
        });
    }
    
    [self jsq_updateKeyboardTriggerPoint];
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPPConnectStateChanged object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self jsq_addObservers];
    [self jsq_addActionToInteractivePopGestureRecognizer:YES];
    [self.keyboardController beginListeningForKeyboard];
    
    if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
        [self.snapshotView removeFromSuperview];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self jsq_addActionToInteractivePopGestureRecognizer:NO];
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self jsq_removeObservers];
    [self.keyboardController endListeningForKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING: %s", __PRETTY_FUNCTION__);
}

#pragma mark - View rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (self.showTypingIndicator) {
        self.showTypingIndicator = NO;
        self.showTypingIndicator = YES;
        [self.collectionView reloadData];
    }
}

#pragma mark - Messages view controller

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    NSAssert(NO, @"Error! required method not implemented in subclass. Need to implement %s", __PRETTY_FUNCTION__);
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    NSAssert(NO, @"Error! required method not implemented in subclass. Need to implement %s", __PRETTY_FUNCTION__);
}

- (void)finishSendingMessage
{
    [self finishSendingMessageAnimated:YES];
}

- (void)finishSendingMessageAnimated:(BOOL)animated {
    
    UITextView *textView = self.inputToolbar.contentView.textView;
    textView.text = nil;
    [textView.undoManager removeAllActions];
    
    [self.inputToolbar toggleSendButtonEnabled];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
    
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView reloadData];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:false];
    }
}

- (void)finishReceivingMessage
{
    [self finishReceivingMessageAnimated:YES];
}

- (void)finishReceivingMessageAnimated:(BOOL)animated {
    
    self.showTypingIndicator = NO;
    
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView reloadData];
    
    if (self.automaticallyScrollsToMostRecentMessage && ![self jsq_isMenuVisible]) {
        [self scrollToBottomAnimated:animated];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    if ([self.collectionView numberOfSections] == 0) {
        return;
    }
    NSInteger items = [self.collectionView numberOfItemsInSection:0];
    if (items == 0) {
        return;
    }
    CGFloat collectionViewContentHeight = [self.collectionView.collectionViewLayout collectionViewContentSize].height;
    BOOL isContentTooSmall = (collectionViewContentHeight < CGRectGetHeight(self.collectionView.bounds));
    
    if (isContentTooSmall) {
        //  workaround for the first few messages not scrolling
        //  when the collection view content size is too small, `scrollToItemAtIndexPath:` doesn't work properly
        //  this seems to be a UIKit bug, see #256 on GitHub
        [self.collectionView scrollRectToVisible:CGRectMake(0.0, collectionViewContentHeight - 1.0f, 1.0f, 1.0f)
                                        animated:animated];
        return;
    }
    
    //  workaround for really long messages not scrolling
    //  if last message is too long, use scroll position bottom for better appearance, else use top
    //  possibly a UIKit bug, see #480 on GitHub
    NSUInteger finalRow = MAX(0, [self.collectionView numberOfItemsInSection:0] - 1);
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    CGSize finalCellSize = [self.collectionView.collectionViewLayout sizeForItemAtIndexPath:finalIndexPath];
    
    CGFloat maxHeightForVisibleMessage = CGRectGetHeight(self.collectionView.bounds) - self.collectionView.contentInset.top - CGRectGetHeight(self.inputToolbar.bounds);
    
    UICollectionViewScrollPosition scrollPosition = (finalCellSize.height > maxHeightForVisibleMessage) ? UICollectionViewScrollPositionBottom : UICollectionViewScrollPositionTop;
    
    [self.collectionView scrollToItemAtIndexPath:finalIndexPath
                                atScrollPosition:scrollPosition
                                        animated:animated];
}

#pragma mark - JSQMessages collection view data source

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"ERROR: required method not implemented: %s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<JSQMessageData> messageItem = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
    NSParameterAssert(messageItem != nil);
    
    NSString *messageSenderId = [messageItem senderId];
    NSParameterAssert(messageSenderId != nil);
    
    BOOL isOutgoingMessage = [messageSenderId isEqualToString:self.senderId];
    BOOL isMediaMessage = [messageItem isMediaMessage];
    
    NSString *cellIdentifier = nil;
    if (isMediaMessage) {
        cellIdentifier = isOutgoingMessage ? self.outgoingMediaCellIdentifier : self.incomingMediaCellIdentifier;
    }
    else {
        cellIdentifier = isOutgoingMessage ? self.outgoingCellIdentifier : self.incomingCellIdentifier;
    }
    
    JSQMessagesCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.delegate = collectionView;
    if (!isMediaMessage) {
        cell.textView.text = [messageItem text];
        NSMutableArray *tmpArray = [NSMutableArray array];
        
        // 正则匹配图片信息
        [CBRegularExpressionManager itemIndexesWithPattern:@"\\[[\\u4e00-\\u9fa5a-z]{1,3}\\]" inString:[messageItem text] usingBlock:^(NSString *name,NSRange range,  NSInteger idx, BOOL *const stop) {
            // 图片信息储存
            TYImageStorage *imageStorage = [[TYImageStorage alloc]init];
            NSString *pic = [EmotionManager emotionForKey:name];
            if (pic) {
                imageStorage.imageName = pic;
                imageStorage.range = range;
                imageStorage.size = CGSizeMake(25, 25);
                [tmpArray addObject:imageStorage];
            }
        }];
        // 添加图片信息数组到label
        [cell.textView addTextStorageArray:tmpArray];
        if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
            //  workaround for iOS 7 textView data detectors bug
            cell.textView.text = nil;
            cell.textView.attributedText = [[NSAttributedString alloc] initWithString:[messageItem text]
                                                                           attributes:@{ NSFontAttributeName : collectionView.collectionViewLayout.messageBubbleFont }];
        }
        
        NSParameterAssert(cell.textView.text != nil);
        
        id<JSQMessageBubbleImageDataSource> bubbleImageDataSource = [collectionView.dataSource collectionView:collectionView messageBubbleImageDataForItemAtIndexPath:indexPath];
        if (bubbleImageDataSource != nil) {
            cell.messageBubbleImageView.image = [bubbleImageDataSource messageBubbleImage];
            cell.messageBubbleImageView.highlightedImage = [bubbleImageDataSource messageBubbleHighlightedImage];
        }
    }
    else {
        id<JSQMessageMediaData> messageMedia = [messageItem media];
        cell.mediaView = [messageMedia mediaView] ?: [messageMedia mediaPlaceholderView];
       // NSParameterAssert(cell.mediaView != nil);
    }
    
    BOOL needsAvatar = YES;
    if (isOutgoingMessage && CGSizeEqualToSize(collectionView.collectionViewLayout.outgoingAvatarViewSize, CGSizeZero)) {
        needsAvatar = NO;
    }
    else if (!isOutgoingMessage && CGSizeEqualToSize(collectionView.collectionViewLayout.incomingAvatarViewSize, CGSizeZero)) {
        needsAvatar = NO;
    }
    
    id<JSQMessageAvatarImageDataSource> avatarImageDataSource = nil;
    if (needsAvatar) {
        avatarImageDataSource = [collectionView.dataSource collectionView:collectionView avatarImageDataForItemAtIndexPath:indexPath];
        if (avatarImageDataSource != nil) {
            
            NSString *avatarImage = [avatarImageDataSource avatarImage];
            if (avatarImage == nil) {
                cell.avatarImageView.image = [avatarImageDataSource avatarPlaceholderImage];
                cell.avatarImageView.highlightedImage = nil;
            }
            else {
                [cell.avatarImageView sd_setImageWithURL:CRURL(avatarImage) placeholderImage:nil];
                cell.avatarImageView.highlightedImage = nil;
            }
        }
    }
    
    cell.cellTopLabel.attributedText = [collectionView.dataSource collectionView:collectionView attributedTextForCellTopLabelAtIndexPath:indexPath];
    cell.messageBubbleTopLabel.attributedText = [collectionView.dataSource collectionView:collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:indexPath];
    cell.cellBottomLabel.attributedText = [collectionView.dataSource collectionView:collectionView attributedTextForCellBottomLabelAtIndexPath:indexPath];
    
    CGFloat bubbleTopLabelInset = (avatarImageDataSource != nil) ? 60.0f : 15.0f;
    
    if (isOutgoingMessage) {
        cell.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, bubbleTopLabelInset);
    }
    else {
        cell.messageBubbleTopLabel.textInsets = UIEdgeInsetsMake(0.0f, bubbleTopLabelInset, 0.0f, 0.0f);
    }
    
    //    cell.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.layer.shouldRasterize = YES;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(JSQMessagesCollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if (self.showTypingIndicator && [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [collectionView dequeueTypingIndicatorFooterViewForIndexPath:indexPath];
    }
    else if (self.showLoadEarlierMessagesHeader && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [collectionView dequeueLoadEarlierMessagesViewHeaderForIndexPath:indexPath];
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (!self.showTypingIndicator) {
        return CGSizeZero;
    }
    
    return CGSizeMake([collectionViewLayout itemWidth], kJSQMessagesTypingIndicatorFooterViewHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (!self.showLoadEarlierMessagesHeader) {
        return CGSizeZero;
    }
    
    return CGSizeMake([collectionViewLayout itemWidth], kJSQMessagesLoadEarlierHeaderViewHeight);
}

#pragma mark - Collection view delegate

- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //  disable menu for media messages
    id<JSQMessageData> messageItem = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
    if ([messageItem isMediaMessage]) {
        return NO;
    }
    
    self.selectedIndexPathForMenu = indexPath;
    
    //  textviews are selectable to allow data detectors
    //  however, this allows the 'copy, define, select' UIMenuController to show
    //  which conflicts with the collection view's UIMenuController
    //  temporarily disable 'selectable' to prevent this issue
    //    JSQMessagesCollectionViewCell *selectedCell = (JSQMessagesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //    selectedCell.textView.selectable = NO;
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    }
    
    return NO;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        id<JSQMessageData> messageData = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:[messageData text]];
    }
}

#pragma mark - Collection view delegate flow layout

- (CGSize)collectionView:(JSQMessagesCollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath { }

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath { }

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapCellAtIndexPath:(NSIndexPath *)indexPath
         touchLocation:(CGPoint)touchLocation { }

#pragma mark - Input toolbar delegate

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender
{
    /**
     * 音频按钮
     */
    [self showAudioPan];
    
}
-(void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressImageBarButton:(UIButton *)sender
{
    /**
     *  图片按钮
     */
    if (self.inputToolbar.contentView.textView.isFirstResponder) {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }else{
        if (_isFacialShow) {
            [self hiddenFacialPan];
            CGFloat y = AppWindow.height;
            [UIView animateWithDuration:.25 animations:^{
                _inputToolbar.y = y - _inputToolbar.height;
                [self jsq_updateCollectionViewInsets];
                [self scrollToBottomAnimated:true];
            }];
        }
        if (_isAudioShow) {
            [self hiddenAudioPan];
            CGFloat y =AppWindow.height;
            [UIView animateWithDuration:.25 animations:^{
                _inputToolbar.y = y - _inputToolbar.height;
                [self jsq_updateCollectionViewInsets];
                [self scrollToBottomAnimated:true];
            }];
        }
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"从相册选取照片" otherButtonTitles:@"拍照", nil];
    [sheet showInView:self.view];
    
}
-(void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressEmotionBarButton:(UIButton *)sender
{
    /**
     * 表情按钮
     */
    [self showFacialPan];
    
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    if (toolbar.sendButtonOnRight) {
        [self didPressSendButton:sender
                 withMessageText:[self jsq_currentlyComposedMessageText]
                        senderId:self.senderId
               senderDisplayName:self.senderDisplayName
                            date:[NSDate date]];
    }
    else {
        [self didPressAccessoryButton:sender];
    }
}



- (NSString *)jsq_currentlyComposedMessageText
{
    //  auto-accept any auto-correct suggestions
    [self.inputToolbar.contentView.textView.inputDelegate selectionWillChange:self.inputToolbar.contentView.textView];
    [self.inputToolbar.contentView.textView.inputDelegate selectionDidChange:self.inputToolbar.contentView.textView];
    
    return [self.inputToolbar.contentView.textView.text jsq_stringByTrimingWhitespace];
}

#pragma mark - Text view delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.keyboardController beginListeningForKeyboard];
    if (_isFacialShow) {
        [self hiddenFacialPan];
    }
    if (_isAudioShow) {
        [self hiddenAudioPan];
    }
    return true;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [textView becomeFirstResponder];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [self.inputToolbar toggleSendButtonEnabled];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    [self.keyboardController endListeningForKeyboard];
    [textView resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView.text length] == 0&&[text isEqualToString:@"\n"]) {
        return false;
    }
    if ([text isEqualToString:@"\n"]) {
        [self didPressSendButton:nil
                 withMessageText:[self jsq_currentlyComposedMessageText]
                        senderId:self.senderId
               senderDisplayName:self.senderDisplayName
                            date:[NSDate date]];
        return false;
    }else{
        
    }
    return true;
}

#pragma mark - Notifications

- (void)jsq_handleDidChangeStatusBarFrameNotification:(NSNotification *)notification
{
    if (self.keyboardController.keyboardIsVisible) {
        [self jsq_setToolbarBottomLayoutGuideConstant:CGRectGetHeight(self.keyboardController.currentKeyboardFrame)];
    }
}

- (void)jsq_didReceiveMenuWillShowNotification:(NSNotification *)notification
{
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    UIMenuController *menu = [notification object];
    [menu setMenuVisible:NO animated:NO];
    
    JSQMessagesCollectionViewCell *selectedCell = (JSQMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    CGRect selectedCellMessageBubbleFrame = [selectedCell convertRect:selectedCell.messageBubbleContainerView.frame toView:self.view];
    
    [menu setTargetRect:selectedCellMessageBubbleFrame inView:self.view];
    [menu setMenuVisible:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
}

- (void)jsq_didReceiveMenuWillHideNotification:(NSNotification *)notification
{
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    
    //  per comment above in 'shouldShowMenuForItemAtIndexPath:'
    //  re-enable 'selectable', thus re-enabling data detectors if present
    //    JSQMessagesCollectionViewCell *selectedCell = (JSQMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    //    selectedCell.textView.selectable = YES;
    self.selectedIndexPathForMenu = nil;
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kJSQMessagesKeyValueObservingContext) {
        
        if (object == self.inputToolbar.contentView.textView
            && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            
            CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            
            CGFloat dy = newContentSize.height - oldContentSize.height;
            
            [self jsq_adjustInputToolbarForComposerTextViewContentSizeChange:dy];
            [self jsq_updateCollectionViewInsets];
            if (self.automaticallyScrollsToMostRecentMessage) {
                [self scrollToBottomAnimated:NO];
            }
        }
    }
}

#pragma mark - Keyboard controller delegate

- (void)keyboardController:(JSQMessagesKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame
{
    if (![self.inputToolbar.contentView.textView isFirstResponder] && self.toolbarBottomLayoutGuide.constant == 0.0f) {
        return;
    }
    CGFloat heightFromBottom = CGRectGetMaxY(self.collectionView.frame) - CGRectGetMinY(keyboardFrame);
    
    heightFromBottom = MAX(0.0f, heightFromBottom);
    if (_isFacialShow||_isAudioShow) {
        heightFromBottom = AppWindow.height - _facialPan.height;
    }
    
    [self jsq_setToolbarBottomLayoutGuideConstant:heightFromBottom];
}

- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant
{
    self.toolbarBottomLayoutGuide.constant = constant;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    [self jsq_updateCollectionViewInsets];
}

- (void)jsq_updateKeyboardTriggerPoint
{
    self.keyboardController.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(self.inputToolbar.bounds));
}

#pragma mark - Gesture recognizers

- (void)jsq_handleInteractivePopGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
                [self.snapshotView removeFromSuperview];
            }
            
            [self.keyboardController endListeningForKeyboard];
            
            if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
                [self.inputToolbar.contentView.textView resignFirstResponder];
                [UIView animateWithDuration:0.0
                                 animations:^{
                                     [self jsq_setToolbarBottomLayoutGuideConstant:0.0f];
                                 }];
                
                UIView *snapshot = [self.view snapshotViewAfterScreenUpdates:YES];
                [self.view addSubview:snapshot];
                self.snapshotView = snapshot;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self.keyboardController beginListeningForKeyboard];
            
            if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
                [self.snapshotView removeFromSuperview];
            }
            break;
        default:
            break;
    }
}

#pragma mark - Input toolbar utilities

- (BOOL)jsq_inputToolbarHasReachedMaximumHeight
{
    return CGRectGetMinY(self.inputToolbar.frame) == (self.topLayoutGuide.length + self.topContentAdditionalInset);
}

- (void)jsq_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy
{
    BOOL contentSizeIsIncreasing = (dy > 0);
    
    if ([self jsq_inputToolbarHasReachedMaximumHeight]) {
        BOOL contentOffsetIsPositive = (self.inputToolbar.contentView.textView.contentOffset.y > 0);
        
        if (contentSizeIsIncreasing || contentOffsetIsPositive) {
            [self jsq_scrollComposerTextViewToBottomAnimated:YES];
            return;
        }
    }
    
    CGFloat toolbarOriginY = CGRectGetMinY(self.inputToolbar.frame);
    CGFloat newToolbarOriginY = toolbarOriginY - dy;
    
    //  attempted to increase origin.Y above topLayoutGuide
    if (newToolbarOriginY <= self.topLayoutGuide.length + self.topContentAdditionalInset) {
        dy = toolbarOriginY - (self.topLayoutGuide.length + self.topContentAdditionalInset);
        [self jsq_scrollComposerTextViewToBottomAnimated:YES];
    }
    NSLog(@"11 --- %f",self.inputToolbar.y);
    [self jsq_adjustInputToolbarHeightConstraintByDelta:dy];
    NSLog(@"22 --- %f",self.inputToolbar.y);
    
    [self jsq_updateKeyboardTriggerPoint];
    NSLog(@"33 --- %f",self.inputToolbar.y);
    
    if (dy < 0) {
        [self jsq_scrollComposerTextViewToBottomAnimated:NO];
    }
}

- (void)jsq_adjustInputToolbarHeightConstraintByDelta:(CGFloat)dy
{
    CGFloat proposedHeight = self.toolbarHeightConstraint.constant + dy;
    
    CGFloat finalHeight = MAX(proposedHeight, self.inputToolbar.preferredDefaultHeight);
    
    if (self.inputToolbar.maximumHeight != NSNotFound) {
        finalHeight = MIN(finalHeight, self.inputToolbar.maximumHeight);
    }
    
    if (self.toolbarHeightConstraint.constant != finalHeight) {
        self.toolbarHeightConstraint.constant = finalHeight;
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }
}

- (void)jsq_scrollComposerTextViewToBottomAnimated:(BOOL)animated
{
    UITextView *textView = self.inputToolbar.contentView.textView;
    CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, textView.contentSize.height - CGRectGetHeight(textView.bounds));
    
    if (!animated) {
        textView.contentOffset = contentOffsetToShowLastLine;
        return;
    }
    
    [UIView animateWithDuration:0.01
                          delay:0.01
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         textView.contentOffset = contentOffsetToShowLastLine;
                     }
                     completion:nil];
}

#pragma mark - Collection view utilities

- (void)jsq_updateCollectionViewInsets
{
    [self jsq_setCollectionViewInsetsTopValue:self.topLayoutGuide.length + self.topContentAdditionalInset
                                  bottomValue:CGRectGetMaxY(self.collectionView.frame) - CGRectGetMinY(self.inputToolbar.frame)];
}

- (void)jsq_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0.0f, bottom, 0.0f);
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
}

- (BOOL)jsq_isMenuVisible
{
    //  check if cell copy menu is showing
    //  it is only our menu if `selectedIndexPathForMenu` is not `nil`
    return self.selectedIndexPathForMenu != nil && [[UIMenuController sharedMenuController] isMenuVisible];
}


# pragma mark - panview

-(void)showFacialPan{
    
    if (_isFacialShow) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    UIImage *accessoryImage = [UIImage jsq_defaultKeyboardImage];
    UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor darkGrayColor]];
    [self.inputToolbar.contentView.emotionBarButtonItem setImage:normalImage forState:UIControlStateNormal];
    [self.inputToolbar.contentView.emotionBarButtonItem setImage:highlightedImage forState:UIControlStateHighlighted];
    if (_isAudioShow) {
        [self hiddenAudioPan];
    }
    _isFacialShow = true;
    if (self.inputToolbar.contentView.textView.isFirstResponder) {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }
    CGFloat y = AppWindow.height - _facialPan.height;
    
    CGFloat heightFromBottom = CGRectGetMaxY(self.collectionView.frame) - y;
    heightFromBottom = MAX(0.0f, heightFromBottom);
    [self jsq_setToolbarBottomLayoutGuideConstant:heightFromBottom];
    [self scrollToBottomAnimated:true];
    
    [UIView animateWithDuration:.25 animations:^{
        _facialPan.y = y;
    }];
}
-(void)showAudioPan{
    
    if (_isAudioShow) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    if (_isFacialShow) {
        [self hiddenFacialPan];
    }
    UIImage *accessoryImage = [UIImage jsq_defaultKeyboardImage];
    UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor darkGrayColor]];
    [self.inputToolbar.contentView.leftBarButtonItem setImage:normalImage forState:UIControlStateNormal];
    [self.inputToolbar.contentView.leftBarButtonItem setImage:highlightedImage forState:UIControlStateHighlighted];    _isAudioShow = true;
    if (self.inputToolbar.contentView.textView.isFirstResponder) {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }
    
    CGFloat y = AppWindow.height - _audioPan.height;
    CGFloat heightFromBottom = CGRectGetMaxY(self.collectionView.frame) - y;
    heightFromBottom = MAX(0.0f, heightFromBottom);
    [self jsq_setToolbarBottomLayoutGuideConstant:heightFromBottom];
    [self scrollToBottomAnimated:true];
    [UIView animateWithDuration:.25 animations:^{
        _audioPan.y = y;
    }];
    
}
-(void)hiddenAudioPan
{
    CGFloat y = AppWindow.height;
    _isAudioShow = false;
    UIImage *accessoryImage = [UIImage jsq_defaultRecordImage];
    UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor darkGrayColor]];
    [self.inputToolbar.contentView.leftBarButtonItem setImage:normalImage forState:UIControlStateNormal];
    [self.inputToolbar.contentView.leftBarButtonItem setImage:highlightedImage forState:UIControlStateHighlighted];
    [UIView animateWithDuration:.25 animations:^{
        _audioPan.y = y;
    }];
}
-(void)hiddenFacialPan
{
    CGFloat y = AppWindow.height;
    _isFacialShow = false;
    UIImage *accessoryImage = [UIImage jsq_defaultEmotionImage];
    UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor darkGrayColor]];
    [self.inputToolbar.contentView.emotionBarButtonItem setImage:normalImage forState:UIControlStateNormal];
    [self.inputToolbar.contentView.emotionBarButtonItem setImage:highlightedImage forState:UIControlStateHighlighted];
    [UIView animateWithDuration:.25 animations:^{
        _facialPan.y = y;
    }];
}

# pragma mark - facialDelegate
#pragma mark - facial delegate
-(void)selectedFacialView:(NSString *)facial{
    
    NSString *str = self.inputToolbar.contentView.textView.text;
    if (![facial isEqualToString:@"删除"]) {
        NSString *newStr = [NSString stringWithFormat:@"%@%@",str,facial];
        self.inputToolbar.contentView.textView.text = newStr;
        
    }else{
        [self deleteFacial];
    }
}
-(void)sendMessage{
    
    [self didPressSendButton:nil
             withMessageText:[self jsq_currentlyComposedMessageText]
                    senderId:self.senderId
           senderDisplayName:self.senderDisplayName
                        date:[NSDate date]];
    
}
-(void)deleteFacial{
    
    NSError *error = nil;
    NSString *regTags = @"\\[[\\u4e00-\\u9fa5a-z]{1,3}\\]";       // 设计好的正则表达式，最好先在小工具里试验好
    NSString *text = self.inputToolbar.contentView.textView.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                  
                                                                           options:NSRegularExpressionCaseInsensitive    // 还可以加一些选项，例如：不区分大小写
                                  
                                                                             error:&error];
    
    // 执行匹配的过程
    
    NSArray *matches = [regex matchesInString:text options:0  range:NSMakeRange(0, [text length])];
    
    // 用下面的办法来遍历每一条匹配记录
    NSRange range = self.inputToolbar.contentView.textView.selectedRange;
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        if (range.location>=matchRange.location&&range.location<=matchRange.location+matchRange.length) {
            
            NSString *newStr = [text stringByReplacingCharactersInRange:matchRange withString:@""];
            self.inputToolbar.contentView.textView.text = newStr;
            return;
            break;
            
        }
    }
    if (text.length>0) {
        
        NSString *newText = [text substringToIndex:text.length - 1];
        self.inputToolbar.contentView.textView.text = newText;
    }
    
}



#pragma mark - Utilities

- (void)jsq_addObservers
{
    if (self.jsq_isObserving) {
        return;
    }
    
    [self.inputToolbar.contentView.textView addObserver:self
                                             forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                                context:kJSQMessagesKeyValueObservingContext];
    
    self.jsq_isObserving = YES;
}

- (void)jsq_removeObservers
{
    if (!_jsq_isObserving) {
        return;
    }
    
    @try {
        [_inputToolbar.contentView.textView removeObserver:self
                                                forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                   context:kJSQMessagesKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    
    _jsq_isObserving = NO;
}

- (void)jsq_registerForNotifications:(BOOL)registerForNotifications
{

    if (registerForNotifications) {
//         NSLog(@"YYYYYYYYYYYYYYYYYYYYYYY");
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jsq_handleDidChangeStatusBarFrameNotification:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jsq_didReceiveMenuWillShowNotification:)
                                                     name:UIMenuControllerWillShowMenuNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jsq_didReceiveMenuWillHideNotification:)
                                                     name:UIMenuControllerWillHideMenuNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkXmppState) name:kXMPPConnectStateChanged object:nil];
    }
    else {
//         NSLog(@"NNNNNNNNNNNNNNNNNNNNN");
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidChangeStatusBarFrameNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIMenuControllerWillShowMenuNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIMenuControllerWillHideMenuNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:kXMPPConnectStateChanged
                                                      object:nil];
    }
}

- (void)jsq_addActionToInteractivePopGestureRecognizer:(BOOL)addAction
{
    if (self.navigationController.interactivePopGestureRecognizer) {
        [self.navigationController.interactivePopGestureRecognizer removeTarget:nil
                                                                         action:@selector(jsq_handleInteractivePopGestureRecognizer:)];
        
        if (addAction) {
            [self.navigationController.interactivePopGestureRecognizer addTarget:self
                                                                          action:@selector(jsq_handleInteractivePopGestureRecognizer:)];
        }
    }
}


# pragma mark - actionsheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex>1) {
        return;
    }
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate  = self;
    if (buttonIndex == 0) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    }else if(buttonIndex == 1){
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [CRRootNavigation() presentViewController:picker animated:YES completion:nil];
    picker = nil;
    
}


# pragma mark - ImagePickerDelegate
/**
 *  相册代理
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        // Get the assets library
        
        NSString* fileName = [self createImageFileName];
        NSString *jpgPath = [[self getFileDir] stringByAppendingPathComponent:CRString(@"%@",fileName)];
        UIImage* image = [info valueForKey:UIImagePickerControllerOriginalImage];
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL directory = true;
        if (![manager fileExistsAtPath:[self getFileDir] isDirectory:&directory]) {
            [manager createDirectoryAtPath:[self getFileDir] withIntermediateDirectories:true attributes:nil error:nil];
        }
        UIImage *newImage = nil;
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            NSDictionary *imageMetadata = [info objectForKey:
                                           UIImagePickerControllerMediaMetadata];
            NSInteger oritation = [[imageMetadata valueForKeyPath:@"Orientation"] integerValue];
            UIImage *oImage = [UIImage thumbImage:image];
            image = nil;
            newImage = [UIImage image:oImage rotation:oritation];
            
        }else{
            newImage = [UIImage thumbImage:image];
        }
        BOOL saveSign = [UIImageJPEGRepresentation(newImage, 0.4) writeToFile:jpgPath atomically:NO];
        if(saveSign)
        {
            //图片旋转上传
            NSDictionary *dict = @{@"name": fileName,@"type":@"image"};
            [CRRootNavigation() dismissViewControllerAnimated:YES completion:^{
                if ([self respondsToSelector:@selector(sendMedia:type:)]) {
                    [self sendMedia:dict type:SOMessageTypePhoto];
                }
            }];
        }else{
            [CRRootNavigation() dismissViewControllerAnimated:YES completion:^{
                [CustomToast showMessageOnWindow:@"获取资源失败"];
            }];
        }
    }
}
//  创建文件名
-(NSString*) createImageFileName
{
    NSDate *date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    NSString* name = [NSString stringWithFormat:@"Upload_%f.jpg", interval];
    return name;
}
//  创建文件名
-(NSString*) getFileDir
{
    NSString *imgs = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"/Images/"];
    NSLog(@"imgpath == %@",imgs);
    return imgs;
}
-(void)sendMedia:(NSDictionary *)media type:(SOMessageType)type{}
- (void)loadOlderMessages{}

# pragma mark - scrollViewdelegate
/**
 *  scrollViewDelegate
 *
 *  @param scrollView
 */
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_isLoadingMore) {
        return;
    }
    if (scrollView.contentOffset.y <= self.collectionView.contentInset.top) {
        if ( false == _isAllLoad) {
            [self loadOlderMessages];
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.inputToolbar.contentView.textView.isFirstResponder) {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }else{
        if (_isFacialShow) {
            [self hiddenFacialPan];
            [UIView animateWithDuration:.25 animations:^{
                [self jsq_setToolbarBottomLayoutGuideConstant:0];
                [self scrollToBottomAnimated:true];
            }];
        }
        if (_isAudioShow) {
            [self hiddenAudioPan];
            [UIView animateWithDuration:.25 animations:^{
                [self jsq_setToolbarBottomLayoutGuideConstant:0];
                [self scrollToBottomAnimated:true];
            }];
        }
    }
}


/**
 *  添加
 */
/**
 *  连接状态
 */
-(void)checkXmppState{

    if (!_disconnectFlag) {
        _disconnectFlag = [[UIView alloc] initWithFrame:CGRectMake(0, NAV_H, [UIScreen mainScreen].bounds.size.width, 30)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        _disconnectFlag.backgroundColor = [UIColor orangeColor];
        button.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
        [button setTitle:@"已断开连接，点击重连" forState:UIControlStateNormal];
        button.titleLabel.font = MSGFont(12);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(reconnect:) forControlEvents:UIControlEventTouchUpInside];
        [_disconnectFlag addSubview:button];
        [self.view addSubview:_disconnectFlag];
        _disconnectFlag.hidden = true;
    }
    if ([XmppListenerManager sharedManager].isNetworkOK&&[XmppListenerManager sharedManager].xmppStream.isAuthenticated) {
        
        _disconnectFlag.hidden = true;
        
    }else{
        _disconnectFlag.hidden = false;
        
    }
    

}
-(void)cancel:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];

}
/**
 *  离线状态下重新连接
 *
 *  @param sender sender
 */
-(void)reconnect:(id)sender{
    
    [[XmppListenerManager sharedManager] disconnect];
    [[XmppListenerManager sharedManager] connectToServer];
    
}


@end
