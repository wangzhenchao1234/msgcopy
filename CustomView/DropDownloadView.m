//
//  VirtualMenuView.m
//  Kaoke
//
//  Created by Gavin on 15/4/28.
//  Copyright (c) 2015年 Msgcopy. All rights reserved.
//

#import "DropDownloadView.h"
#import "DropDownloadCell.h"

@implementation DropDownloadView

-(void)awakeFromNib
{
    self.frame = AppWindow.bounds;
    _tableView.height = 44*3;
    _mainView.height = 44*4+8;
    _tableView.layer.cornerRadius = 5;
    _cancelButton.layer.cornerRadius = 5;
    _cancelButton.clipsToBounds = true;
    _tableView.clipsToBounds = true;
    
}
-(void)show{
    
    [_tableView reloadData];
    UIViewController *vc = (UIViewController*)self.delegate;
    _mainView.y = -_mainView.height;
    [vc.view addSubview:self];
    [UIView animateWithDuration:.35 animations:^{
        _mainView.y = NAV_H + 10;
        _isShown = true;
    }];
    
}
-(void)hidden{
    
    [UIView animateWithDuration:.35 animations:^{
        _mainView.y = - _mainView.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        _isShown = false;
    }];
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidden];
}
-(void)reloadData
{
    [_tableView reloadData];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.delegate dropView:self numberOfRowsInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifire = @"DropDownloadCell";
    DropDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifire];
    if (!cell) {
        cell = [Utility nibWithName:@"DropDownloadCell" index:0];
        cell.imageView.frame = CGRectZero;
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 15);
    }
    NSString *title = [self.delegate dropView:self titleForRowAtIndexPath:indexPath];
    cell.titleView.text = title;
    cell.titleView.textColor = [UIColor colorFromHexRGB:@"383838"];
    return cell;
}

- (IBAction)doCancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cancelButtonClicked)]) {
        [self.delegate cancelButtonClicked];
    }
    [self hidden];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self hidden];
    if ([self.delegate respondsToSelector:@selector(dropView:selectMenuAtIndext:)]) {
        [self.delegate dropView:self selectMenuAtIndext:indexPath.row];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
