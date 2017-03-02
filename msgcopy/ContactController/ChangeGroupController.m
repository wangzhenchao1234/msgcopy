//
//  ChangeSexViewController.m
//  Kaoke
//
//  Created by xiaogu on 14-1-6.
//
//

#import "ChangeGroupController.h"

@interface ChangeGroupController ()
{
    NSMutableArray *_groups;
    NSInteger curIndex;
}
@end

@implementation ChangeGroupController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtons];
    [self loadGroup];
    // Do any additional setup after loading the view.
}
-(void)loadGroup
{
    self.title = @"修改分组";
    _groups = [[NSMutableArray alloc] init];
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [AppWindow addSubview:hud];
    [hud show:true];
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIAllContactGroup params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ContactGroupEntity *group = [ContactGroupEntity buildInstanceByJson:obj];
            [_groups addObject:group];
        }];
        [__self.tableView reloadData];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}
-(void)setButtons{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 27, 27);
    [button addTarget:self action:@selector(submitChanged) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

}

-(void)submitChanged{
    
    ContactGroupEntity *group = CRArrayObject(_groups, curIndex);
    if (group) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
        hud.removeFromSuperViewOnHide = true;
        [hud show:true];
        [AppWindow addSubview:hud];
        CRWeekRef(self);
        [_contact changeGroup:group.gid success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            _contact.parent = group;
            [__self.navigationController popViewControllerAnimated:true];
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [hud hide:true];
            [CustomToast showMessageOnWindow:msg];
        }];
    }else{
        [CustomToast showMessageOnWindow:@"请重新选择"];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _groups.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    ContactGroupEntity *group = CRArrayObject(_groups, indexPath.row);
    if (group) {
        cell.textLabel.text = group.title;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (_contact.parent.gid == group.gid) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    curIndex = indexPath.row;
    UITableViewCell *sCell = [self.tableView cellForRowAtIndexPath:indexPath];
    for (UITableViewCell *cell in self.tableView.visibleCells ) {
        if (cell == sCell) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
