//
//  AddCommentControllerTableViewController.m
//  msgcopy
//
//  Created by Gavin on 15/7/1.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "AddCommenController.h"
#import "CommentsController.h"
#import "AddCommentContentCell.h"
#import "AddCommentHeaderView.h"
#import "AddCommentFooterView.h"

#define TopHeight  0//79
#define FooterHeight (AppWindow.width-10)+10

static NSString *CellIdentifire = @"AddCommentContentCell";

@interface AddCommenController ()<UITableViewDelegate,UITableViewDataSource,AddCommentContentCellDelegate>
{
    AddCommentContentCell *contentCell;
    __block NSDictionary   *userPoint;

    
}
@property(nonatomic,retain)AddCommentHeaderView *header;
@property(nonatomic,retain)AddCommentFooterView *footer;


@end

@implementation AddCommenController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configNavigationItem];
//    [self configHeaderView];
    [self configFooterView];
    [self configToolBar];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_defaultContent) {
        contentCell.textView.text = _defaultContent;
    }
}
# pragma mark - 添加导航栏按钮

-(void)configNavigationItem
{
    //config some
    self.attaches = [[NSMutableArray alloc] init];
    self.title = @"评论";
    UIButton *submite = [UIButton buttonWithType:UIButtonTypeCustom];
    submite.frame = CGRectMake(0, 0, 27, 27);
    submite.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [submite setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
    [submite addTarget:self action:@selector(submite:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *submiteItem = [[UIBarButtonItem alloc] initWithCustomView:submite];
    self.navigationItem.rightBarButtonItem = submiteItem;
    
}
# pragma mark - headerView

-(void)configHeaderView
{
    //config some
    _header = [Utility nibWithName:NSStringFromClass([AddCommentHeaderView class]) index:0];
    _header.height = TopHeight;
    _header.width = self.view.width;
    NSString *url = [self getImageUrl];
    [_header.imageView sd_setImageWithURL:CRURL(url) placeholderImage:ImagePlaceImage];
    self.tableView.tableHeaderView = _header;
}
# pragma mark - footerView

-(void)configFooterView
{
    //config some
    if (IS_IPHONE4) {
        self.tableView.contentInset = UIEdgeInsetsMake(NAV_H, 0, 0, 0);
    }
    _footer = [Utility nibWithName:NSStringFromClass([AddCommentFooterView class]) index:0];
    _footer.height = FooterHeight;
    _footer.width = self.view.width;
    self.tableView.tableFooterView = _footer;
}

# pragma mark - 工具栏

-(void)configToolBar
{
    //config some
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    self.toolBar.backgroundColor = CRCOLOR_WHITE;
    self.toolBar.tintColor = CRCOLOR_BLACK;
    
    [self.view addSubview:self.toolBar];
    
    UIBarButtonItem *emotion = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cm_face"] style:UIBarButtonItemStyleDone target:self action:@selector(addEmotion:)];
    UIBarButtonItem *image = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cm_picture"] style:UIBarButtonItemStyleDone target:self action:@selector(addImage:)];
    UIBarButtonItem *video = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cm_video"] style:UIBarButtonItemStyleDone target:self action:@selector(addVideo:)];

    UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolBar.items = @[emotion,space1,image,space2,video];

}


# pragma mark - imageUrl

-(NSString*)getImageUrl{
    
    if (_article.thumbnail) {
        return _article.thumbnail.turl;
    }
    NSString *imageUrl = nil;
    NSArray *images = _article.images.count>0?_article.images:_article.imageSet.images;
    if (images.count>0) {
        KaokeImage *img = images[0];
        imageUrl = img.ourl;
    }
    return imageUrl;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addImage:(id)sender
{
    if (self.facialShown) {
        [self hiddenEmotionView];
    }else{
        [contentCell.textView resignFirstResponder];
    }
    [super addImage:sender];
}
-(void)addVideo:(id)sender{
    if (self.facialShown) {
        [self hiddenEmotionView];
    }else{
        [contentCell.textView resignFirstResponder];
    }
    [super addVideo:sender];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddCommentContentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire];
    if (!cell) {
        cell = [Utility nibWithName:@"AddCommentContentCell" index:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    contentCell = cell;
    contentCell.textView.delegate = self;
    contentCell.deletate = self;
    // Configure the cell...
    
    return cell;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSString *sizeKey = NSStringFromSelector(@selector(contentSize));
    if ([keyPath isEqualToString:sizeKey]) {
        [self performSelectorOnMainThread:@selector(adjustFrame:) withObject:nil waitUntilDone:true];
    }
}
# pragma mark - 调整高度

-(void)adjustFrame:(id)sender{
    
    //do something
    CGSize size = contentCell.textView.contentSize;
    CGRect frame = contentCell.textView.frame;
    frame.size.height = size.height;
    contentCell.textView.frame = frame;
    CGRect cellFrame = contentCell.frame;
    cellFrame.size.height = contentCell.topConstraint.constant + contentCell.bottomConstranit.constant + frame.size.height;
    contentCell.frame = cellFrame;
    CGSize tableSize = self.tableView.contentSize;
    CGFloat height = TopHeight + FooterHeight + contentCell.height;
    tableSize.height = height;
    self.tableView.contentSize = tableSize;
    _footer.y = TopHeight + contentCell.height;

}
# pragma mark - actions

-(void)updateMediaView:(NSArray *)attachs
{
    [_footer reloadWithAttachs:self.attaches];
}

# pragma mark - 判断字符串中是否全是空格

- (BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        
        return true;
        
    } else {
        
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            
            return true;
            
        } else {
            
            return false;
            
        }
        
    }
    
}


# pragma mark - 提交

-(void)submite:(id)sender{
    
    //do something
    if (self.attaches.count == 0 && contentCell.textView.text.length == 0 ) {
        [CustomToast showMessageOnWindow:@"您没有输入任何内容"];
        return;
    }
    
    if ([self isEmpty:contentCell.textView.text]) {
        [CustomToast showMessageOnWindow:@"评论不能全部为空格"];
        return;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [AppWindow addSubview:hud];
    [hud show:true];
    if (contentCell.textView.text.length == 0) {
        contentCell.textView.text = @"";
    }
    __block CommentEntity *comment = nil;
    NSDictionary *params = @{
                             @"content":contentCell.textView.text
                             };
    CRWeekRef(self);
    [MSGRequestManager Post:kAPINewPubComment(_article.mid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        comment = [CommentEntity buildInstanceByJson:data];
        if (self.attaches.count>0&&comment) {
            hud.labelText = @"正在上传第1个附件";
            __block NSInteger count = self.attaches.count;
            for (NSDictionary *attach in self.attaches) {
                
                NSString *name = attach[@"name"];
                NSString *filePath = CRUploadFilePath(name);
                NSData * ds = [NSData dataWithContentsOfFile:filePath];
                NSData *thData = nil;
                if ([attach[@"type"] isEqualToString:@"video"]) {
                    NSString *tName = attach[@"thumbnail"];
                    UIImage *thumbnail = [UIImage imageWithContentsOfFile:CRUploadFilePath(tName)];
                    if (UIImagePNGRepresentation(thumbnail) == nil) {
                        thData = UIImageJPEGRepresentation(thumbnail, 1);
                    } else {
                        thData = UIImagePNGRepresentation(thumbnail);
                    }
                }
                __block BOOL finished = false;
                [UploadManager uploadFile:ds type:attach[@"type"] name:name success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    MediaEntity* media = data;
                    NSString *descr = contentCell.textView.text.length >= 24?[contentCell.textView.text substringToIndex:23]:contentCell.textView.text;
                    [UploadManager uploadCommentMedia:media.mid descr:descr fType:media.fType thumnail:thData success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        ArticleMediaEntity *aMedia = data;
                        NSDictionary *params = @{
                                                 @"obj":CRString(@"%d",aMedia.aid)
                                                 };
                        [MSGRequestManager MKUpdate:kAPILinkCommentMedia(comment.cid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                            finished = true;
                            --count;
                            NSInteger index = self.attaches.count - count;
                            hud.labelText = CRString(@"正在上传第%d个附件",index);
                            if (count == 0) {
                                [__self uploadFinished:comment];
                            }
                        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                            --count;
                            NSInteger index = self.attaches.count - count;
                            hud.labelText = CRString(@"正在上传第%d个附件",index);
                            if (count == 0) {
                                [__self uploadFinished:comment];
                            }
                            finished = true;
                        }];
                        
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        finished = true;
                        --count;
                        NSInteger index = self.attaches.count - count;
                        hud.labelText = CRString(@"正在上传第%d个附件",index);
                        if (count == 0) {
                            [__self uploadFinished:comment];
                        }

                    }];
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    finished = true;
                    --count;
                    NSInteger index = self.attaches.count - count;
                    hud.labelText = CRString(@"正在上传第%d个",index);
                    if (count == 0) {
                        [__self uploadFinished:comment];
                    }
                }];
                
            }
            
        }else{
            //评论成功
            [__self uploadFinished:comment];
            [hud hide:true];
        }

    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
        return;
    }];
   
}
-(void)uploadFinished:(CommentEntity*)comment{

    CRWeekRef(self);
    MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
    CRWeekRef(hud);
    [MSGRequestManager Get:kAPIComment(comment.cid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__hud hide:true];
        CommentEntity *comment = [CommentEntity buildInstanceByJson:data];
        //评论成功
        [ScoreUserActionManager doUserAction:USER_COMMENT_ACTION user:kCurUser.userName currentStatus:true success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            
            userPoint = nil;
            if (CRWebAppTitle(@"pointmanage")) {
                MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
                if (!hud) {
                    hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
                    [AppWindow addSubview:hud];
                    hud.removeFromSuperViewOnHide = true;
                }
                [hud show:true];
                CRWeekRef(self);
                [MSGRequestManager Get:kAPIPoint params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    
//                                NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!data - %@",data);
                    
                    //获取积分状态
                    userPoint = data;
                    [ScoreUserActionManager getAllUserActionStatus:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        __block NSDictionary *pointPub = nil;
                        NSArray * pointsJson = data;
                        [pointsJson enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            if ([obj[@"content_type"] isEqualToString:USER_COMMENT_ACTION]) {
                                pointPub = obj;
                                
//                                 NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!pointPub - %@",pointPub);
                                
                                *stop = true;
                            }
                        }];
                        //积分启用状态
                        NSInteger i = 0;
                        ++i;
                        NSInteger ciShu = [pointPub[@"maxnum"] integerValue];
                        //积分启用状态
                        if ([pointPub[@"openstatus"] boolValue]&&[pointPub[@"status"] boolValue]&&i<=ciShu) {
                            
                            
//                                         NSLog(@"。。。。。。。。。积分启用状态。。。。。。。。");
                            
                            
                            NSInteger point = [pointPub[@"point"] longLongValue];
                            
//                                                NSLog(@"。。。。。。。。。%d。。。。。。。。",point);
                            
                            NSString *type = pointPub[@"point_type"];
                            
//                                                NSLog(@"..............%@......",type);
//                         [CustomToast showMessageOnWindow:CRString(@"您的积分增加：%d",point)];
                            //加积分不提示
                            
                        }else{
                            //积分未启用直接跳过检查
                        }
                        
                    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                        [hud hide:true];
                        [GVConfirmView showConfirm:@"系统出错，无法继续操作" inView:AppWindow confirmButton:@"确定" action:^{
                            [__self.navigationController popViewControllerAnimated:true];
                        }cancelTitle:nil action:nil];
                        
                    }];
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    [hud hide:true];
                    [GVConfirmView showConfirm:@"系统出错，无法继续操作" inView:AppWindow confirmButton:@"确定" action:^{
                        [__self.navigationController popViewControllerAnimated:true];
                    }cancelTitle:nil action:nil];
                }];
            }

            CRLog(@"评论积分++");
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            CRLog(@"%@",msg);

        }];
        if (_article&&_article.pubid!=0) {
            PubEntity *pub = [[PubEntity alloc] init];
            pub.pid = _article.pubid;
            pub.title = _article.title;
            [UserActionManager userAddComments:pub];
        }
        if ([__self.pushController respondsToSelector:@selector(inSertComment:)]) {
            [__self.pushController inSertComment:comment];
            [__self.navigationController popToViewController:(UIViewController*)__self.pushController animated:true];
        }
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__hud hide:true];
        [CustomToast showMessageOnWindow:msg];
    }];
}
# pragma mark - scrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.facialShown) {
        [self hiddenEmotionView];
    }
    [contentCell.textView resignFirstResponder];
}

# pragma mark -  textViewDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.facialShown) {
        [self hiddenEmotionView];
    }
    self.tableView.height -= [CRKeyboardUtility keyboardFrame].size.height;
    [self adjustFrame:nil];
    [self adjustOffsite];
    [self adjustToolBar];
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.tableView.height = self.view.height;
    [self adjustFrame:nil];
    [self adjustToolBar];
}
-(void)textViewDidChangeSelection:(UITextView *)textView
{
    [self adjustOffsite];
}
-(void)textViewDidChange:(UITextView *)textView
{
    contentCell.placeholder.hidden = (contentCell.textView.text.length > 0);
    [self adjustOffsite];
    [self adjustToolBar];

}
-(void)adjustOffsite{
    
    UITextRange *startTextRange = contentCell.textView.selectedTextRange;
    CGRect caretRect = [contentCell.textView caretRectForPosition:startTextRange.end];
    CGFloat caretTop = CGRectGetMinY(caretRect);
    CGFloat lineHeight = CGRectGetHeight(caretRect);
    CGFloat keyboardHeight = [CRKeyboardUtility keyboardFrame].size.height;
    CGFloat y = TopHeight + keyboardHeight + 20 + 44 + caretTop + lineHeight - AppWindow.height;
    
    CGPoint offsite = self.tableView.contentOffset;
    if (y > 0) {
        offsite.y = y;
        self.tableView.contentOffset = offsite;
    }

}
# pragma mark - facialDelegate

# pragma mark - 添加表情

-(void)selectedFacialView:(NSString*)str
{
    if ([str isEqualToString:@"删除"]) {
        [self deleteFacial];
        return;
    }
    NSString *new = CRString(@"%@%@",contentCell.textView.text,str);
    contentCell.textView.text = new;
    [self textViewDidChange:contentCell.textView];
}

# pragma mark - 发送

-(void)sendMessage
{
    [self submite:nil];
}
-(void)deleteFacial{
    
    NSError *error = nil;
    NSString *regTags = @"\\[[\\u4e00-\\u9fa5a-z]{1,3}\\]";       // 设计好的正则表达式，最好先在小工具里试验好
    NSString *text = contentCell.textView.text;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                  
                                                                           options:NSRegularExpressionCaseInsensitive    // 还可以加一些选项，例如：不区分大小写
                                  
                                                                             error:&error];
    
    // 执行匹配的过程
    
    NSArray *matches = [regex matchesInString:text options:0  range:NSMakeRange(0, [text length])];
    
    // 用下面的办法来遍历每一条匹配记录
    NSRange range = contentCell.textView.selectedRange;
    NSLog(@"loc aa  == %d, len aa == %d",range.location,range.length);
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        NSLog(@"loc  == %d, len == %d",matchRange.location,matchRange.length);
        if (range.location>=matchRange.location&&range.location<=matchRange.location+matchRange.length) {
            
            NSString *newStr = [text stringByReplacingCharactersInRange:matchRange withString:@""];
            contentCell.textView.text = newStr;
            return;
            break;
            
        }
    }
    if (text.length>0) {
        
        NSString *newText = [text substringToIndex:text.length - 1];
        contentCell.textView.text = newText;
    }
    
}


@end
