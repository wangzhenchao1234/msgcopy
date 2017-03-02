//
//  ChangeSexViewController.m
//  Kaoke
//
//  Created by xiaogu on 14-1-6.
//
//

#import "ChangeSexController.h"

@interface ChangeSexController ()
{
    NSString *gender;
}
@end

@implementation ChangeSexController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)onDidAppear:(BOOL)init{
    [super viewDidAppear:init];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtons];
    [self intilizedData];
	// Do any additional setup after loading the view.
}
-(void)intilizedData{
    
    self.title = @"修改性别";
    UserEntity *user = kCurUser;
    if (user.gender == false) {
        gender = @"false";
    }else{
        gender = @"true";
    }

}
-(void)setButtons{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:@"" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    button.frame = CGRectMake(0, 0, 27, 27);
    [button addTarget:self action:@selector(submitChanged) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

}

-(void)submitChanged{
    
    if ([gender boolValue] == kCurUser.gender) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
    [AppWindow addSubview:hud];
    CRWeekRef(self);
    [kCurUser changeAttr:@"gender" value:gender success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        kCurUser.gender = [gender boolValue];
        [__self.navigationController popViewControllerAnimated:true];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    NSArray *array = @[@"男",@"女"];
    cell.textLabel.text = array[indexPath.row];
    if (kCurUser.gender == YES&&indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else if(kCurUser.gender == false && indexPath.row == 1){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    gender = @"false";
    if (indexPath.row == 0) {
        gender = @"true";
    }
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
