//
//  ContactNewController.m
//  msgcopy
//
//  Created by Gavin on 15/7/28.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "ContactNewController.h"
#import "GVPickerView.h"


@interface ContactNewController ()<GVPickerViewDelegate,UITextFieldDelegate>
{
    
    __weak IBOutlet UITableViewCell *groupcell;
    __weak IBOutlet UITableViewCell *titleCell;
    __weak IBOutlet UITableViewCell *phoneCell;
    __weak IBOutlet UITableViewCell *doneCell;
    __weak IBOutlet UITextField *titleInputView;
    __weak IBOutlet UITextField *phoneInputView;
    
    NSInteger curGroup;
    
}
@property(nonatomic,retain)GVPickerView *picker;

@end

@implementation ContactNewController

- (void)viewDidLoad {
    [super viewDidLoad];
    curGroup = 0;
    self.title = @"新建联系人";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    ContactGroupEntity *group = CRArrayObject(_groups, 0);
    if (group) {
        groupcell.textLabel.text = group.title;
    }
    [titleInputView becomeFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
    }
    return 1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                [titleInputView resignFirstResponder];
                [phoneInputView resignFirstResponder];
                if (!_picker) {
                    _picker = [GVPickerView sharedPicker];
                }
                _picker.delegate = self;
                [_picker show];

            }
                break;
            default:
                break;
        }
        
    }else{
        [self doneClick:nil];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return groupcell;
                break;
            case 1:
                titleCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return titleCell;
                break;
            case 2:
                phoneCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return phoneCell;
                break;
            default:
                break;
        }
        
    }
    return doneCell;
}

# pragma mark - PickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(GVPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(GVPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _groups.count;
}

-(NSString*)pickerView:(GVPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    ContactGroupEntity *group = CRArrayObject(_groups, row);
    if (group) {
        return group.title;
    }
    return @"";
}

-(void)changePickerSubmite:(NSIndexPath*)indexPath
{
    curGroup = indexPath.row;
    ContactGroupEntity *group = CRArrayObject(_groups, indexPath.row);
    if (group) {
        groupcell.textLabel.text  = group.title;
    };
}

# pragma mark - textFiledDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == titleInputView) {
        [textField resignFirstResponder];
        while ([titleInputView isFirstResponder]) {
            
        }
        [phoneInputView becomeFirstResponder];
    }else{
        [self doneClick:nil];
    }
    return true;
}

# pragma mark - actions

-(void)doneClick:(id)sender
{
    if (titleInputView.text.length == 0) {
        [CustomToast showMessageOnWindow:@"请输入联系人名称"];
        return;
    }
    
    if (titleInputView.text.length > 20) {
        [CustomToast showMessageOnWindow:@"联系人名称不能多于20个字符"];
        return;
    }
    if (phoneInputView.text.length == 0) {
        [CustomToast showMessageOnWindow:@"请输入手机号"];
        return;
    }
    if (![VerifyHanddler verifyPhone:phoneInputView.text]) {
        [CustomToast showMessageOnWindow:@"请输入正确的手机号格式"];
        return;
    }
    ContactGroupEntity *group = CRArrayObject(_groups, curGroup);
    if (!group) {
        [CustomToast showMessageOnWindow:@"请选择分组"];
        return;
    }
    CRWeekRef(self);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [AppWindow addSubview:hud];
    [hud show:true];
    NSDictionary *params = @{
                             @"title":titleInputView.text,
                             @"phone":phoneInputView.text,
                             @"group":CRString(@"%d",group.gid)
                             };
    
    [MSGRequestManager MKPost:kAPIAllContacts params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        titleInputView.text = nil;
        phoneInputView.text = nil;
        [CustomToast showMessageOnWindow:@"新建成功"];
        [__self.navigationController popViewControllerAnimated:true];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [titleInputView resignFirstResponder];
    [phoneInputView resignFirstResponder];
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
