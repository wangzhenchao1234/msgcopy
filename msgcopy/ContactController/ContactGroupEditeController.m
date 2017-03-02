//
//  GroupEditeController.m
//  msgcopy
//
//  Created by wngzc on 15/7/10.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ContactGroupEditeController.h"
#import "ModifyGroupController.h"
#import "ChangeAttrController.h"


static NSString *cellIdentifire = @"cell";

@interface ContactGroupEditeController ()

@end

@implementation ContactGroupEditeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configTableView];
}
-(void)configTableView
{
    //config some
    self.title = @"编辑分组";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    add.frame = CGRectMake(0, 0, 46, 27);
//    [add setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [add setTitle:@"新建" forState:UIControlStateNormal];
    add.titleLabel.font = MSGFont(15);
    [add setTitleColor:CRCOLOR_BLACK forState:UIControlStateNormal];
    add.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
//    add.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [add addTarget:self action:@selector(addGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:add];
    self.navigationItem.rightBarButtonItem = addItem;
    
}
# pragma mark - 添加分组

-(void)addGroup:(id)sender{
    //do something
    ChangeAttrController *addGroup = [[ChangeAttrController alloc] initWithTitle:@"添加分组" placeholder:@"分组名称" defautContent:nil completeAction:^(id text) {
        if ([text length] == 0) {
            [CustomToast showMessageOnWindow:@"分组名称不能为空"];
            return;
        }
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        CRWeekRef(self);
        CRWeekRef(hud);
        NSDictionary *params = @{
                                 @"title":text
                                 };
        [MSGRequestManager Post:kAPIAllContactGroup params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__hud hide:true];
            ContactGroupEntity* group = [ContactGroupEntity buildInstanceByJson:data];
            [_groups addObject:group];
            [__self.tableView reloadData];
            [__self.navigationController popViewControllerAnimated:true];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__hud hide:true];
            [CustomToast showMessageOnWindow:msg];
        }];
    }];
    [self.navigationController pushViewController:addGroup animated:true];
}
-(void)finishedAddGroup:(ArticleGroupEntity *)group
{
    [self.tableView reloadData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groups.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifire];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifire];
    }
    ContactGroupEntity *group = CRArrayObject(_groups, indexPath.row);
    if (group) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (group) {
            cell.textLabel.text = group.title;
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除
    ContactGroupEntity *group = CRArrayObject(_groups, indexPath.row);
    if (group) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        CRWeekRef(self);
        CRWeekRef(hud);
        [MSGRequestManager MKDelete:kAPIEditeContactGroup(group.gid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__hud hide:true];
            [_groups removeObject:group];
            [__self.tableView reloadData];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__hud hide:true];
            [CustomToast showMessage:msg in:__self.view];
        }];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.row == 0) {
        return;
    }
    ContactGroupEntity *group = CRArrayObject(_groups, indexPath.row);
    if (group) {
        ChangeAttrController *modify = [[ChangeAttrController alloc] initWithTitle:@"修改分组名称" placeholder:@"分组名称" defautContent:group.title completeAction:^(id text) {
            
            if ([text length] == 0) {
                [CustomToast showMessageOnWindow:@"分组名称不能为空"];
                return ;
            }
            NSDictionary *params = @{
                                     @"title":text
                                     };
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
            hud.removeFromSuperViewOnHide = true;
            [hud show:true];
            [AppWindow addSubview:hud];
            CRWeekRef(self);
            CRWeekRef(hud);
            [MSGRequestManager MKUpdate:kAPIEditeContactGroup(group.gid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [__hud hide:true];
                group.title = text;
                [__self.tableView reloadData];
                [__self.navigationController popViewControllerAnimated:true];
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [__hud hide:true];
                [CustomToast showMessageOnWindow:msg];
            }];
        }];
        [self.navigationController pushViewController:modify animated:true];
    }
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
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
