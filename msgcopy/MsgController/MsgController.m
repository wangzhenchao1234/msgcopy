//
//  MsgController.m
//  msgcopy
//
//  Created by Gavin on 15/7/7.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "MsgController.h"
#import "MsgThumbnailCell.h"
#import "MsgCell.h"
#import "DropDownloadView.h"
#import "CenterCrossView.h"
#import "CreateMsgController.h"
#import "GroupEditeController.h"

static NSString *TCellIdentifire = @"MsgThumnailCell";
static NSString *CellIdentifire = @"MsgCell";

@interface MsgController ()<UITableViewDataSource,UITableViewDelegate,DropDownloadViewDelegate,CenterCrossViewDelegate>
@property(nonatomic,retain)NSMutableArray *msgGroups;
@property(nonatomic,retain)NSMutableArray *selectedMsgs;
@property(nonatomic,retain)NSMutableArray *msgs;
@property(nonatomic,assign)NSInteger curGroup;
@property (retain, nonatomic) UITableView *tableView;
@property(nonatomic,retain)DropDownloadView *dropView;
@property(nonatomic,retain)CenterCrossView *crossView;
@property(nonatomic,retain)UIButton *droipButton;
@property(nonatomic,assign)UITableViewCellEditingStyle cellEditeStyle;
@property(nonatomic,retain)UIBarButtonItem *editeItem;
@property(nonatomic,retain)UIBarButtonItem *doneItem;
@property(nonatomic,retain)UIToolbar *toolBar;
@property(nonatomic,retain)NSArray *kxmenus;

@end

@implementation MsgController
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
    [self configDropButton];
    [self configToolBar];
    [self configNavigationItems];
    [self intilizedDataSource];
    // Do any additional setup after loading the view.
}
# pragma mark -  初始化tableView

-(void)configTableView
{
    //config some
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
    if (IS_IPHONE4) {
        self.tableView.contentInset = UIEdgeInsetsMake(NAV_H, 0, 0, 0);
    }
    self.tableView.backgroundColor = [UIColor colorFromHexRGB:@"f8f8f8"];
    _cellEditeStyle = UITableViewCellEditingStyleDelete;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    CRWeekRef(self);
    [self.tableView addHeaderWithCallback:^{
        [__self reloadCurGroupData];
    }];
    [self.tableView addFooterWithCallback:^{
        [__self loadMoreGroupData];
    }];
}

# pragma mark - dropButton

-(void)configDropButton
{
    //config some
    _dropView = [Utility nibWithName:@"DropDownloadView" index:0];
    _dropView.delegate = self;
    [_dropView.cancelButton setTitle:@"编辑分组" forState:UIControlStateNormal];
    [_dropView.cancelButton setTitleColor:[UIColor colorFromHexRGB:@"838383"] forState:UIControlStateNormal];

    [_dropView.cancelButton setImage:[UIImage imageNamed:@"msg_group_add"] forState:UIControlStateNormal];
    [_dropView.cancelButton setTintColor:[UIColor colorFromHexRGB:@"838383"]];
    
    _droipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _droipButton.titleLabel.font = MSGFont(18);
    [_droipButton setTitleColor:CRCOLOR_BLACK forState:UIControlStateNormal];
    [_droipButton setTitle:@"我的收藏" forState:UIControlStateNormal];
    [_droipButton setImage:[UIImage imageNamed:@"ic_drop_down"] forState:UIControlStateNormal];
    [_droipButton sizeToFit];
    [_droipButton setImageEdgeInsets:UIEdgeInsetsMake(0, _droipButton.width+5, 0, -_droipButton.width+5)];
    [_droipButton addTarget:self action:@selector(dropMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _droipButton;
    
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
    
    KxMenuItem *_editeMenu = [KxMenuItem menuItem:@"编辑" image:[UIImage imageNamed:@"msg_group_edite"] target:self action:@selector(editeClicked:)];
    KxMenuItem *_createMenu = [KxMenuItem menuItem:@"新建" image:[UIImage imageNamed:@"msg_create"] target:self action:@selector(createClicked:)];
    _kxmenus = @[_editeMenu,_createMenu];
    
    UIButton *_doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _doneButton.frame = CGRectMake(0, 0, 45, 27);
    [_doneButton setTitle:@"完成" forState:UIControlStateNormal];
    _doneButton.titleLabel.font = MSGFont(15);
    [_doneButton setTitleColor:[UIColor colorFromHexRGB:@"393939"] forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
    _doneItem = [[UIBarButtonItem alloc] initWithCustomView:_doneButton];
    
}

# pragma mark - 显示菜单

-(void)showEditeMenu:(id)sender{
    //do something
    UIButton *button = sender;
    CGRect from = [self.navigationController.navigationBar convertRect:button.frame toView:self.navigationController.view];
    [KxMenu showMenuInView:self.navigationController.view fromRect:from menuItems:_kxmenus];
}


# pragma mark - 编辑

-(void)editeClicked:(id)sender{
    //do something
    [self.selectedMsgs removeAllObjects];
    if (!self.selectedMsgs) {
        self.selectedMsgs = [[NSMutableArray alloc] init];
    }
    [self showToolBar];
    _cellEditeStyle = UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
    [self.tableView setEditing:true];
    [self.tableView reloadData];
    [self.navigationItem setRightBarButtonItems:@[_doneItem] animated:true];
    [self.navigationItem setHidesBackButton:true animated:true];
    
}

# pragma mark - 新建投稿
-(void)createClicked:(id)sender{
    //do something
    CreateMsgController *creat = [Utility controllerInStoryboard:@"Main" withIdentifier:@"CreateMsgController"];
    creat.groupDicts = _msgGroups;
    creat.pushController = self;
    [self.navigationController pushViewController:creat animated:true];

}
# pragma mark - 取消编辑

-(void)doneClicked:(id)sender{
    //do something
    [self hiddenToolBar];
    [self.tableView setEditing:false];
    [self.tableView reloadData];
    [self.navigationItem setRightBarButtonItems:@[_editeItem] animated:true];
    [self.navigationItem setHidesBackButton:false animated:true];
    _cellEditeStyle = UITableViewCellEditingStyleDelete;//设置tableCell的编辑类型
}

-(void)configToolBar
{
    //config some
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height,self.view.width , 44)];
    [self.view addSubview:_toolBar];
    
    UIButton *_moveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _moveButton.frame = CGRectMake(0, 0, 44, 27);
    [_moveButton setTitle:@"移至" forState:UIControlStateNormal];
    [_moveButton setTitleColor:[UIColor colorFromHexRGB:@"23ad69"] forState:UIControlStateNormal];
    [_moveButton addTarget:self action:@selector(moveClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *_moveItem = [[UIBarButtonItem alloc] initWithCustomView:_moveButton];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIButton *_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.frame = CGRectMake(0, 0, 44, 27);
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteButton setTitleColor:[UIColor colorFromHexRGB:@"23ad69"] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *_deleteItem = [[UIBarButtonItem alloc] initWithCustomView:_deleteButton];
    _toolBar.items = @[_moveItem,space,_deleteItem];
    
    _crossView = [Utility nibWithName:@"CenterCrossView" index:0];
    _crossView.delegate = self;
    
}
# pragma mark - 显示toolbar

-(void)showToolBar
{
    [UIView animateWithDuration:.35 animations:^{
        _toolBar.y = self.view.height - _toolBar.height;
    }];
}

# pragma mark - 隐藏toolbar
-(void)hiddenToolBar
{
    [UIView animateWithDuration:.35 animations:^{
        _toolBar.y = self.view.height;
    }];
}

# pragma mark - 移动

-(void)moveClicked:(id)sender{
    //do something
    if (_crossView.isShown) {
        [_crossView hidden];
        return;
    }
    [_crossView reloadData];
    [_crossView show];
    
}

# pragma mark - crossViewDelegate
-(NSString*)crossView:(CenterCrossView *)crossView titleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *groupDict = CRArrayObject(_msgGroups, indexPath.row);
    if (groupDict) {
        ArticleGroupEntity *group = groupDict[@"group"];
        if (group) {
            return group.title;
        }
    }
    return @"";
}
-(NSInteger)crossView:(CenterCrossView *)crossView numberOfRowsInSection:(NSInteger)section
{
    return _msgGroups.count;
}
-(void)crossView:(CenterCrossView *)crossView selectMenuAtIndext:(NSInteger)index
{
    if (_curGroup == index) {
        return;
    }
    if (_selectedMsgs.count>0) {
        NSMutableDictionary *groupDict = CRArrayObject(_msgGroups,index);
        NSMutableDictionary *curGroupDict = CRArrayObject(_msgGroups,_curGroup);
        if (groupDict) {
            ArticleGroupEntity *group = groupDict[@"group"];
            NSMutableArray *msgs = groupDict[@"msgs"];
            NSMutableArray *curMsgs = curGroupDict[@"msgs"];

            if (group) {
                NSDictionary *params = @{
                                         @"group":CRString(@"%d",group.gid)
                                         };
                __block NSMutableArray *success = [[NSMutableArray alloc] init];
                __block NSMutableArray *failed = [[NSMutableArray alloc] init];
                __block NSUInteger count = _selectedMsgs.count;
                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
                hud.removeFromSuperViewOnHide = true;
                [self.view addSubview:hud];
                [hud show:true];
                CRWeekRef(hud);
                CRWeekRef(self);
                for (int i = 0; i < _selectedMsgs.count;i++) {
                    __block  ArticleEntity *moveArticle = _selectedMsgs[i];
                    [MSGRequestManager Update:kAPIMsgMove(moveArticle.mid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [success addObject:moveArticle];
                        if (success.count + failed.count == count) {
                            [curMsgs removeObjectsInArray:success];
                            [msgs addObjectsFromArray:success];
                            [_selectedMsgs removeAllObjects];
                            [__hud hide:true];
                            [CustomToast showMessageOnWindow:CRString(@"成功%d个,失败%d个",success.count,failed.count)];
                            [__self.tableView reloadData];
                        }
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [failed addObject:moveArticle];
                        if (success.count + failed.count == count) {
                            [curMsgs removeObjectsInArray:success];
                            [msgs addObjectsFromArray:success];
                            [_selectedMsgs removeAllObjects];
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
            [CustomToast showMessageOnWindow:@"获取分组信息失败"];
        }
    }else{
        [CustomToast showMessageOnWindow:@"请选择若干条内容"];
    }

}

# pragma mark - 删除

-(void)deleteClicked:(id)sender{
    //do something
    NSMutableDictionary *groupDict = CRArrayObject(_msgGroups,_curGroup);
    if (groupDict) {
        NSMutableArray *msgs = groupDict[@"msgs"];
        if (msgs.count == 0) {
            [CustomToast showMessageOnWindow:@"当前分组没有内容"];
        }else if(_selectedMsgs.count == 0){
            [CustomToast showMessageOnWindow:@"请选择若干条内容"];
        }else{
            __block NSMutableArray *success = [[NSMutableArray alloc] init];
            __block NSMutableArray *failed = [[NSMutableArray alloc] init];
            __block NSUInteger count = _selectedMsgs.count;
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
            hud.removeFromSuperViewOnHide = true;
            [self.view addSubview:hud];
            [hud show:true];
            CRWeekRef(hud);
            CRWeekRef(self);
            for (int i = 0; i < _selectedMsgs.count;i++) {
                __block  ArticleEntity *moveArticle = _selectedMsgs[i];
                [MSGRequestManager MKDelete:kAPIMSG(moveArticle.mid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [success addObject:moveArticle];
                    if (success.count + failed.count == count) {
                        [msgs removeObjectsInArray:success];
                        [_selectedMsgs removeAllObjects];
                        [__hud hide:true];
                        [CustomToast showMessageOnWindow:CRString(@"成功%d个,失败%d个",success.count,failed.count)];
                        [__self.tableView reloadData];
                    }
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [failed addObject:moveArticle];
                    if (success.count + failed.count == count) {
                        [msgs removeObjectsInArray:success];
                        [_selectedMsgs removeAllObjects];
                        [__hud hide:true];
                        [CustomToast showMessageOnWindow:CRString(@"成功%d个,失败%d个",success.count,failed.count)];
                        [__self.tableView reloadData];
                    }
                }];
            }
        }
    }
    
}


# pragma mark - 点击下拉菜单

-(void)dropMenuClick:(id)sender{
    //do something
    if (_dropView.isShown) {
        [_dropView hidden];
        return;
    }
    [_dropView reloadData];
    [_dropView show];
    
}
# pragma mark - DropViewDelegate

-(NSString*)dropView:(DropDownloadView *)dropView titleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *groupDict = CRArrayObject(_msgGroups, indexPath.row);
    if (groupDict) {
        ArticleGroupEntity *group = groupDict[@"group"];
        if (group) {
            return group.title;
        }
    }
    return @"";
}
-(NSInteger)dropView:(DropDownloadView *)dropView numberOfRowsInSection:(NSInteger)section
{
    return _msgGroups.count;
}
-(void)dropView:(DropDownloadView *)dropView selectMenuAtIndext:(NSInteger)index
{
    NSMutableDictionary *groupDict = CRArrayObject(_msgGroups,index);
    NSString *title = @"";
    if (groupDict) {
        ArticleGroupEntity *group = groupDict[@"group"];
        if (group) {
            title = group.title;
        }
    }
    [_droipButton setTitle:title forState:UIControlStateNormal];
    [_droipButton sizeToFit];
    [_droipButton setImageEdgeInsets:UIEdgeInsetsMake(0, _droipButton.width+5, 0, -_droipButton.width+5)];
    self.navigationItem.titleView = _droipButton;
    if (_curGroup!= index) {
        
        _curGroup = index;
        NSArray *msgs = [Utility dictionaryValue:groupDict forKey:@"msgs"];
        if (msgs.count == 0) {
            [self.tableView.header beginRefreshing];
        }else{
            [self.tableView.footer resetNoMoreData];
            [self.tableView reloadData];
        }
    }
}
-(void)cancelButtonClicked
{
    GroupEditeController *groupEdite = [Utility controllerInStoryboard:@"Main" withIdentifier:@"GroupEditeController"];
    groupEdite.groupDicts = _msgGroups;
    [self.navigationController pushViewController:groupEdite animated:true];
}

# pragma mark - 初始化数据

-(void)intilizedDataSource{
    //intilizedDataSource
    _curGroup = 0;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = true;
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIAllGroup params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        if (CRJSONIsArray(data)) {
            NSMutableArray *groups = [[NSMutableArray alloc] init];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
                ArticleGroupEntity *group = [ArticleGroupEntity buildInstanceByJson:obj];
                [groupDict setObject:group forKey:@"group"];
                [groups addObject:groupDict];
            }];
            _msgGroups = groups;
            [__self.tableView.header beginRefreshing];
        }else{
            [CustomToast showMessageOnWindow:@"发生未知错误"];
        }
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}
# pragma mark - 下拉刷新

-(void)reloadCurGroupData
{
    __block NSMutableDictionary *groupDict = CRArrayObject(_msgGroups, _curGroup);
    if (groupDict) {
        ArticleGroupEntity *group = groupDict[@"group"];
        __block NSInteger page = 1;
        CRWeekRef(self);
        [MSGRequestManager Get:kAPIMsgs(group.gid, page) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            if (CRJSONIsDictionary(data)) {
                NSArray *articles = data[@"articles"];
                NSMutableArray *msgs = [[NSMutableArray alloc] init];
                [articles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    ArticleEntity *msg = [ArticleEntity buildInstanceByJson:obj];
                    [msgs addObject:msg];
                }];
                if (msgs.count<20) {
                    [__self.tableView.footer noticeNoMoreData];
                }else{
                    [__self.tableView.footer resetNoMoreData];
                }
                [groupDict setObject:msgs forKey:@"msgs"];
                [groupDict setObject:CRString(@"%d",page) forKey:@"page"];
                [__self.tableView reloadData];
            }else{
                [CustomToast showMessageOnWindow:@"发生未知错误"];
            }
            [__self.tableView.header endRefreshing];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [CustomToast showMessageOnWindow:msg];
        }];
    }
}

# pragma mark - 加载更多

-(void)loadMoreGroupData
{
    __block NSMutableDictionary *groupDict = CRArrayObject(_msgGroups, _curGroup);
    if (groupDict) {
        ArticleGroupEntity *group = groupDict[@"group"];
        NSString *pageStr = groupDict[@"page"];
        __block NSInteger page = pageStr?[pageStr integerValue]+1:1;
        CRWeekRef(self);
        [MSGRequestManager Get:kAPIMsgs(group.gid, page) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            if (CRJSONIsDictionary(data)) {
                NSArray *articles = data[@"articles"];
                NSMutableArray *msgs = [[NSMutableArray alloc] init];
                [articles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    ArticleEntity *msg = [ArticleEntity buildInstanceByJson:obj];
                    [msgs addObject:msg];
                }];
                if (msgs.count<20) {
                    [__self.tableView.footer noticeNoMoreData];
                }
                NSMutableArray *oldMsgs = [Utility dictionaryValue:groupDict forKey:@"msgs"];
                if (msgs.count>0) {
                    if (oldMsgs) {
                        [oldMsgs addObjectsFromArray:msgs];
                        [groupDict setObject:oldMsgs forKey:@"msgs"];
                    }else{
                        [groupDict setObject:msgs forKey:@"msgs"];
                    }
                    [groupDict setObject:CRString(@"%d",page) forKey:@"page"];
                    [__self.tableView reloadData];
                }
                
            }else{
                [CustomToast showMessageOnWindow:@"发生未知错误"];
            }
            [__self.tableView.footer endRefreshing];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [CustomToast showMessageOnWindow:msg];
        }];
    }
}
# pragma mark - 插入一条收藏

-(void)insertMsg:(ArticleEntity*)msg toGroup:(NSInteger)index
{
    NSMutableDictionary *groupDict = _msgGroups[index];
    NSMutableArray *msgs = [Utility dictionaryValue:groupDict forKey:@"msgs"];
    if (!msgs) {
        msgs = [[NSMutableArray alloc] init];
        [msgs insertObject:msg atIndex:0];
        [groupDict setObject:msgs forKey:@"msgs"];
    }else{
        [msgs insertObject:msg atIndex:0];
    }
    [self.tableView reloadData];
}


# pragma mark - tableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableDictionary *groupDict = CRArrayObject(_msgGroups, _curGroup);
    if (groupDict) {
        NSArray *msgs = groupDict[@"msgs"];
        if (msgs) {
            return msgs.count;
        }
 
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.001;
    NSDictionary *groupDict = CRArrayObject(_msgGroups, _curGroup);
    if (groupDict) {
        NSArray *msgs = [Utility dictionaryValue:groupDict forKey:@"msgs"];
        ArticleEntity *msg = CRArrayObject(msgs, indexPath.row);
        if (msg) {
            if (!msg.thumbnail) {
                height = [MsgCell cellHeight];
            }else{
                height =[MsgThumbnailCell cellHeight];
            }
        }
    }
    return ceil(height);
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *groupDict = CRArrayObject(_msgGroups, _curGroup);
    if (groupDict) {
        NSMutableArray *msgs = [Utility dictionaryValue:groupDict forKey:@"msgs"];
        __block ArticleEntity *article = CRArrayObject(msgs, indexPath.row);
        if (article) {
            MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
            hud.removeFromSuperViewOnHide = true;
            [AppWindow addSubview:hud];
            [hud show:true];
            CRWeekRef(self);
            CRWeekRef(hud);
            [MSGRequestManager MKDelete:kAPIMSG(article.mid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [msgs removeObject:article];
                [__hud hide:true];
                [__self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                [__hud hide:true];
                [CustomToast showMessageOnWindow:msg];
            }];
        }
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *groupDict = CRArrayObject(_msgGroups, _curGroup);
    if (groupDict) {
        NSArray *msgs = [Utility dictionaryValue:groupDict forKey:@"msgs"];
        ArticleEntity *msg = CRArrayObject(msgs, indexPath.row);
        if (msg.thumbnail.turl) {
            MsgThumbnailCell *cell = [tableView dequeueReusableCellWithIdentifier:TCellIdentifire];
            if (!cell) {
                cell = [Utility nibWithName:@"MsgThumbnailCell" index:0];
            }
            [cell buildWithData:msg];
            return cell;
        }
        MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire];
        if (!cell) {
            cell = [Utility nibWithName:@"MsgCell" index:0];
        }
        [cell buildWithData:msg];
        return cell;
    }else{
        MsgThumbnailCell *cell = [tableView dequeueReusableCellWithIdentifier:TCellIdentifire];
        if (!cell) {
            cell = [Utility nibWithName:@"MsgThumbnailCell" index:0];
        }
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *groupDict = CRArrayObject(_msgGroups, _curGroup);
    if (groupDict) {
        NSArray *msgs = [Utility dictionaryValue:groupDict forKey:@"msgs"];
        ArticleEntity *msg = CRArrayObject(msgs, indexPath.row);
        if (msg) {
            if (tableView.editing) {
                [_selectedMsgs addObject:msg];
            }else{
                [tableView deselectRowAtIndexPath:indexPath animated:true];
                [MsgOpenHandler openWithMsgID:msg.mid placeholderView:nil];
            }
        }
    }
    
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellEditeStyle;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
