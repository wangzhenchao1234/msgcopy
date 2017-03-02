//
//  ChangeUserNameViewController.m
//  Kaoke
//
//  Created by xiaogu on 14-1-6.
//
//

#import "ChangeNickController.h"

@interface ChangeNickController ()
{
    UITextField *_textInputView;
}
@end

@implementation ChangeNickController

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
    [self intilizedData];
	// Do any additional setup after loading the view.
}

-(void)intilizedData{
    
    self.title = @"修改用户名";
    
}
-(void)setButtons{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    button.frame = CGRectMake(0, 0, 27, 27);
    [button addTarget:self action:@selector(submitChanged) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    _textInputView.text = kCurUser.firstName;
    [_textInputView becomeFirstResponder];
    
}
-(void)resingresponder{
    
    [_textInputView resignFirstResponder];
    
}
-(void)submitChanged{
    
    if (!_textInputView.text||_textInputView.text.length == 0) {
        [CustomToast showMessageOnWindow:@"用户名不能为空"];
        return;
    }else if(_textInputView.text.length >= 32){
        [CustomToast showMessageOnWindow:@"用户名长度不能超过32个字符"];
        return;
    }else if([_textInputView.text isEqualToString:kCurUser.firstName]){
        [self.navigationController popViewControllerAnimated:true];
        return;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    [AppWindow addSubview:hud];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
   
    NSDictionary *params = @{
                             @"first_name":_textInputView.text
                             };
    CRWeekRef(self);
    [MSGRequestManager MKUpdate:kAPIUserSign params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        kCurUser.firstName = _textInputView.text;
        [__self.navigationController popViewControllerAnimated:true];
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentity = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentity];
    if (!_textInputView) {
        _textInputView = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, self.view.frame.size.width - 20, 40)];
        _textInputView.borderStyle = UITextBorderStyleNone;
        _textInputView.keyboardType = UIKeyboardTypeASCIICapable;
        _textInputView.clearButtonMode = UITextFieldViewModeWhileEditing;
        [cell.contentView addSubview:_textInputView];
    }
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
