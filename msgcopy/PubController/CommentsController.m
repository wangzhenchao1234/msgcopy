//
//  CommentsController.m
//  msgcopy
//
//  Created by Gavin on 15/6/29.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "CommentsController.h"
#import "CommentCell.h"
#import "AddCommenController.h"

static NSString *CellIdentfire = @"CommentCell";

@interface CommentsController ()

@property(nonatomic,retain)NSMutableArray *comments;

@end

@implementation CommentsController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configNavigationItem];
    [self configTableView];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
# pragma mark - 评论按钮

-(void)configNavigationItem
{
    
    //config some
    self.title = @"相关评论";
    
    UIButton *edite = [UIButton buttonWithType:UIButtonTypeCustom];
    edite.frame = CGRectMake(0, 0, 27, 27);
    [edite setImage:[UIImage imageNamed:@"msg_create"] forState:UIControlStateNormal];
    edite.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [edite addTarget:self action:@selector(editeAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editeItem = [[UIBarButtonItem alloc] initWithCustomView:edite];
    self.navigationItem.rightBarButtonItem = editeItem;
    
}

# pragma mark - 配置列表

-(void)configTableView
{
    //config some
    self.tableView.tableFooterView = [[UIView alloc] init];
    CRWeekRef(self);
    [self.tableView addHeaderWithCallback:^{
        [__self refreshComments:nil];
    }];
    [self.tableView.header performSelector:@selector(beginRefreshing) withObject:nil afterDelay:1];
    
}

# pragma mark - 添加评论

-(void)refreshComments:(id)sender{
    
    //do something
    CRWeekRef(self);
    [MSGRequestManager Get:kAPIComments(_article.mid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        if (CRJSONIsArray(data)) {
            NSMutableArray *comments = [[NSMutableArray alloc] init];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                CommentEntity *comment = [CommentEntity buildInstanceByJson:obj];
                [comments addObject:comment];
            }];
            __self.comments = comments;
            [__self.tableView.header endRefreshing];
            [__self.tableView reloadData];
        }
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__self.tableView.header endRefreshing];
        [CustomToast showMessageOnWindow:msg];
    }];
    
}


# pragma mark - 刷新

-(void)editeAction:(id)sender{
    //do something
    AddCommenController *add = [Utility controllerInStoryboard:@"Main" withIdentifier:@"AddCommenController"];
    add.article = _article;
    add.pushController = (id<AddCommenControllerDelegate>)self;
    [self.navigationController pushViewController:add animated:true];
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
    return _comments.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentEntity *comment = CRArrayObject(_comments, indexPath.row);
    CGFloat height = 0;
    if (comment) {
        NSInteger mediaCount = comment.images.count + comment.videos.count;// + comment.audios.count;
        height = [CommentCell getHeightWithContent:comment.content mediaCount:mediaCount];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentfire];
    if (!cell) {
        cell = [Utility nibWithName:@"CommentCell" index:0];
    }
    CommentEntity *comment = CRArrayObject(_comments, indexPath.row);
    if (comment) {
        [cell buildByData:comment];
    }
    // Configure the cell...
    return cell;
}
-(void)inSertComment:(CommentEntity*)comment{
    [_comments insertObject:comment atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
