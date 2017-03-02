//
//  ShareCategoryView.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/11.
//  Copyright © 2015年 wngzc. All rights reserved.
//

#import "ShareCategoryView.h"

#import "LeafShareCell.h"
#import "LimbShareHeaderCell.h"

@implementation ShareCategoryView
-(void)awakeFromNib
{
    [super awakeFromNib];
    _heightConstraint.constant = 300;
    _bottomConstraint.constant = -300;
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidden)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:NSClassFromString(@"ShareCategoryView")]) {
        return true;
    }
    return false;
}
-(void)show{
    [self loadDatasource];
    [AppWindow addSubview:self];
    [UIView animateWithDuration:.35 animations:^{
        _bottomConstraint.constant = 0;
    }];
}
-(void)hidden{
    
    [UIView animateWithDuration:.35 animations:^{
        _bottomConstraint.constant = -300;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];

}

-(void)loadDatasource{
    
    [MBProgressHUD showMessag:nil toView:self];
    [MSGRequestManager Get:kAPILimbLeafs(_shop.sid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [MBProgressHUD hideAllHUDsForView:self animated:false];
        _limbs = [NSMutableArray new];
        NSArray *limbsJson = data;
        [limbsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LimbEntity *limb = [LimbEntity buildInstanceByJson:obj];
            NSArray *leafsJson = obj[@"leafs"];
            NSMutableArray *leafs = [NSMutableArray new];
            [leafsJson enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LeafEntity *leaf = [LeafEntity buildInstanceByJson:obj];
                [leafs addObject:leaf];
            }];
            limb.leafs = leafs;
            [_limbs addObject:limb];
        }];
        [_tableView reloadData];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [MBProgressHUD hideAllHUDsForView:self animated:false];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LimbHeader"];
    if (!view) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"LimbHeader"];
        LimbShareHeaderCell *contentView = [Utility nibWithName:@"LimbHeaderFooterView" index:0];
        contentView.frame = view.bounds;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [view addSubview:contentView];
        contentView.tag = 100;
        UIButton *action = [UIButton buttonWithType:UIButtonTypeCustom];
        action.frame = CGRectMake(0, 0, tableView.width - 60, 50);
        action.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin
        
        ;
        action.backgroundColor = CRCOLOR_CLEAR;
        action.tag = 200;
        [view addSubview:action];
        [action addTarget:self action:@selector(openLimb:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    view.frame = CGRectMake(0, 0, tableView.width, 50);
    __block UIButton *action = nil;
    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *a = obj;
        if ([a isKindOfClass:[UIButton class]]&&a.tag>=200&&a.tag<1000) {
            action = (UIButton*)a;
            action.frame = CGRectMake(0, 0, view.width - 60, view.height);
            *stop = true;
        }
    }];
    LimbEntity *limb = _limbs[section];
    action.tag = 200 + section;
    LimbShareHeaderCell *header = (LimbShareHeaderCell*)[view viewWithTag:100];
    [header.thumbnail sd_setImageWithURL:CRURL(limb.icon.normal_icon)];
    header.titleView.text =limb.title;
    return view;
}
-(void)openLimb:(UIButton*)sender{
    NSInteger index = sender.tag - 200;
    LimbEntity *limb = _limbs[index];
    limb.isOpen = !limb.isOpen;
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationNone];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _limbs.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LimbEntity *limb = _limbs[section];
    if (!limb.isOpen) {
        return 0;
    }
    return limb.leafs.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LimbEntity *limb = _limbs[indexPath.section];
    if (indexPath.row == limb.leafs.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
        return cell;
    }
    
    LeafShareCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeafCell"];
    if (!cell) {
        cell = [Utility nibWithName:@"LeafShareCell" index:0];
    }
    LeafEntity *leaf = CRArrayObject(limb.leafs, indexPath.row);
    cell.titleView.text = leaf.title;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    LimbEntity *limb = CRArrayObject(_limbs, indexPath.section);
    LeafEntity *leaf = CRArrayObject(limb.leafs, indexPath.row);
    [self hidden];
    if ([_delegate respondsToSelector:@selector(categoryView:clickLeaf:limb:)]) {
        [_delegate categoryView:self clickLeaf:leaf limb:limb];
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
