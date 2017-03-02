//
//  MsgPhotoBrowser.h
//  msgcopy
//
//  Created by Gavin on 15/5/25.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MsgPhotoBrowser.h"

#import <MessageUI/MessageUI.h>
#import "MWPhoto.h"
#import "MWPhotoProtocol.h"
#import "MWCaptionView.h"

// Debug Logging
#if 0 // Set to 1 to enable debug logging
#define MWLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define MWLog(x, ...)
#endif

@class MsgPhotoBrowser;

@protocol MsgPhotoBrowserDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MsgPhotoBrowser *)photoBrowser;
- (id <MWPhoto>)photoBrowser:(MsgPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (id <MWPhoto>)photoBrowser:(MsgPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (MWCaptionView *)photoBrowser:(MsgPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(MsgPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MsgPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MsgPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(MsgPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MsgPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(MsgPhotoBrowser *)photoBrowser;

@end
@interface MsgPhotoBrowser : UIViewController<UIScrollViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
    NSArray *pubRels;
}

@property (nonatomic, weak) IBOutlet id<MsgPhotoBrowserDelegate> delegate;
@property (nonatomic) BOOL zoomPhotosToFill;
@property (nonatomic) BOOL displayNavArrows;
@property (nonatomic) BOOL displayActionButton;
@property (nonatomic) BOOL displaySelectionButtons;
@property (nonatomic) BOOL alwaysShowControls;
@property (nonatomic) BOOL enableGrid;
@property (nonatomic) BOOL enableSwipeToDismiss;
@property (nonatomic) BOOL startOnGrid;
@property (nonatomic) NSUInteger delayToHideElements;
@property (nonatomic, readonly) NSUInteger currentIndex;
@property (nonatomic, retain)PubEntity *pub;
@property (nonatomic, retain)ArticleEntity *msg;

// Init
- (id)initWithPhotos:(NSArray *)photosArray  __attribute__((deprecated("Use initWithDelegate: instead"))); // Depreciated
- (id)initWithDelegate:(id <MsgPhotoBrowserDelegate>)delegate;
- (id)initWithPub:(PubEntity *)pub;
- (id)initWithMsg:(ArticleEntity *)msg;
// Reloads the photo browser and refetches data
- (void)reloadData;

// Set page that photo browser starts on
- (void)setCurrentPhotoIndex:(NSUInteger)index;
- (void)setInitialPageIndex:(NSUInteger)index  __attribute__((deprecated("Use setCurrentPhotoIndex: instead"))); // Depreciated

// Navigation
- (void)showNextPhotoAnimated:(BOOL)animated;
- (void)showPreviousPhotoAnimated:(BOOL)animated;

@end
