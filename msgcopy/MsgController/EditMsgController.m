//
//  EditMsgController.m
//  msgcopy
//
//  Created by sh on 16/10/20.
//  Copyright © 2016年 wngzc. All rights reserved.
//

#import "EditMsgController.h"


#import "CreateMsgController.h"
#import "AddCommentContentCell.h"
#import "AddCommentHeaderView.h"
#import "AddCommentFooterView.h"
#import "MsgController.h"
#import "MsgGroupCell.h"
#import "MsgTitleCell.h"
#import "GVPickerView.h"

#define TopHeight  88//79
#define FooterHeight (AppWindow.width-10)+10

static NSString *imgLabelText = @"<div class='img_wrap'><img class='pic' src='#'></div>";
static NSString *videoLabelText = @"<div class='img_wrap'><img class='video' src='#'></div>";

static NSString *GroupCell = @"GroupCell";
static NSString *TitleCell = @"TitleCell";
static NSString *ContentCell = @"ContentCell";

@interface EditMsgController ()<UITableViewDataSource,UITableViewDelegate,AddCommentContentCellDelegate,GVPickerViewDelegate>
{
    NSInteger curGroup;
}
@property(nonatomic,retain)MsgGroupCell *groupCell;
@property(nonatomic,retain)MsgTitleCell *titleCell;
@property(nonatomic,retain)GVPickerView *picker;
@property(nonatomic,retain)AddCommentContentCell *contentCell;
@property(nonatomic,retain)AddCommentHeaderView *header;
@property(nonatomic,retain)AddCommentFooterView *footer;
//@property(nonatomic,retain)NSMutableArray * array;//盛放picker选择的照片
@end

@implementation EditMsgController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self intilizedDataSource];
    [self configNavigationItem];
    [self configFooterView];
    [self configToolBar];

    // Do any additional setup after loading the view.
}

# pragma mark - 添加导航栏按钮

-(void)configNavigationItem
{
    //config some
    self.title = @"编辑投稿";
    self.attaches = [[NSMutableArray alloc] init];
    UIButton *submite = [UIButton buttonWithType:UIButtonTypeCustom];
    submite.frame = CGRectMake(0, 0, 27, 27);
    submite.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [submite setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
    [submite addTarget:self action:@selector(submite:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *submiteItem = [[UIBarButtonItem alloc] initWithCustomView:submite];
    self.navigationItem.rightBarButtonItem = submiteItem;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)intilizedDataSource{
    //intilizedDataSource
    
    NSLog(@"_article.images --- %@",_article.images);
    self.attaches = [[NSMutableArray alloc] init];
    
    if (!_groupDicts) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        hud.removeFromSuperViewOnHide = true;
        CRWeekRef(self);
        [MSGRequestManager Get:kAPIAllGroup params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//            [hud hide:true];
            if (CRJSONIsArray(data)) {
                NSMutableArray *groups = [[NSMutableArray alloc] init];
                [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] init];
                    ArticleGroupEntity *group = [ArticleGroupEntity buildInstanceByJson:obj];
                    [groupDict setObject:group forKey:@"group"];
                    [groups addObject:groupDict];
                    
                }];
                _groupDicts = groups;
                [__self.tableView reloadData];
            }else{
                [CustomToast showMessageOnWindow:@"发生未知错误"];
            }
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//            [hud hide:true];
            [CustomToast showMessageOnWindow:msg];
        }];
    }
    
    
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
    
    [self.attaches removeAllObjects];
//    NSLog(@"222222-------------================%@",_article.videos);
    for (KaokeImage * image in _article.images) {
        NSDictionary *dict = @{@"name": image.otitle,@"type":@"image"};
        [self.attaches addObject:dict];
    }
    for (KaokeVideo * video in _article.videos) {
        NSDictionary *dict = @{@"name": video.otitle,@"type":@"video",@"thumbnail":video.thumbnail};
        [self.attaches addObject:dict];
    }
    
//    NSLog(@"编辑页面中的attaches-------------================%@",self.attaches);
    [_footer reloadWithAttachs:self.attaches];
    
    
}

# pragma mark - 工具栏

-(void)configToolBar
{
    //config some
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    self.toolBar.backgroundColor = CRCOLOR_WHITE;
    self.toolBar.tintColor = CRCOLOR_BLACK;
    
    [self.view addSubview:self.toolBar];
    
    UIBarButtonItem *image = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cm_picture"] style:UIBarButtonItemStyleDone target:self action:@selector(openPhotoAllbum:)];
    UIBarButtonItem *photoCamera = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_camera"] style:UIBarButtonItemStyleDone target:self action:@selector(openPhotoCamera:)];
    UIBarButtonItem *video = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cm_video"] style:UIBarButtonItemStyleDone target:self action:@selector(openVideoCamera:)];
    
    UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolBar.items = @[image,space1,photoCamera,space2,video];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <2 ) {
        return 44;
    }
    return 1000;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = nil;
    if (indexPath.row == 0) {
        cellIdentity = GroupCell;
    }else if(indexPath.row == 1){
        cellIdentity = TitleCell;
    }else{
        cellIdentity = ContentCell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        if (!cell) {
            cell = [Utility nibWithName:@"MsgGroupCell" index:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        _groupCell = (MsgGroupCell*)cell;
//        NSMutableDictionary *groupDict = CRArrayObject(_groupDicts, curGroup);
//        if (groupDict) {
//            ArticleGroupEntity *group = groupDict[@"group"];
            _groupCell.titleView.text = _article.parent.title;
//        }
        
    }else if(indexPath.row == 1){
        if (!cell) {
            cell = [Utility nibWithName:@"MsgTitleCell" index:0];
        }
        _titleCell = (MsgTitleCell*)cell;
        _titleCell.titleFiled.text = _article.title;
    }else{
        if (!cell) {
            cell = [Utility nibWithName:@"AddCommentContentCell" index:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        NSString * mStr = [_article.content substringFromIndex:21];
        NSRange range = [mStr rangeOfString:@"<"];//匹配得到的下标
//        NSLog(@"rang:%@",NSStringFromRange(range));
       NSString * string = [mStr substringToIndex:range.location];//截取范围类的字符串
        _contentCell = (AddCommentContentCell*)cell;
        _contentCell.textView.text = string;
        _contentCell.placeholder.text = @"";

        _contentCell.deletate = self;
        _contentCell.textView.delegate = self;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (_contentCell.textView.isFirstResponder) {
            [_contentCell.textView resignFirstResponder];
        }
        if (_titleCell.titleFiled.isFirstResponder) {
            [_titleCell.titleFiled resignFirstResponder];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:true];
        if (!_picker) {
            _picker = [GVPickerView sharedPicker];
        }
        _picker.delegate = self;
        [_picker show];
    
    }
}

# pragma mark - PickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(GVPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(GVPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _groupDicts.count;
}

-(NSString*)pickerView:(GVPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *dict = CRArrayObject(_groupDicts, row);
    ArticleGroupEntity *group = [Utility dictionaryValue:dict forKey:@"group"];
    if (group) {
        return group.title;
    }
    return @"";
}

-(void)changePickerSubmite:(NSIndexPath*)indexPath
{
    curGroup = indexPath.row;
    NSDictionary *dict = CRArrayObject(_groupDicts, indexPath.row);
    ArticleGroupEntity *group = [Utility dictionaryValue:dict forKey:@"group"];
    if (group) {
        _groupCell.titleView.text  = group.title;
    };
}
# pragma mark - 调整高度

-(void)adjustFrame:(id)sender{
    
    //do something
    CGSize size = _contentCell.textView.contentSize;
    CGRect frame = _contentCell.textView.frame;
    frame.size.height = size.height;
    _contentCell.textView.frame = frame;
    CGRect cellFrame = _contentCell.frame;
    cellFrame.size.height = _contentCell.topConstraint.constant + _contentCell.bottomConstranit.constant + frame.size.height;
    _contentCell.frame = cellFrame;
    CGSize tableSize = self.tableView.contentSize;
    CGFloat height = TopHeight + FooterHeight + _contentCell.height;
    tableSize.height = height;
    self.tableView.contentSize = tableSize;
    _footer.y = TopHeight + _contentCell.height;
    
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
    if (_titleCell.titleFiled.text.length == 0) {
        [CustomToast showMessageOnWindow:@"标题不能为空"];
        return;
    }
    
    
    if (self.attaches.count == 0 && _contentCell.textView.text.length == 0 ) {
        [CustomToast showMessageOnWindow:@"内容不能为空"];
        return;
    }
    
    if ([self isEmpty:_titleCell.titleFiled.text] || [self isEmpty:_contentCell.textView.text]) {
        [CustomToast showMessageOnWindow:@"标题或正文中不能全部为空格"];
        return;
    }
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    hud.removeFromSuperViewOnHide = true;
    [AppWindow addSubview:hud];
    [hud show:true];
    
    
    
    //处理content
    NSString*(^handleContent)(NSString *str) = ^(NSString *str){
        NSMutableString *contentStr = [[NSMutableString alloc] init];
        NSString *content = CRString(@"<p>%@</p>",_contentCell.textView.text);
        [contentStr appendFormat:@"%@",content];
        
        for (NSDictionary *attach in self.attaches) {
            if ([attach[@"type"] isEqualToString:@"image"]) {
                [contentStr appendString:imgLabelText];
            }else if([attach[@"type"] isEqualToString:@"video"]){
                [contentStr appendString:videoLabelText];
            }
        }
        NSString *resultStr = CRString(@"<div id='content'>%@</div>",contentStr);
//        NSLog(@"++++++++++++++++++++++++++++++++%@",contentStr);
        
        return resultStr;
    };
    //处理缩略图
    NSData *(^handleThumbnail)(NSArray*attachs) = ^(NSArray *attachs){
        
        __block NSData *result = nil;
        [attachs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *attach = obj;
            if ([attach[@"type"] isEqualToString:@"image"]) {
                NSString *name = attach[@"name"];
                if (name) {
                    NSString *path = CRUploadFilePath(name);
                    if (path) {
                        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
                        if (data) {
                            result = data;
                            *stop = true;
                        }
                    }
                }
            }else if([attach[@"type"] isEqualToString:@"video"]){
                if (attach[@"thumbnail"]) {
                    NSString *path = CRUploadFilePath(attach[@"thumbnail"]);
                    if (path) {
                        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
                        if (data) {
                            result = data;
                            *stop = true;
                        }
                    }
                }
                
                
            }
        }];
        return result;
    };
    
    __block NSString *resultStr = handleContent(_contentCell.textView.text);
    if (_contentCell.textView.text.length == 0) {
        _contentCell.textView.text = @"";
    }
    CRWeekRef(self);
    //创建收藏缩略图
    NSData *thumdata = handleThumbnail(self.attaches);
    __block ThumbnailEntity *thumbnail = nil;
    if (thumdata) {
        //缩略图存在先上传缩略图
        [UploadManager createArticleThumnail:thumdata success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            thumbnail = data;
            NSLog(@"编辑页上传缩略图中的thumbnail ----------------- %@",thumbnail);
            [__self submitMsgWithThumbnail:thumbnail content:resultStr];
            
        } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
            [__self submitMsgWithThumbnail:nil content:resultStr];
            NSLog(@"提交收藏缩略图失败");
        }];
    }else{
        //缩略图不存在直接提交
        [__self submitMsgWithThumbnail:nil content:resultStr];
    }
}

-(void)submitMsgWithThumbnail:(ThumbnailEntity*)thumbnal content:(NSString*)content{
    
    NSMutableDictionary *params = nil;
    NSDictionary *groupDict = CRArrayObject(_groupDicts, curGroup);
    if (!groupDict) {
        [CustomToast showMessageOnWindow:@"请选择分组"];
        return;
    }
    ArticleGroupEntity *group = [Utility dictionaryValue:groupDict forKey:@"group"];
    if (!group) {
        [CustomToast showMessageOnWindow:@"请选择分组"];
    }
    NSString *contentStr = _contentCell.textView.text;
    NSString *descr = contentStr.length>120?[contentStr substringToIndex:120]:contentStr;
//    NSLog(@"########### %d",curGroup);
    if (thumbnal) {
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_titleCell.titleFiled.text,@"title",content,@"content",[NSString stringWithFormat:@"%d",group.gid],@"group",@"1",@"ctype",[NSString stringWithFormat:@"%d",thumbnal.tid],@"thumbnail",descr,@"descr",nil];
        
    }else{
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_titleCell.titleFiled.text,@"title",content,@"content",[NSString stringWithFormat:@"%d",group.gid],@"group",@"1",@"ctype",@"",@"thumbnail",descr,@"descr", nil];
        
    }
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    CRWeekRef(hud);
    CRWeekRef(self);
    [MSGRequestManager Update:kAPIEditMsg(_article.mid) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
       
        NSMutableArray * mArr = [[NSMutableArray alloc] init]; //修改之后的media
        NSMutableArray * artArr = [[NSMutableArray alloc] init]; //文章原有的media
        for (KaokeImage * ima in _article.images) {
            NSDictionary * dict = @{@"name":ima.otitle,@"type":@"image"};
            [artArr addObject:dict];
        }
        for (KaokeVideo * vie in _article.videos) {
            NSDictionary * dict = @{@"name":vie.otitle,@"type":@"video",@"thumbnail":vie.thumbnail};
            [artArr addObject:dict];
        }
        
        
        for (NSDictionary * media in self.attaches) {
            [mArr addObject:media];
        }
        [artArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
            NSDictionary * mei = obj;
            if (![mArr containsObject:mei] || mArr.count == 0) {
                if ([mei[@"type"] isEqualToString:@"image"]) {
                [_article.images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    KaokeImage * ima = obj;
                    if ([ima.otitle isEqualToString:mei[@"name"]]) {
                        [MSGRequestManager MKDelete:KAPIDeleteImage(_article.mid,ima.mid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    NSLog(@"删除成功");
                    [artArr removeObject:mei];
                    [_article.images removeObject:ima];
                
//                    [__self uploadFinished:_article];
                    
                    
                    
                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                    NSLog(@"删除失败");
                    [CustomToast showMessageOnWindow:msg];
                }];
                }
               
            }];
                }else if([mei[@"type"] isEqualToString:@"video"]){
                    [_article.videos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        KaokeVideo * vid = obj;
                        if ([vid.otitle isEqualToString:mei[@"name"]]) {
                            [MSGRequestManager MKDelete:KAPIDeleteVideo(_article.mid,vid.mid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                NSLog(@"删除成功");
                                [artArr removeObject:mei];
                                [_article.images removeObject:vid];
                                
                                
                            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                NSLog(@"删除失败");
                                [CustomToast showMessageOnWindow:msg];
                            }];
                        }
                        
                    }];
                
                }
    }
}];

        
            for (int i = 0;i < mArr.count; i++) {
                    if (![artArr containsObject:mArr[i]] || artArr.count == 0) {
                            __hud.labelText = @"正在上传第1个附件";
                                NSString *filePath = CRUploadFilePath(mArr[i][@"name"]);
                                NSData * ds = [NSData dataWithContentsOfFile:filePath];
                                NSData *thData = nil;
                                if ([mArr[i][@"type"] isEqualToString:@"video"]) {
                                    NSString *tName = mArr[i][@"thumbnail"];
                                    UIImage *thumbnail = [UIImage imageWithContentsOfFile:CRUploadFilePath(tName)];
                                    if (UIImagePNGRepresentation(thumbnail) == nil) {
                                        thData =  UIImageJPEGRepresentation(thumbnail, 1);
                                    } else {
                                        thData = UIImagePNGRepresentation(thumbnail);
                                    }
                                }
                                __block BOOL finished = false;
                                    NSString * type = mArr[i][@"type"];
                                    NSString * name = mArr[i][@"name"];
                                [UploadManager uploadFile:ds type:type name:name success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                    
                                    MediaEntity* media = data;
//                                     NSLog(@"上传过程中 ------ %d - %@  ",media.mid,media.fType);
                                    NSString *descr = _titleCell.titleFiled.text.length >= 24?[_titleCell.titleFiled.text substringToIndex:23]:_titleCell.titleFiled.text;
                                    [UploadManager createArticleMedia:media.mid descr:descr fType:media.fType thumnail:thData success:^(NSString *msg, NSInteger code, id data, NSString *requestURL)
                                     {
                                         
                                         ArticleMediaEntity *aMedia = data;
                                         aMedia.type = type;
                                         NSMutableDictionary *params  = [NSMutableDictionary dictionaryWithObjectsAndKeys:descr,@"descr",[NSString stringWithFormat:@"%d",aMedia.aid],@"obj",nil];
                                         
                                         [MSGRequestManager MKUpdate:kAPILinkMsgMedia(_article.mid,aMedia.type) params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                             finished = true;
//                                             --count;
//                                             NSInteger index = self.attaches.count - count;
//                                             __hud.labelText = CRString(@"正在上传第%d个附件",index);
//                                             if (count == 0) {
                                                 [__self uploadFinished:_article];
//                                             }
                                         } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//                                             --count;
//                                             NSInteger index = self.attaches.count - count;
//                                             __hud.labelText = CRString(@"正在上传第%d个附件",index);
//                                             if (count == 0) {
                                                 [__self uploadFinished:_article];
//                                             }
                                             finished = true;
                                         }];
                                         
                                         
                                         
                                     } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                         finished = true;
//                                         --count;
//                                         NSInteger index = self.attaches.count - count;
//                                         __hud.labelText = CRString(@"正在上传第%d个附件",index);
//                                         if (count == 0) {
                                             [__self uploadFinished:_article];
//                                         }
                                         
                                     }];
                                    
                                } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                                    finished = true;
//                                    --count;
//                                    NSInteger index = self.attaches.count - count;
//                                    __hud.labelText = CRString(@"正在上传第%d个",index);
//                                    if (count == 0) {
                                        [__self uploadFinished:_article];
//                                    }
                                }];
                                
//                            }
                        
                        }
                        
                }
        
        //video
        
        
        
        
        
        
            
            [__self uploadFinished:_article];
            
        }failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//        [__hud hide:true];
        [CustomToast showMessageOnWindow:msg];
        return;

    }];
    

    
}


-(void)uploadFinished:(ArticleEntity*)msgi{
//    NSLog(@"==============%@",msgi.images);
    CRWeekRef(self);
    MBProgressHUD *hud = [MBProgressHUD HUDForView:AppWindow];
    CRWeekRef(hud);
//    [MSGRequestManager Get:kAPIMSG(msgi.mid) params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [__hud hide:true];
        //修改成功
//        if (__self.pushController) {
            [__self.navigationController popViewControllerAnimated:YES];
//    
//        }
//    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
//        [__hud hide:true];
//        [CustomToast showMessageOnWindow:msg];
//    }];
}
# pragma mark - scrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.facialShown) {
        [self hiddenEmotionView];
    }
    [_contentCell.textView resignFirstResponder];
}

# pragma mark -  textViewDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.facialShown) {
        [self hiddenEmotionView];
    }
    _contentCell.placeholder.hidden = (textView.text.length > 0);
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
    _contentCell.placeholder.hidden = (textView.text.length > 0);
    [self adjustOffsite];
    [self adjustToolBar];
    
}
-(void)adjustOffsite{
    
    UITextRange *startTextRange = _contentCell.textView.selectedTextRange;
    CGRect caretRect = [_contentCell.textView caretRectForPosition:startTextRange.end];
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
@end


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

