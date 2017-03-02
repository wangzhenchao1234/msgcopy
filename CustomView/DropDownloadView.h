//
//  VirtualMenuView.h
//  Kaoke
//
//  Created by wngzc on 15/4/28.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropDownloadView;

@protocol DropDownloadViewDelegate <NSObject>

@required

-(NSString*)dropView:(DropDownloadView*)dropView titleForRowAtIndexPath:(NSIndexPath*)indexPath;
-(NSInteger)dropView:(DropDownloadView*)dropView numberOfRowsInSection:(NSInteger)section;

@optional
-(void)dropView:(DropDownloadView*)dropView selectMenuAtIndext:(NSInteger)index;
-(void)cancelButtonClicked;
@end

@interface DropDownloadView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (nonatomic,retain) NSArray *titles;
@property (nonatomic,weak) id<DropDownloadViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic,assign) BOOL isShown;
-(void)reloadData;
-(void)hidden;
-(void)show;
@end
