//
//  CreateContentController.h
//  msgcopy
//
//  Created by wngzc on 15/7/9.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacialPanView.h"
#import "FacialView.h"
#import <MediaPlayer/MediaPlayer.h>

#define ImageSheetTag 100
#define VideoSheetTag 200
#define AudioSheetTag 200

@interface CreateContentController : UIViewController<UITextViewDelegate,facialViewDelegate,UINavigationControllerDelegate,MPMediaPickerControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property(nonatomic,assign)BOOL facialShown;
@property(nonatomic,retain)UIToolbar *toolBar;
@property(nonatomic,retain)UITableView *tableView;
@property(nonatomic,retain)FacialPanView *facialView;
@property(nonatomic,retain)NSMutableArray *attaches;

-(void)openVideoCamera:(id)sender;
-(void)openVideoAllbum:(id)sender;
-(void)openPhotoCamera:(id)sender;
-(void)openPhotoAllbum:(id)sender;

-(void)adjustToolBar;
-(void)hiddenEmotionView;

-(void)addVideo:(id)sender;
-(void)addImage:(id)sender;
-(void)addEmotion:(id)sender;

-(void)updateMediaView:(NSArray*)attachs;

@end
