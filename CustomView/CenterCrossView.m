//
//  CenterCrossView.m
//  msgcopy
//
//  Created by Gavin on 15/7/8.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "CenterCrossView.h"
#import "CenterCrossCell.h"

@implementation CenterCrossView

-(void)awakeFromNib
{
    self.frame = AppWindow.bounds;
    _tableView.height = 44*5;
    _tableView.layer.cornerRadius = 5;
    _tableView.clipsToBounds = true;
    _tableView.alpha = 0;
    
}
-(void)show{
    
    [_tableView reloadData];
    [AppWindow addSubview:self];
    [UIView animateWithDuration:.25 animations:^{
        _tableView.alpha = 1;
        _isShown = true;
    }];
    
}
-(void)hidden{
    
    [UIView animateWithDuration:.25 animations:^{
        _tableView.alpha = 0;
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
    return [self.delegate crossView:self numberOfRowsInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifire = @"DropDownloadCell";
    CenterCrossCell*cell = [tableView dequeueReusableCellWithIdentifier:identifire];
    if (!cell) {
        cell = [Utility nibWithName:@"DropDownloadCell" index:0];
        cell.imageView.frame = CGRectZero;
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 15);
    }
    NSString *title = [self.delegate crossView:self titleForRowAtIndexPath:indexPath];
    cell.titleView.text = title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self hidden];
    if ([_delegate respondsToSelector:@selector(crossView:selectMenuAtIndext:)]) {
        [_delegate crossView:self selectMenuAtIndext:indexPath.row];
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
