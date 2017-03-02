//
//  ChangeAttrController.m
//  msgcopy
//
//  Created by wngzc on 15/7/27.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "ChangeAttrController.h"

@interface ChangeAttrController ()
@property(nonatomic,copy)void(^callBack)(id data);
@property(nonatomic,retain)UITextField *textInputView;
@property(nonatomic,copy)NSString* defautContent;
@property(nonatomic,copy)NSString* placeholder;

@end

@implementation ChangeAttrController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setButtons];
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _textInputView.text = _defautContent;
    [_textInputView becomeFirstResponder];
}
-(id)initWithTitle:(NSString*)title placeholder:(NSString*)placeholder defautContent:(NSString*)defautContent completeAction:(void(^)(id data))completeAction
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = title;
        _placeholder = placeholder;
        _defautContent = defautContent;
        _callBack = completeAction;
    }
    return self;
}
-(void)setButtons{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 27, 27);
    [button addTarget:self action:@selector(submitChanged) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
}

-(void)submitChanged{
    if (_callBack) {
        _callBack(_textInputView.text);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    // Configure the cell...
    if (!cell) {
        cell = [[MsgTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        _textInputView = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, tableView.width - 20, 44)];
        _textInputView.placeholder = _placeholder;
        [cell.contentView addSubview:_textInputView];
    }
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
