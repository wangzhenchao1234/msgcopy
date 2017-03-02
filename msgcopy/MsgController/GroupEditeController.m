//
//  GroupEditeController.m
//  msgcopy
//
//  Created by Gavin on 15/7/10.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "GroupEditeController.h"
#import "ModifyGroupController.h"

static NSString *cellIdentifire = @"cell";

@interface GroupEditeController ()

@end

@implementation GroupEditeController

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
    add.frame = CGRectMake(0, 0, 27, 27);
    [add setImage:[UIImage imageNamed:@"msg_group_new"] forState:UIControlStateNormal];
    add.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [add addTarget:self action:@selector(addGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:add];
    self.navigationItem.rightBarButtonItem = addItem;
    
}
# pragma mark - 添加分组

-(void)addGroup:(id)sender{
    //do something
    ModifyGroupController *modify = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ModifyGroupController"];
    modify.type = MsgGroupEditeTypeAdd;
    modify.pushController = self;
    [self.navigationController pushViewController:modify animated:true];
}
-(void)finishedAddGroup:(ArticleGroupEntity *)group
{
    NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
    [groupDict setObject:group forKey:@"group"];
    [groupDict setObject:@"0" forKey:@"page"];
    [_groupDicts addObject:groupDict];
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
    return _groupDicts.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifire];
    NSDictionary *groupDict = CRArrayObject(_groupDicts, indexPath.row);
    ArticleGroupEntity *group = [Utility dictionaryValue:groupDict forKey:@"group"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (group) {
        cell.textLabel.text = group.title;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除
    NSDictionary *groupDict = CRArrayObject(_groupDicts, indexPath.row);
    ArticleGroupEntity *group = [Utility dictionaryValue:groupDict forKey:@"group"];
    if (group) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        CRWeekRef(self);
        CRWeekRef(hud);
        [MSGRequestManager MKDelete:kAPIGroup(group.gid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__hud hide:true];
            [_groupDicts removeObject:groupDict];
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
    NSDictionary *groupDict = CRArrayObject(_groupDicts, indexPath.row);
    ArticleGroupEntity *group = [Utility dictionaryValue:groupDict forKey:@"group"];
    if (group) {
         ModifyGroupController *editeGroup = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ModifyGroupController"];
        editeGroup.type = MsgGroupEditeTypeModifyName;
        editeGroup.group = group;
        editeGroup.pushController = self;
        [self.navigationController pushViewController:editeGroup animated:true];
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
