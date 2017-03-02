//
//  LimbManagerController.m
//  msgcopy
//
//  Created by Hackintosh on 15/11/2.
//  Copyright © 2015年 Gavin. All rights reserved.
//

#import "LimbManagerController.h"
#import "LimbHeaderFooterView.h"
#import "LeafManagerCell.h"
#import "EditeLeafView.h"
#import "LimbEditController.h"
#import "ProductController.h"

@interface LimbManagerController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL isEdite;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,retain)NSMutableArray *limbs;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBarView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionItem;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *place1;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *plc2;

@end

@implementation LimbManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    CRWeekRef(self);
    self.title = _shop.title;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [__self loadDatasource];
    }];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [_tableView.header beginRefreshing];
    [self setRightButton];
    [_actionButton setTitle:@"发布商品" forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
}
-(void)setRightButton{

    UIButton *edite = [UIButton buttonWithType:UIButtonTypeCustom];
    edite.frame = CGRectMake(0, 0, 27, 27);
    edite.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [edite setImage:[UIImage imageNamed:@"bt_add_comment"] forState:UIControlStateNormal];
    [edite addTarget:self action:@selector(doEdite:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:edite];
    self.navigationItem.rightBarButtonItem = item;
}
-(void)doEdite:(id)sender{
    isEdite = !isEdite;
    if (!isEdite) {
        [_actionButton setTitle:@"发布商品" forState:UIControlStateNormal];
    }else{
        [_actionButton setTitle:@"添加分类" forState:UIControlStateNormal];
    }
    _toolBarView.items = @[_place1,_actionItem,_plc2];
    [self.tableView reloadData];
}
-(void)loadDatasource{
    
    [MSGRequestManager Get:kAPILimbLeafs(_shop.sid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
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
        [_tableView.header endRefreshing];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [_tableView.header endRefreshing];
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
        LimbHeaderFooterView *contentView = [Utility nibWithName:@"LimbHeaderFooterView" index:0];
        contentView.frame = view.bounds;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [view addSubview:contentView];
        contentView.tag = 100;
        contentView.editeButton.tag = 1000;
        UIButton *action = [UIButton buttonWithType:UIButtonTypeCustom];
        [contentView.editeButton addTarget:self action:@selector(editeLimb:) forControlEvents:UIControlEventTouchUpInside];
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
    LimbHeaderFooterView *header = (LimbHeaderFooterView*)[view viewWithTag:100];
    header.editeButton.tag = 1000 + section;
    header.editeButton.hidden = !isEdite;
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
-(void)editeLimb:(UIButton*)sender{
    NSInteger index = sender.tag - 1000;
    LimbEntity *limb = _limbs[index];
    [self performSegueWithIdentifier:@"showLimbEdite" sender:limb];
    
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
    if (!isEdite) {
        return limb.leafs.count;
    }
    return limb.leafs.count+1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LimbEntity *limb = _limbs[indexPath.section];
    if (indexPath.row == limb.leafs.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
        cell.contentView.backgroundColor = [UIColor colorWithRed:222/255.0f green:232/255.0f blue:232/255.0f alpha:0.3];
        return cell;
    }

    LeafManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeafCell"];
    cell.contentView.backgroundColor = [UIColor colorWithRed:222/255.0f green:222/255.0f blue:222/255.0f alpha:.3];
    LeafEntity *leaf = CRArrayObject(limb.leafs, indexPath.row);
    cell.titleView.text = leaf.title;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];

    LimbEntity *limb = CRArrayObject(_limbs, indexPath.section);
    if (indexPath.row < limb.leafs.count) {
        LeafEntity *leaf = CRArrayObject(limb.leafs, indexPath.row);

        if (isEdite) {
            CRWeekRef(self);
            [EditeLeafView showEdite:leaf complete:^(BOOL confirm) {
                if (confirm) {
                    [__self.tableView reloadData];
                }
            }];

            return;
        }
        
        [self performSegueWithIdentifier:@"ShowGoods" sender:@[_shop,leaf]];
        return;
    }else{
        CRWeekRef(self);
        [EditeLeafView showAdd:limb complete:^(BOOL confirm) {
            if (confirm) {
                [__self.tableView reloadData];
            }
        }];
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showLimbEdite"]) {
        LimbEditController *vc = segue.destinationViewController;
        vc.type = @(1);
        CRWeekRef(self);
        vc.callBacl = ^(BOOL result,id data){
            if (result) {
                [__self.navigationController popViewControllerAnimated:true];
                [__self.tableView reloadData];
            }
        };
        [vc setValue:sender forKey:@"limb"];
    }else if([segue.identifier isEqualToString:@"ShowGoods"]){
        UIViewController *vc = segue.destinationViewController;
        [vc setValue:sender[0] forKey:@"shop"];
        [vc setValue:sender[1] forKey:@"leaf"];
    }else if([segue.identifier isEqualToString:@"AddLimb"]){
        
        LimbEditController *vc = segue.destinationViewController;
        vc.type = AddType;
        vc.shop = _shop;
        CRWeekRef(self);
        vc.callBacl = ^(BOOL result,id data){
            if (result) {
                
                [__self.navigationController popViewControllerAnimated:true];
                [_limbs addObject:data];
                [__self.tableView reloadData];
            }
        };
        [vc setValue:sender forKey:@"limb"];
        
    }else if([segue.identifier isEqualToString:@"AddProduct"]){
        ProductController *vc = segue.destinationViewController;
        [vc setValue:@(0) forKey:@"type"];
        [vc setValue:sender forKey:@"shop"];
        CRWeekRef(self);
        vc.completeCallBack = ^(BOOL result){
            [__self.navigationController popViewControllerAnimated:true];
        };
        
        
    }
    
}
- (IBAction)doAction:(id)sender {
    if (isEdite) {
        [self performSegueWithIdentifier:@"AddLimb" sender:_shop];
        return;
    }
    [self performSegueWithIdentifier:@"AddProduct" sender:_shop];
}


@end
