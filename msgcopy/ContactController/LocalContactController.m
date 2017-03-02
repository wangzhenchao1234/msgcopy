//
//  LocalContactController.m
//  msgcopy
//
//  Created by wngzc on 15/7/27.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "LocalContactController.h"
#import <AddressBook/AddressBook.h>
#import "ContactCell.h"


#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface LocalContactController ()<UISearchBarDelegate,UISearchDisplayDelegate,UIScrollViewDelegate>
{
    BlankView *blankView;
}
@property(nonatomic,retain)NSMutableArray *contacts;
@property(nonatomic,retain)NSMutableArray *selectedContacts;
@property(nonatomic,retain)NSMutableArray *searchResultContacts;
@property(nonatomic,retain)UIButton * allSeleButton;
//全选按钮
@property(nonatomic,retain)UILabel * label;
@property (assign, nonatomic)NSInteger count;//全选按钮点击次数
@property (assign,nonatomic)int buttonY;
@property(nonatomic,assign) int viewY;
@property (assign,nonatomic)int labelY;

@property(nonatomic,strong)UIButton*allSelectView;
@end

@implementation LocalContactController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setButtons];
    [self configFooterView];
    [self checkOauth];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchDisplayController setActive:false];
//    [_allSeletedButton removeFromSuperview];

}

-(void)setButtons{
    
    self.title = @"导入联系人";
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"bt_submite"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 27, 27);
    [button addTarget:self action:@selector(submitChanged) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    //全选
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    self.allSelectView = view;
    view.frame = CGRectMake(0, SCREENHEIGHT-44, SCREENWIDTH, 44);
    view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    [_allSelectView addTarget:self action:@selector(allSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:view];
    [self.tableView bringSubviewToFront:view];

    _count = 0;
    _allSeleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_allSeletedButton setImage:[UIImage imageNamed:@"ImageSelectedOff.png"] forState:UIControlStateNormal];
    _allSeleButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-75, 12, 20 , 20);
     _allSeleButton.imageView.frame = _allSeleButton.bounds;
     _allSeleButton.imageView.hidden = NO;
    [_allSeleButton addTarget:self action:@selector(allSelect:) forControlEvents:UIControlEventTouchUpInside];
    _allSeleButton.layer.cornerRadius = _allSeleButton.frame.size.height/2;
    _allSeleButton.layer.masksToBounds = YES;
    _allSeleButton.layer.borderWidth = 1;
    
    [_allSelectView addSubview:_allSeleButton];
//    [self.tableView addSubview:_allSeleButton];
//    [self.tableView bringSubviewToFront:_allSeleButton];
   // _buttonY=(int)_allSeleButton.frame.origin.y;
    _viewY = (int)_allSelectView.frame.origin.y;
    _label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-50,7, 40, 30)];
    _label.text = @"全选";
    [_label setFont:[UIFont systemFontOfSize:14]];
    [_label setTintColor:[UIColor blackColor]];
    [_allSelectView addSubview:_label];
//    [self.tableView addSubview:_label];
//    [self.tableView bringSubviewToFront:_label];
   // _labelY=(int)_label.frame.origin.y;
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

   _allSelectView.frame = CGRectMake(_allSelectView.frame.origin.x, _viewY + self.tableView.contentOffset.y, _allSelectView.frame.size.width, _allSelectView.frame.size.height);
    
//    _allSeleButton.frame = CGRectMake(_allSeleButton.frame.origin.x, _buttonY + self.tableView.contentOffset.y, _allSeleButton.frame.size.width, _allSeleButton.frame.size.height);
//    
//    _label.frame = CGRectMake(_label.frame.origin.x, _labelY + self.tableView.contentOffset.y, _label.frame.size.width, _label.frame.size.height);
//
}



//所有的model的seleted变化

-(void)ChangeAlldateForSeleted:(BOOL)seleted{

    for (ContactEntity * model in _contacts) {
        model.isSelected = seleted;
    }

    [self.tableView reloadData];
}


#pragma mark - 全选

-(void)allSelect:(UIButton *)sender{
    
    _count += 1;

    //将所有的数据都存在一个数组中
    
    sender.selected = !sender.selected;
    if (_count % 2 == 1) {
        
//        [_allSeleButton setImage:[UIImage imageNamed:@"ImageSelectedOn.png"] forState:UIControlStateSelected];
        _allSeleButton.backgroundColor = [UIColor colorWithRed:0.000 green:0.478 blue:1.000 alpha:1.00];
        [self.selectedContacts removeAllObjects];
        for (ContactEntity * contact in self.contacts) {
            if (contact) {
                [self.selectedContacts addObject:contact];
            }
            
            
        }
        
        [self ChangeAlldateForSeleted:YES];
        
        
        for (int i = 0; i < self.selectedContacts.count; i++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
        
    
    }else{
    
//        [_allSeleButton setImage:[UIImage imageNamed:@"ImageSelectedOff.png"] forState:UIControlStateNormal];
        _allSeleButton.backgroundColor = [UIColor whiteColor];
        [self.selectedContacts removeAllObjects];
        for (int i = 0; i < self.selectedContacts.count; i++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        [self ChangeAlldateForSeleted:NO];
    }
    
//    NSLog(@"self.selectedContacts--------%@",self.selectedContacts);
}




-(void)configFooterView
{
   
    //config some
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setEditing:true];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.searchDisplayController.searchResultsTableView setEditing:true];
    self.searchDisplayController.searchBar.returnKeyType = UIReturnKeyDone;
}
-(void)checkOauth{
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    
    
    __block BOOL accessGranted = NO;
    if (&ABAddressBookRequestAccessWithCompletion) {
        
        // we're on iOS 6
        NSLog(@"on iOS 6 or later, trying to grant access permission");
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else { // we're on iOS 5 or older
        
        NSLog(@"on iOS 5 or older, it is OK");
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
        [self intilizedDataSource];

    }else{
        UILabel *placeView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.allSelectView.width, self.allSelectView.height)];
        placeView.textAlignment = NSTextAlignmentCenter;
        placeView.textColor = [UIColor colorFromHexRGB:@"999999"];
        placeView.font = MSGFont(20);
        placeView.text = @"访问未经授权";
        self.tableView.backgroundView = placeView;

    }
}
-(void)intilizedDataSource{
    //intilizedDataSource
    self.contacts = [[NSMutableArray alloc] init];
    self.selectedContacts = [[NSMutableArray alloc] init];
    _searchResultContacts = [[NSMutableArray alloc] init];
    NSString *os_version = [[UIDevice currentDevice] systemVersion];
    
    ABAddressBookRef addressBookRef;
    if ([os_version compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending)
    {
        addressBookRef = ABAddressBookCreate();
        [self getAddressBookContacts:addressBookRef];
    }
    else
    {
        // Request authorization to Address Book
        addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                // First time access has been granted, add the contact
                if(granted)
                {
                    ABAddressBookRef addressBookRef1 = ABAddressBookCreateWithOptions(NULL, NULL);
                    [self getAddressBookContacts:addressBookRef1];
                    CFRelease(addressBookRef1);
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access, add the contact
            [self getAddressBookContacts:addressBookRef];
        }
        else {
            // The user has previously denied access
            // Send an alert telling user to change privacy setting in settings app
        }
    }
    
    if(addressBookRef!=NULL)      CFRelease(addressBookRef);

    if (_contacts.count == 0) {
        if (!blankView) {
            blankView = [BlankView blanViewWith:[UIImage imageNamed:@"message_blank"] descr:@"通讯录里没有任何联系人" actionTitle:nil target:nil selector:nil];
            blankView.actionView.hidden = true;
        }
        self.tableView.backgroundView = blankView;
    }else{
        self.tableView.backgroundView = nil;
    }

    [self.tableView reloadData];
}
//获取本地通讯录
-(void)getAddressBookContacts:(ABAddressBookRef)addressBookRef
{
    
    
    //            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    CFIndex n = ABAddressBookGetPersonCount(addressBookRef);
    
    for( NSInteger i = 0 ; i < n ; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        
        ABMultiValueRef contactnumber = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        
        NSString *firstName1 = (__bridge_transfer NSString *)firstName;
        NSString *lastName1 = (__bridge_transfer NSString *)lastName;
        
        for(CFIndex j = 0; j < ABMultiValueGetCount(contactnumber); j++)
        {
            CFStringRef contactnumberRef = ABMultiValueCopyValueAtIndex(contactnumber, j);
            
            NSString *contactnumberstr = (__bridge NSString *)contactnumberRef;
            //            [self.contactnumberArray contactnumber];
            NSMutableString *num = [contactnumberstr mutableCopy];
            NSMutableCharacterSet *set = [NSMutableCharacterSet characterSetWithCharactersInString:@"- "];
            NSArray *array = [num componentsSeparatedByCharactersInSet:set];
            NSMutableString *phoneNum = [[NSMutableString alloc] initWithCapacity:0];
            for (NSString *str in array) {
                [phoneNum appendString:str];
            }
            ContactEntity* contact = [[ContactEntity alloc] init];
            if (firstName1 == nil) {
                firstName1 = @"";
            }
            if (lastName1 == nil) {
                lastName1 = @"";
            }
            [contact setTitle:[NSString stringWithFormat:@"%@ %@", lastName1, firstName1]];
            [contact setPhone:phoneNum];
            
            
            [self.contacts addObject:contact];
//            NSLog(@"contacts - %@",contact.phone);
            
            CFRelease(contactnumberRef);
        }
        
        CFRelease(contactnumber);
    }
    CFRelease(all);
    
}
# pragma mark -  actions

-(void)submitChanged
{
    
    if (self.selectedContacts.count == 0) {
        [CustomToast showMessageOnWindow:@"未选中任何内容！"];
        return;
    }
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:AppWindow];
    [AppWindow addSubview:hud];
    hud.removeFromSuperViewOnHide = true;
    [hud show:true];
    CRWeekRef(self);
    CRWeekRef(hud);
    __block NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    [MSGRequestManager Get:kAPIAllContactGroup params:nil success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ContactGroupEntity *group = [ContactGroupEntity buildInstanceByJson:obj];
            [groups addObject:group];
        }];
        ContactGroupEntity *group = groups[0];
        __block NSInteger success = 0;
        __block NSInteger failed = 0;
        __hud.labelText = @"正在导入第1个";
        [self.selectedContacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ContactEntity *contact = obj;
            NSDictionary *params = @{
                                     @"title":contact.title,
                                     @"phone":contact.phone,
                                     @"group":CRString(@"%d",group.gid)
                                     };
            [MSGRequestManager Post:kAPIAllContacts params:params success:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                success ++ ;
                if (success + failed >= [_selectedContacts count]) {
                    [__hud hide:true];
                    [_selectedContacts removeAllObjects];
                    [__self.tableView reloadData];
                    [__self.searchDisplayController.searchResultsTableView reloadData];
                    [CustomToast showMessageOnWindow:CRString(@"导入完毕：\n成功%d;\n失败:%d",success,failed)];
                   
                }else{
                    __hud.labelText = CRString(@"正在导入第%d个",success+failed+1);
                }
                
            } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL) {
                
                NSLog(@"msg - %@",msg);
                
                
                failed ++ ;
                if (success + failed >= [_selectedContacts count]) {
                    [__hud hide:true];
                    [_selectedContacts removeAllObjects];
                    [__self.tableView reloadData];
                    [CustomToast showMessageOnWindow:CRString(@"导入完毕：\n成功%d;\n失败:%d",success,failed)];
                }else{
                    __hud.labelText = CRString(@"正在导入第%d个",success+failed+1);
                }

            }];
            
        }];
        
    } failed:^(NSString *msg, NSInteger code, id data, NSString *requestURL){
        
        [hud hide:true];
        [CustomToast showMessageOnWindow:msg];
        return;
        
    }];
     _allSeleButton.backgroundColor = [UIColor whiteColor];
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
    if (tableView ==  self.searchDisplayController.searchResultsTableView) {
        return _searchResultContacts.count;
    }
    return _contacts.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifire = @"ContactCell";
    ContactCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifire];
    ContactEntity *contact = CRArrayObject(_contacts, indexPath.row);
    if (contact) {
        [cell.headView setImage:UserPlaceImage];
        cell.nickView.text = contact.title;
        cell.phoneView.text = contact.phone;
    }
    // Configure the cell...
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactEntity *contact = _contacts[indexPath.row];
    if (contact) {
        [self.selectedContacts addObject:contact];
    }

    
//    NSLog(@"_--------------%@",contact);
    
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

# pragma mark - searchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSString *text = searchBar.text;
    NSMutableArray *result = [NSMutableArray new];
    [self.contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ContactEntity *contact = obj;
        if ([contact.title containsString:text]||[contact.phone containsString:text]) {
            [result addObject:contact];
        }
    }];
    [_searchResultContacts removeAllObjects];
    [_searchResultContacts addObjectsFromArray:result];
    [self.searchDisplayController.searchResultsTableView reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self submitChanged];
}

//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    
//}


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




@end
