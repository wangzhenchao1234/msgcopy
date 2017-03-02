//
//  FilterController.m
//  msgcopy
//
//  Created by wngzc on 15/7/14.
//  Copyright (c) 2015年 wngzc. All rights reserved.
//

#import "FilterController.h"

@interface FilterController ()
{
    NSDictionary *_curCondition;
    NSArray *_locations;
}
@property(nonatomic,retain)NSMutableArray *searchResults;

@end

@implementation FilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
    [self intilizedDataSource];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)intilizedDataSource{
    //intilizedDataSource
    _searchResults = [NSMutableArray new];
    _locations = [LocationManager sharedManager].locations;
}
-(void)configTableView
{
    //config some
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        return _conditions.count;
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _searchResults.count;
    }
    if (_curCondition) {
        return 1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.font = MSGFont(15);
    if (tableView == self.tableView) {
        
        if (indexPath.section == 0) {
            [[LocationManager sharedManager] refreshServer];
            cell.accessoryType = UITableViewCellAccessoryNone;
            _curCondition = nil;
            for (NSString *lcs in _locations) {
                for (NSDictionary *item in _conditions) {
                    if ([[item valueForKey:@"title"] length] >= lcs.length) {
                        if ([[item valueForKey:@"title"] rangeOfString:lcs].location!=NSNotFound) {
                            _curCondition = item;
                            break;
                        }
                    }else{
                        if ([lcs rangeOfString:[item valueForKey:@"title"]].location!=NSNotFound) {
                            _curCondition = item;
                            break;
                        }
                    }
                    
                }
                if (_curCondition) {
                    break;
                }
            }
            if (_curCondition) {
                cell.textLabel.text = _curCondition[@"title"];
            }else{
                cell.textLabel.text = @"GPS正在定位...";
            }
            return cell;
        }

        NSDictionary *condition = CRArrayObject(_conditions, indexPath.row);
        if (CRJSONIsDictionary(condition)) {
            NSString *title = [Utility dictionaryNullValue:condition forKey:@"title"];
            cell.textLabel.text = title;
            if (![condition valueForKey:@"children"]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }else{
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }else{
        if (indexPath.section == 0) {
            NSDictionary *item = CRArrayObject(_searchResults, indexPath.row);
            cell.textLabel.text = [item valueForKey:@"title"];
            cell.textLabel.textColor = [UIColor blackColor];
            if (![item valueForKey:@"children"]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }else{
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    // Configure the cell...
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = nil;
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {
            
            if (!_locations) {
                return;
            }
            item = _curCondition;
            
        }else{
            item = CRArrayObject(_conditions, indexPath.row);
        }
    }else{
        item = _searchResults[indexPath.row];
    }
    NSDictionary *condition = CRArrayObject(_conditions, indexPath.row);
    
    if (CRJSONIsDictionary(condition)) {
        NSArray *conditions = [Utility dictionaryValue:condition forKey:@"children"];
        if (conditions) {
            
            FilterController *filter = [Utility controllerInStoryboard:@"Main" withIdentifier:@"FilterController"];
            filter.title = [Utility dictionaryNullValue:condition forKey:@"title"];
            filter.conditions = conditions;
            [self.navigationController pushViewController:filter animated:true];

        }else{
            [FilterManager updateCurFilter:condition];
            CRUserSetBOOL(true, kFilterInit);
            [self.navigationController popToRootViewControllerAnimated:true];
        }
    }
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    NSString *text = searchBar.text;
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *item in _conditions) {
        NSString *title = [item valueForKey:@"title"];
        if ([title containsString:text]) {
            [result addObject:item];
        }
    }
    [_searchResults removeAllObjects];
    [_searchResults addObjectsFromArray:result];
    [self.searchDisplayController.searchResultsTableView reloadData];
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
