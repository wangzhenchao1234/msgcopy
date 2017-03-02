//
//  SettingController.m
//  msgcopy
//
//  Created by Gavin on 15/6/19.
//  Copyright (c) 2015年 Gavin. All rights reserved.
//

#import "SettingController.h"
#import "ChangePwdController.h"
#import "UserHelperController.h"

static NSString *CellIdentifire1 = @"SettingCell";

@interface SettingController ()
{
    NSArray *countSettings;
    NSArray *functionSettings;
    NSMutableArray *about;
    BOOL hasUserHelper;
}
@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    [self intilizedDataSource];
    [self.tableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)intilizedDataSource{
    //intilizedDataSource
    countSettings = @[@[@"当前账号",@"修改密码"],@[[UIImage imageNamed:@"acount"],[UIImage imageNamed:@"modify_pwd"]]];
    functionSettings = @[@[@"好友推荐",@"清除缓存"],@[[UIImage imageNamed:@"recommand"],[UIImage imageNamed:@"clear"]]];
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/welcome.bundle/"];
    NSArray *imageNames = CRFilesForType(path, @"png");
    if (imageNames.count>0) {
        hasUserHelper = true;
    }
    about = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableArray *aboutTitles = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableArray *aboutIcons = [[NSMutableArray alloc] initWithCapacity:2];
    
    [about addObject:aboutTitles];
    [about addObject:aboutIcons];
    if (hasUserHelper) {
        [aboutTitles addObject:@"新手帮助"];
        [aboutIcons addObject:[UIImage imageNamed:@"help"]];
    }
    [aboutTitles addObject:@"关于我们"];
    [aboutIcons addObject:[UIImage imageNamed:@"info"]];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return countSettings.count;
            break;
        case 1:
            return functionSettings.count;
            break;
        case 2:
        {
            NSArray *titles = about[0];
            return titles.count;
        }
            break;
    
        default:return 0;
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifire1 forIndexPath:indexPath];
    NSArray *sectionItem = nil;
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (indexPath.section) {
        case 0:
            sectionItem = countSettings;
            if(indexPath.row == 0)
                if (LoginState) {
                    cell.detailTextLabel.text = kCurUser.userName;
                }else{
                    cell.detailTextLabel.text = @"未登录";
                }
            else
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_arrow_right"]];
            break;
        case 1:
            sectionItem = functionSettings;
            break;
        case 2:
            sectionItem = about;
            break;
            
        default:
            break;
    }
    NSArray *icons = CRArrayObject(sectionItem, 1);
    NSArray *titles = CRArrayObject(sectionItem, 0);
    cell.textLabel.font = MSGFont(13);
    cell.detailTextLabel.font = MSGFont(13);
    cell.textLabel.textColor = [UIColor colorFromHexRGB:@"4d4d4d"];
    cell.textLabel.text = CRArrayObject(titles, indexPath.row);
    cell.imageView.image = CRArrayObject(icons, indexPath.row);
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSArray *sectionItem = nil;
    switch (indexPath.section) {
        case 0:
            sectionItem = countSettings;
            break;
        case 1:
            sectionItem = functionSettings;
            break;
        case 2:
            sectionItem = about;
            break;
            
        default:
            break;
    }
    NSArray *titles = CRArrayObject(sectionItem, 0);
    NSString *title = CRArrayObject(titles, indexPath.row);
    
    if ([title isEqualToString:@"修改密码"]) {
        //修改密码
        [self modifyPwd:nil];
        
    }else if([title isEqualToString:@"好友推荐"]){
        //好友推荐
        [self recommandFriends:nil];
        
    }else if([title isEqualToString:@"清除缓存"]){
        //清除缓存
        [self clearCache:nil];
        
    }else if([title isEqualToString:@"新手帮助"]){
        //新手帮助
        [self userHelper:nil];
        
    }else if([title isEqualToString:@"关于我们"]){
        //关于我们
        [self aboutUs:nil];
    }

}

# pragma mark - 修改密码

-(void)modifyPwd:(id)sender{
    //do something
    if (!LoginState) {
        [CustomToast showMessageOnWindow:@"尚未登录"];
        return;
    }
    ChangePwdController *pwd = [Utility controllerInStoryboard:@"Main" withIdentifier:@"ChangePwdController"];
    [CRRootNavigation() pushViewController:pwd animated:true];
    
}
# pragma mark - 好友推荐

-(void)recommandFriends:(id)sender{
    //do something
    BaseTabItemEntity *base = [[BaseTabItemEntity alloc] initWithType:@"recommend" title:nil icon:nil];
    [base doAction];
}
# pragma mark - 清理缓存

-(void)clearCache:(id)sender{
    //do something
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    CGFloat fileSize =  [self folderSizeAtPath:path];
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    NSArray *contents = [fm contentsOfDirectoryAtPath:path error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        [fm removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL];
    }
    [fm removeItemAtPath:path error:nil];
    [CustomToast showMessageOnWindow:[NSString stringWithFormat:@"成功清理%.02fM缓存",fileSize]];
    fileSize = 0;
}
/**
 *  缓存大小
 *
 *  @param folderPath 缓存路径
 *
 *  @return 缓存大小（M）
 */
- (float )folderSizeAtPath:(NSString*) folderPath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}
/**
 *  缓存大小
 *
 *  @param folderPath 缓存路径
 *
 *  @return 缓存大小（M）
 */
- (long long) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
    
}
# pragma mark - 用户帮助

-(void)userHelper:(id)sender{
    //do something
    UserHelperController *helper = [[UserHelperController alloc] init];
    helper.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [CRRootNavigation() presentViewController:helper animated:true completion:nil];

}
# pragma mark - 关于我们

-(void)aboutUs:(id)sender{
    //do something
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:CRString(@"关于%@",CRAppDisplayName) message:CRAppVersionShort delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
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
