//
//  ChangeMoodViewController.m
//  Kaoke
//
//  Created by xiaogu on 14-1-6.
//
//

#import "ChangeMoodController.h"
#import "MoodCell.h"


@interface ChangeMoodController ()<UITextViewDelegate>

@property (retain, nonatomic) UITextView *textInputView;

@end

@implementation ChangeMoodController

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
    [self intilizedDataSource];
    [self setButtons];
	// Do any additional setup after loading the view.
}
-(void)intilizedDataSource{
    //intilizedDataSource
    self.title = @"修改心情";    
}
-(void)resingresponder{
    [_textInputView resignFirstResponder];
}
-(void)setButtons{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 27, 27);
    [button addTarget:self action:@selector(submitChanged:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.textInputView.text = kCurUser.mood;
    [self.textInputView becomeFirstResponder];
}
-(void)submitChanged:(id)sender{
    
    if (_textInputView.text.length >= 30) {
        [CustomToast showMessageOnWindow:@"不能超过字数限制"];
        return;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    [AppWindow addSubview:hud];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
    CRWeekRef(self);
    [kCurUser changeAttr:@"mood" value:_textInputView.text success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        kCurUser.mood = _textInputView.text;
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
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return rowheight
    return 125;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identity = @"MoodCell";
    MoodCell *cell = (MoodCell*)[tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        cell = [Utility nibWithName:@"MoodCell" index:0];
        _textInputView = cell.textInputView;
        _textInputView.font = MSGYHFont(15);
        _textInputView.textAlignment = NSTextAlignmentLeft;
        _textInputView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _textInputView.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    }
    return cell;
}

-(void)dealloc{
    _textInputView = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
