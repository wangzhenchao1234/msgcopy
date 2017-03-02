//
//  ContactController.m
//  msgcopy
//
//  Created by Gavin on 15/7/25.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ContactController.h"
#import "ContactCell.h"
#import "CenterCrossView.h"
#import "ContactGroupEditeController.h"
#import "LocalContactController.h"
#import "ContactNewController.h"

@interface ContactController ()<CenterCrossViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property(nonatomic,retain)NSMutableArray *groups;
@property(nonatomic,retain)NSMutableArray *allContacts;
@property(nonatomic,retain)NSMutableArray *selectedContacts;
@property(nonatomic,retain)NSMutableArray *searchResultContacts;
@property(nonatomic,retain)CenterCrossView *crossView;
@property(nonatomic,retain)UIButton *droipButton;
@property(nonatomic,assign)UITableViewCellEditingStyle cellEditeStyle;
@property(nonatomic,retain)UIBarButtonItem *editeItem;
@property(nonatomic,retain)UIBarButtonItem *moveItem;
@property(nonatomic,retain)UIBarButtonItem *deleteItem;
@property(nonatomic,retain)UIBarButtonItem *cancelItem;

@property(nonatomic,retain)NSArray *kxmenus;

@end

@implementation ContactController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self configNavigationItems];
    [self intilizedDataSource];
    [self configFooterView];
    [self configTableView];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView.header beginRefreshing];


}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchDisplayController setActive:false];
}
-(void)intilizedDataSource{
    //intilizedDataSource
    
    _cellEditeStyle = UITableViewCellEditingStyleDelete;
    _groups = [[NSMutableArray alloc] init];
    _allContacts = [[NSMutableArray alloc] init];
    _searchResultContacts = [[NSMutableArray alloc] init];
    self.title = @"通讯录";
    
}
-(void)configTableView
{
    //config some
    CRWeekRef(self);
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [__self refresh];
    }];

}

-(void)configFooterView
{
    //config some
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}
-(void)configNavigationItems
{
    //config some
    UIButton *_editeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _editeButton.frame = CGRectMake(0, 0, 27, 27);
    [_editeButton setImage:[UIImage imageNamed:@"ic_drop"] forState:UIControlStateNormal];
    [_editeButton addTarget:self action:@selector(showEditeMenu:) forControlEvents:UIControlEventTouchUpInside];
    _editeItem = [[UIBarButtonItem alloc] initWithCustomView:_editeButton];
    self.navigationItem.rightBarButtonItem = _editeItem;
    
    UIButton *_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.frame = CGRectMake(0, 0, 27, 27);
    [_deleteButton setImage:[UIImage imageNamed:@"ic_delete"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    _deleteItem = [[UIBarButtonItem alloc] initWithCustomView:_deleteButton];
    
    UIButton *_moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _moveButton.frame = CGRectMake(0, 0, 27, 27);
    [_moveButton setImage:[UIImage imageNamed:@"ic_move"] forState:UIControlStateNormal];
    [_moveButton addTarget:self action:@selector(moveClicked:) forControlEvents:UIControlEventTouchUpInside];
    _moveItem = [[UIBarButtonItem alloc] initWithCustomView:_moveButton];
    
    UIButton *_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.frame = CGRectMake(0, 0, 27, 27);
    _cancelButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    [_cancelButton setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    _cancelItem = [[UIBarButtonItem alloc] initWithCustomView:_cancelButton];
    
    
    KxMenuItem *_leadinMenu = [KxMenuItem menuItem:@"导入联系人" image:[UIImage imageNamed:@"ic_inch_contact"] target:self action:@selector(leadinClicked:)];
    KxMenuItem *_createMenu = [KxMenuItem menuItem:@"新建联系人" image:[UIImage imageNamed:@"ic_new_contact"] target:self action:@selector(createClicked:)];
    KxMenuItem *_groupManage = [KxMenuItem menuItem:@"分组管理" image:[UIImage imageNamed:@"ic_contact_group"] target:self action:@selector(groupManageClicked:)];
    KxMenuItem *_batchManage = [KxMenuItem menuItem:@"批量管理" image:[UIImage imageNamed:@"ic_batch"] target:self action:@selector(batchClicked:)];

    _kxmenus = @[_leadinMenu,_createMenu,_groupManage,_batchManage];
    
    _crossView = [Utility nibWithName:@"CenterCrossView" index:0];
    _crossView.delegate = self;

}

-(void)refresh
{
   // CRWeekRef(self);
////    [NSThread detachNewThreadSelector:@selector(refreshLoadData) toTarget:self withObject:nil];
//     NSLog(@"[NSThread currentThread]1==%@",[NSThread currentThread]);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"[NSThread currentThread]2==%@",[NSThread currentThread]);
//        [__self refreshLoadData];
//        
//    });
    [self refreshLoadData];
    //[self refreshLoadData];

}
-(void)refreshLoadData{
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIAllContactGroup params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        NSMutableArray *allGroups = [NSMutableArray new];
        for(NSDictionary* jsonGroup in data)
        {
            ContactGroupEntity* group = [ContactGroupEntity buildInstanceByJson:jsonGroup];
            [allGroups addObject:group];
        }
        __self.groups = allGroups;
        NSMutableArray *gloableContacts = [[NSMutableArray alloc] init];

            [MSGRequestManager Get:kAPIAllContacts params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                    for(NSDictionary* jsonContact in data)
                    {
                        ContactEntity* contact = [ContactEntity buildInstanceByJson:jsonContact];
                        [gloableContacts addObject:contact];
                        __self.allContacts = nil;
                        __self.allContacts = gloableContacts;
                    [__self.groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                            ContactGroupEntity *group = obj;
                            NSLog(@"group==%ld",group.gid);
                            if (contact.parent.gid == group.gid) {
                                [group addContact:contact];
                            }
                        }];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [__self.tableView.header endRefreshing];
                        [__self.tableView reloadData];
                    });


                });

//                for(NSDictionary* jsonContact in data)
//                {
//                    ContactEntity* contact = [ContactEntity buildInstanceByJson:jsonContact];
//                    [gloableContacts addObject:contact];
//                    __self.allContacts = nil;
//                    __self.allContacts = gloableContacts;
//                    
//                    [__self.groups enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                         NSLog(@"[NSThread currentThread]3==%@",[NSThread currentThread]);
//                        ContactGroupEntity *group = obj;
//                        if (contact.parent.gid == group.gid) {
//                            [group addContact:contact];
//                        }
//                    }];
//                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [__self.tableView.header endRefreshing];
//                    [__self.tableView reloadData];
//                });
                //[self.tableView reloadData];
               
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [__self.tableView.header endRefreshing];
                    [CustomToast showMessageOnWindow:msg];
                });
            }];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [__self.tableView.header endRefreshing];
            [CustomToast showMessageOnWindow:msg];
        });
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
# pragma mark - crossViewDelegate
-(NSString*)crossView:(CenterCrossView *)crossView titleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArticleGroupEntity *group = CRArrayObject(_groups, indexPath.row);
    if (group) {
        return group.title;
    }
    return @"";
}
-(NSInteger)crossView:(CenterCrossView *)crossView numberOfRowsInSection:(NSInteger)section
{
    return _groups.count;
}

-(void)crossView:(CenterCrossView *)crossView selectMenuAtIndext:(NSInteger)index
{
    if (_selectedContacts.count>0) {
        
        ContactGroupEntity *group = CRArrayObject(_groups, index);
        __block NSMutableArray *contacts = group.contacts;
        if (group) {
            NSDictionary *params = @{
                                     @"group":CRString(@"%d",group.gid)
                                     };
            __block NSMutableArray *success = [[NSMutableArray alloc] init];
            __block NSMutableArray *failed = [[NSMutableArray alloc] init];
            __block NSUInteger count = _selectedContacts.count;
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.removeFromSuperViewOnHide = true;
            [self.view addSubview:hud];
            [hud show:true];
            CRWeekRef(hud);
            CRWeekRef(self);
            for (int i = 0; i < _selectedContacts.count;i++) {
                __block  ContactEntity *moveContact = _selectedContacts[i];
                NSMutableDictionary *allParams = [[NSMutableDictionary alloc] initWithDictionary:params];
                [allParams addEntriesFromDictionary:@{@"title":moveContact.title,@"phone":moveContact.phone}];
                [MSGRequestManager Update:kAPIEditeContact(moveContact.cid) params:allParams success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                   NSLog(@"msg ------- %@",msg);
                    [success addObject:moveContact];
                    if (success.count + failed.count == count) {
                        [moveContact.parent.contacts removeObjectsInArray:success];
                        [contacts addObjectsFromArray:success];
                        [_selectedContacts removeAllObjects];
                        [__hud hide:true];
                        [CustomToast showMessageOnWindow:CRString(@"成功%d个,失败%d个",success.count,failed.count)];
                        [__self.tableView reloadData];
                    }
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [failed addObject:moveContact];
                    if (success.count + failed.count == count) {
                        [moveContact.parent.contacts removeObjectsInArray:success];
                        [contacts addObjectsFromArray:success];
                        [_selectedContacts removeAllObjects];
                        [__hud hide:true];
                        [CustomToast showMessageOnWindow:CRString(@"成功%d个,失败%d个",success.count,failed.count)];
                        [__self.tableView reloadData];
                    }
                }];
            }
            
        }else{
            [CustomToast showMessageOnWindow:@"获取分组信息失败"];
            
        }
        
    }else{
        [CustomToast showMessageOnWindow:@"请选择若干条内容"];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    return _groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResultContacts.count;
    }
    ContactGroupEntity *group = CRArrayObject(_groups, section);
    if (group.isOpen) {
        return group.contacts.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }
    return 36;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }

    static NSString *headerFooter = @"ContactHeaderFooter";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerFooter];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerFooter];
        UIImageView *flagView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 24, 24)];
        flagView.image = [UIImage imageNamed:@"ic_contact_group"];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(flagView.x + flagView.width + 10, 0, tableView.width - flagView.x - flagView.width - 10 - 10, 36)];
        title.font = MSGFont(14);
        title.tag = 200;
        [header addSubview:flagView];
        [header addSubview:title];
//        
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 1/ScreenScale)];
//        line.backgroundColor = [UIColor colorFromHexRGB:@"9f9fa0"];
//        [header addSubview:line];

        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 36 - 1/ScreenScale, tableView.width, 1/ScreenScale)];
        topLine.backgroundColor = [UIColor colorFromHexRGB:@"9f9fa0"];
        [header addSubview:topLine];
        
        UIButton *action = [UIButton buttonWithType:UIButtonTypeCustom];
        action.frame = CGRectMake(0, 0, tableView.width, 36);
        [action addTarget:self action:@selector(groupOpenAndCloser:) forControlEvents:UIControlEventTouchUpInside];
        [header addSubview:action];
        
        
    }
    UILabel *title = (UILabel*)[header viewWithTag:200];
    __block UIButton *action = nil;
    [header.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            action = obj;
            *stop = true;
        }
    }];
    action.tag = 20 + section;
    ContactGroupEntity *group = CRArrayObject(_groups, section);
    title.text = group.title;
    return header;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifire = @"ContactCell";
    ContactCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifire];
    ContactGroupEntity *group = CRArrayObject(_groups, indexPath.section);
    ContactEntity *contact = CRArrayObject(group.contacts, indexPath.row);
    if (contact) {
        [cell.headView sd_setImageWithURL:CRURL(contact.head50)];
        cell.nickView.text = contact.title;
        cell.phoneView.text = contact.phone;
    }
    // Configure the cell...
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactEntity *contact = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        contact = CRArrayObject(_searchResultContacts, indexPath.section);
        
    }else{
        ContactGroupEntity *group = CRArrayObject(_groups, indexPath.section);
        contact = CRArrayObject(group.contacts, indexPath.row);
    }
    if (contact) {
        if (tableView.editing) {
            [_selectedContacts addObject:contact];
        }else{
            [tableView deselectRowAtIndexPath:indexPath animated:true];
            ContactContentController *content = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ContactContentController"];
            content.contact = contact;
            [self.navigationController pushViewController:content animated:true];
        }
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactGroupEntity *group = CRArrayObject(_groups,indexPath.section);
    if (group) {
        NSMutableArray *contacts = group.contacts;
        __block ContactEntity *contact = CRArrayObject(contacts, indexPath.row);
        if (contact) {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
            hud.removeFromSuperViewOnHide = true;
            [AppWindow addSubview:hud];
            [hud show:true];
            CRWeekRef(self);
            CRWeekRef(hud);
            [MSGRequestManager MKDelete:kAPIEditeContact(contact.cid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [contacts removeObject:contact];
                [_allContacts removeObject:contact];
                [__hud hide:true];
                [__self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [__hud hide:true];
                [CustomToast showMessageOnWindow:msg];
            }];
        }
    }
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellEditeStyle;
    
}

# pragma mark - actions

-(void)groupOpenAndCloser:(UIButton*)sender
{
    NSInteger index = sender.tag - 20;
    ContactGroupEntity *group = CRArrayObject(_groups, index);
    group.isOpen = !group.isOpen;
    [self.tableView reloadData];
}

# pragma mark - 编辑菜单

-(void)showEditeMenu:(id)sender{
    //do something
    UIButton *button = sender;
    CGRect from = [self.navigationController.navigationBar convertRect:button.frame toView:self.navigationController.view];
    [KxMenu showMenuInView:self.navigationController.view fromRect:from menuItems:_kxmenus];

}

# pragma mark - 移动联系人

-(void)moveClicked:(id)sender{
    //do something
    if (_crossView.isShown) {
        [_crossView hidden];
        return;
    }
    [_crossView reloadData];
    [_crossView show];
}
# pragma mark - 删除联系人

-(void)deleteClicked:(id)sender{
    //do something
    if (_selectedContacts.count>0) {
        
        __block NSMutableArray *contacts = self.selectedContacts;

        __block NSMutableArray *success = [[NSMutableArray alloc] init];
        __block NSMutableArray *failed = [[NSMutableArray alloc] init];
        __block NSUInteger count = _selectedContacts.count;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.removeFromSuperViewOnHide = true;
        [self.view addSubview:hud];
        [hud show:true];
        CRWeekRef(hud);
        CRWeekRef(self);
        for (int i = 0; i < _selectedContacts.count;i++) {
            __block  ContactEntity *moveContact = _selectedContacts[i];
            [MSGRequestManager MKDelete:kAPIEditeContact(moveContact.cid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [success addObject:moveContact];
                [_allContacts removeObject:moveContact];
                if (success.count + failed.count == count) {
                    [moveContact.parent.contacts removeObjectsInArray:success];
                    [contacts addObjectsFromArray:success];
                    [_selectedContacts removeAllObjects];
                    [__hud hide:true];
                    [CustomToast showMessageOnWindow:CRString(@"成功%d个,失败%d个",success.count,failed.count)];
                    [__self.tableView reloadData];
                }
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [failed addObject:moveContact];
                if (success.count + failed.count == count) {
                    [moveContact.parent.contacts removeObjectsInArray:success];
                    [contacts addObjectsFromArray:success];
                    [_selectedContacts removeAllObjects];
                    [__hud hide:true];
                    [CustomToast showMessageOnWindow:CRString(@"成功%d个,失败%d个",success.count,failed.count)];
                    [__self.tableView reloadData];
                }
            }];
        }
        
    }else{
        [CustomToast showMessageOnWindow:@"请选择若干条内容"];
    }
}

# pragma mark - 取消

-(void)cancelClicked:(id)sender{
    //do something
    [self.tableView setEditing:false];
    [self.tableView reloadData];
    [self.navigationItem setRightBarButtonItems:@[_editeItem] animated:true];
    self.navigationItem.leftBarButtonItem = nil;
    _cellEditeStyle = UITableViewCellEditingStyleDelete;//设置tableCell的编辑类型
}

# pragma mark - 导入联系人

-(void)leadinClicked:(id)sender{
    //do something
    LocalContactController *local = [Utility controllerInStoryboard:@"Main" withIdentifier:@"LocalContactController"];
    [self.navigationController pushViewController:local animated:true];
}

# pragma mark - 创建联系人

-(void)createClicked:(id)sender{
    //do something
    
    if (_groups.count == 0) {
        [CustomToast showMessageOnWindow:@"请刷新获取分组信息后重试"];
        return;
    }
    ContactNewController *new = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ContactNewController"];
    new.groups = _groups;
    [self.navigationController pushViewController:new animated:true];
    
}
# pragma mark - 分组管理

-(void)groupManageClicked:(id)sender{
    //do something
    ContactGroupEditeController *groupEdite = [[ContactGroupEditeController alloc] initWithStyle:UITableViewStyleGrouped];
    groupEdite.groups = _groups;
    [self.navigationController pushViewController:groupEdite animated:true];
}

# pragma mark - 批量管理

-(void)batchClicked:(id)sender{
    //do something
    [self.selectedContacts removeAllObjects];
    if (!self.selectedContacts) {
        self.selectedContacts = [[NSMutableArray alloc] init];
    }
    _cellEditeStyle = UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
    [self.tableView setEditing:true];
    [self.tableView reloadData];
    [self.navigationItem setRightBarButtonItems:@[_deleteItem,_moveItem] animated:true];
    self.navigationItem.leftBarButtonItem = _cancelItem;
}

# pragma mark - searchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSString *text = searchBar.text;
    NSMutableArray *result = [NSMutableArray new];
    [self.allContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        ContactEntity *contact = obj;
        if ([contact.title containsString:text]||[contact.phone containsString:text]) {
            [result addObject:contact];
        }
    }];
    [_searchResultContacts removeAllObjects];
    [_searchResultContacts addObjectsFromArray:result];
    [self.searchDisplayController.searchResultsTableView reloadData];
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
