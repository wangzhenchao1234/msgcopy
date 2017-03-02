//
//  ModifyGroupNameController.m
//  msgcopy
//
//  Created by Gavin on 15/7/10.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ModifyGroupController.h"
#import "GroupEditeController.h"
#import "GroupModifyCell.h"

static NSString *CellIdentifire = @"cell";

@interface ModifyGroupController ()
{
    UITextField *_editeFiled;
}


@end

@implementation ModifyGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavigaionItem];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _editeFiled.text = _group.title;
    [_editeFiled becomeFirstResponder];
}
-(void)configNavigaionItem
{
    //config some
    UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
    done.frame = CGRectMake(0, 0, 27, 27);
    [done setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
//    [done setTitle:@"完成" forState:UIControlStateNormal];
    [done setTitleColor:CRCOLOR_BLACK forState:UIControlStateNormal];
    done.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [done addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:done];
    self.navigationItem.rightBarButtonItem = doneItem;
}
# pragma mark - 完成

-(void)submit:(id)sender{
    //do something
    NSString *title = _editeFiled.text;
    if (title.length == 0) {
        [CustomToast showMessageOnWindow:@"请输入内容"];
        return;
    }
    if (!_group) {
        [NSException exceptionWithName:@"空内容" reason:@"group不能为空" userInfo:nil];
    }
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
    [AppWindow addSubview:hud];
    CRWeekRef(self);
    CRWeekRef(hud);
    NSDictionary *params = @{
                             @"title":_editeFiled.text,
                             };
    if (_type == MsgGroupEditeTypeModifyName) {
        [MSGRequestManager MKUpdate:kAPIGroup(_group.gid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__hud hide:true];
            _group.title = title;
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__hud hide:true];
            [CustomToast showMessage:msg in:__self.view];
        }];

    }else if(_type == MsgGroupEditeTypeAdd){
        
        [MSGRequestManager Post:kAPIAllGroup params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__hud hide:true];
            ArticleGroupEntity *group = [ArticleGroupEntity buildInstanceByJson:data];
            [_pushController finishedAddGroup:group];
            [__self.navigationController popViewControllerAnimated:true];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__hud hide:true];
            [CustomToast showMessage:msg in:__self.view];
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupModifyCell *cell = (GroupModifyCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifire];
    // Configure the cell...
    _editeFiled = cell.textFiled;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
