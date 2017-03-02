//
//  CenterCrossView.h
//  msgcopy
//
//  Created by wngzc on 15/7/8.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CenterCrossView;

@protocol CenterCrossViewDelegate <NSObject>

@required

-(NSString*)crossView:(CenterCrossView*)crossView titleForRowAtIndexPath:(NSIndexPath*)indexPath;
-(NSInteger)crossView:(CenterCrossView*)crossView numberOfRowsInSection:(NSInteger)section;

@optional
-(void)crossView:(CenterCrossView*)crossView selectMenuAtIndext:(NSInteger)index;

@end


@interface CenterCrossView : UIView<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,retain) NSArray *titles;
@property (nonatomic,weak) id<CenterCrossViewDelegate>delegate;
@property (nonatomic,assign) BOOL isShown;
-(void)reloadData;
-(void)hidden;
-(void)show;

@end
